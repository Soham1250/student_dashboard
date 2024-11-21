import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:async'; // For Timer
import 'dart:convert'; // For JSON parsing
import '../../../../../api/api_service.dart';
import '../../../../../api/endpoints.dart';

class UniversalTestInterface extends StatefulWidget {
  @override
  _UniversalTestInterfaceState createState() => _UniversalTestInterfaceState();
}

class _UniversalTestInterfaceState extends State<UniversalTestInterface> {
  late List<Map<String, dynamic>> questions; // Questions list
  bool isLoading = true; // To show spinner while fetching questions
  int currentQuestionIndex = 0;
  late int totalTime; // Timer (in seconds)
  late Timer timer;
  int remainingTime = 0;

  late String username; // Extracted from arguments
  late String testType; // Extracted from arguments
  final ApiService _apiService = ApiService(); // Initialize API service

  @override
  void initState() {
    super.initState();
    questions = []; // Initialize empty list
    // Timer setup will be initialized after arguments are loaded
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Extract arguments
    final Map<String, String> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    username = args['username']??"Unknown";
    testType = args['testType']??"Unknown";

    // Set timer based on test type
    totalTime = testType == "Full-length" ? 180 * 60 : 40 * 60;
    remainingTime = totalTime;

    // Fetch questions
    fetchQuestions();
    startTimer();
  }

  // Fetch questions from the API
  Future<void> fetchQuestions() async {
    try {
      final response = await _apiService.postRequest(
        addQuestionPaperEndpoint,
        {"testType": testType}
      );
      
      setState(() {
        questions = (response['addedQuestions'] as List).map((q) {
          return {
            'question': q['Question'],
            'options': [q['OptionA'], q['OptionB'], q['OptionC'], q['OptionD']],
            'correctAnswer': q['CorrectOption'],
            'userAnswer': null,
            'markedForReview': false,
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching questions: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Start the timer
  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
        });
      } else {
        timer.cancel();
        submitTest(); // Auto-submit when time runs out
      }
    });
  }

  // Format timer display
  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // Mark/unmark question for review
  void toggleMarkForReview() {
    setState(() {
      questions[currentQuestionIndex]['markedForReview'] =
          !questions[currentQuestionIndex]['markedForReview'];
    });
  }

  // Select an answer
  void selectAnswer(String? selectedAnswer) {
    setState(() {
      questions[currentQuestionIndex]['userAnswer'] = selectedAnswer;
    });
  }

  // Navigate to specific question
  void navigateToQuestion(int index) {
    setState(() {
      currentQuestionIndex = index;
    });
  }

  // Submit test manually
  void submitTest() {
    timer.cancel(); // Stop timer
    final attempted = questions.where((q) => q['userAnswer'] != null).length;
    final markedForReview = questions.where((q) => q['markedForReview']).length;

    // Show confirmation dialog for manual submission
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Submit Test"),
          content: Text(
              "You have answered $attempted questions and marked $markedForReview questions for review. Do you want to submit?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _finalSubmit();
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  // Final submission
  void _finalSubmit() {
    final responses = questions.map((q) {
      return {
        'QuestionID': q['question'], // Assuming QuestionID is stored
        'UserAnswer': q['userAnswer'],
        'MarkedForReview': q['markedForReview'],
      };
    }).toList();

    final submissionData = {
      'username': username,
      'testType': testType,
      'responses': responses,
      'timeSpent': totalTime - remainingTime,
    };

    print("Submitting test: $submissionData");
    // Here, you can send `submissionData` to the backend
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => TestAnalysisScreen()),
    // );
  }

  @override
  void dispose() {
    timer.cancel(); // Dispose timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$testType Test"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              formatTime(remainingTime),
              style: const TextStyle(fontSize: 18, color: Colors.red),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Main question area
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Question ${currentQuestionIndex + 1}:",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Html(data: questions[currentQuestionIndex]['question']),
                        const SizedBox(height: 20),
                        ...questions[currentQuestionIndex]['options']
                            .map<Widget>((option) {
                          return ListTile(
                            leading: Radio<String>(
                              value: option,
                              groupValue:
                                  questions[currentQuestionIndex]['userAnswer'],
                              onChanged: selectAnswer,
                            ),
                            title: Html(data: option),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),

                // Sidebar with toggle
                Container(
                  width: 250,
                  color: Colors.grey[200],
                  child: Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.toggle_on),
                        onPressed: () {
                          // Implement sidebar toggle
                        },
                      ),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(8.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 4.0,
                            mainAxisSpacing: 4.0,
                          ),
                          itemCount: questions.length,
                          itemBuilder: (context, index) {
                            Color buttonColor;

                            if (questions[index]['markedForReview'] == true) {
                              if (questions[index]['userAnswer'] != null) {
                                buttonColor = Colors.orange;
                              } else {
                                buttonColor = Colors.purple;
                              }
                            } else if (questions[index]['userAnswer'] != null) {
                              buttonColor = Colors.green;
                            } else {
                              buttonColor = Colors.red;
                            }

                            return ElevatedButton(
                              onPressed: () => navigateToQuestion(index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: toggleMarkForReview,
              child: const Text("Mark for Review"),
            ),
            ElevatedButton(
              onPressed: () {
                if (currentQuestionIndex > 0) {
                  setState(() {
                    currentQuestionIndex--;
                  });
                }
              },
              child: const Text("Previous"),
            ),
            ElevatedButton(
              onPressed: () {
                if (currentQuestionIndex < questions.length - 1) {
                  setState(() {
                    currentQuestionIndex++;
                  });
                }
              },
              child: const Text("Next"),
            ),
            ElevatedButton(
              onPressed: submitTest,
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}

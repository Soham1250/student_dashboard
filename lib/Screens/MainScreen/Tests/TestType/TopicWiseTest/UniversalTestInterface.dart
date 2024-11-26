import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:async'; // For Timer
// import 'dart:convert'; // For JSON parsing
import '../../../../../api/api_service.dart';
import '../../../../../api/endpoints.dart';

class UniversalTestInterface extends StatefulWidget {
  @override
  _UniversalTestInterfaceState createState() => _UniversalTestInterfaceState();
}

class _UniversalTestInterfaceState extends State<UniversalTestInterface>
    with SingleTickerProviderStateMixin {
  late List<Map<String, dynamic>> questions;
  bool isLoading = true;
  int currentQuestionIndex = 0;
  late int totalTime;
  late Timer timer;
  int remainingTime = 0;
  bool isSidebarVisible = true; // Control sidebar visibility

  late String username;
  late String testType;
  final ApiService _apiService = ApiService();

  // Animation controller for sidebar
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    questions = [];

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final Map<String, String> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    username = args['username'] ?? "Unknown";
    testType = args['testType'] ?? "Unknown";

    totalTime = testType == "Full-length" ? 180 * 60 : 40 * 60;
    remainingTime = totalTime;

    fetchQuestions();
    startTimer();
  }

  // Fetch questions from the API
  Future<void> fetchQuestions() async {
    try {
      final response = await _apiService
          .postRequest(addQuestionPaperEndpoint, {"testType": testType});

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

  // Toggle sidebar visibility
  void toggleSidebar() {
    setState(() {
      isSidebarVisible = !isSidebarVisible;
      if (isSidebarVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sidebarWidth = size.width * 0.7; // 70% of screen width

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
          : SafeArea(
              child: Stack(
                children: [
                  // Main question area
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: 16.0,
                        right: isSidebarVisible ? sidebarWidth + 13.0 : 13.0,
                        top: 16.0,
                        bottom: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Question ${currentQuestionIndex + 1}:",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Html(
                            data: questions[currentQuestionIndex]['question'],
                            style: {
                              "body": Style(
                                fontSize: FontSize(16.0),
                                margin: Margins.zero,
                                // padding: EdgeInsets.zero,
                              ),
                            },
                          ),
                          const SizedBox(height: 20),
                          ...questions[currentQuestionIndex]['options']
                              .map<Widget>((option) {
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                leading: Radio<String>(
                                  value: option,
                                  groupValue: questions[currentQuestionIndex]
                                      ['userAnswer'],
                                  onChanged: selectAnswer,
                                ),
                                title: Html(
                                  data: option,
                                  style: {
                                    "body": Style(
                                      fontSize: FontSize(14.0),
                                      margin: Margins.zero,
                                      // padding: EdgeInsets.zero,
                                    ),
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),

                  // Animated sidebar
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          size.width * (1 - _animation.value),
                          0,
                        ),
                        child: child,
                      );
                    },
                    child: Container(
                      width: sidebarWidth,
                      height: double.infinity,
                      color: Colors.grey[200]!.withOpacity(0.95),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Questions',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isSidebarVisible
                                        ? Icons.chevron_right
                                        : Icons.chevron_left,
                                  ),
                                  onPressed: toggleSidebar,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.all(8.0),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                childAspectRatio: 1.0,
                                crossAxisSpacing: 4.0,
                                mainAxisSpacing: 4.0,
                              ),
                              itemCount: questions.length,
                              itemBuilder: (context, index) {
                                Color buttonColor;

                                if (questions[index]['markedForReview'] ==
                                    true) {
                                  buttonColor =
                                      questions[index]['userAnswer'] != null
                                          ? Colors.orange
                                          : Colors.purple;
                                } else {
                                  buttonColor =
                                      questions[index]['userAnswer'] != null
                                          ? Colors.green
                                          : Colors.red;
                                }

                                return ElevatedButton(
                                  onPressed: () => navigateToQuestion(index),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: buttonColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const Divider(height: 1, color: Colors.grey),
                          Container(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Question Status',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildLegendItem(Colors.red, 'Not Attempted'),
                                _buildLegendItem(Colors.green, 'Answered'),
                                _buildLegendItem(
                                    Colors.purple, 'Marked for Review'),
                                _buildLegendItem(Colors.orange,
                                    'Marked for Review (Answered)'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Toggle button for smaller screens
                  Positioned(
                    right: 0,
                    top: size.height * 0.5,
                    child: AnimatedOpacity(
                      opacity: isSidebarVisible ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.chevron_left),
                          onPressed: toggleSidebar,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: 8.0,
            children: [
              ElevatedButton.icon(
                onPressed: toggleMarkForReview,
                icon: Icon(Icons.bookmark_border),
                label: Text("Review"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                ),
              ),
              ElevatedButton.icon(
                onPressed: currentQuestionIndex > 0
                    ? () => setState(() => currentQuestionIndex--)
                    : null,
                icon: Icon(Icons.arrow_back),
                label: Text("Prev"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                ),
              ),
              ElevatedButton.icon(
                onPressed: currentQuestionIndex < questions.length - 1
                    ? () => setState(() => currentQuestionIndex++)
                    : null,
                icon: Icon(Icons.arrow_forward),
                label: Text("Next"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                ),
              ),
              ElevatedButton.icon(
                onPressed: submitTest,
                icon: Icon(Icons.check_circle_outline),
                label: Text("Submit"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

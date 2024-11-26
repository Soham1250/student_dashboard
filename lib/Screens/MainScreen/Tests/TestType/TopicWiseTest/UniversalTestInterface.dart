import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:async'; // For Timer
import 'dart:math'; // For min/max functions
import '../../../../../api/api_service.dart';
import '../../../../../api/endpoints.dart';

class UniversalTestInterface extends StatefulWidget {
  @override
  _UniversalTestInterfaceState createState() => _UniversalTestInterfaceState();
}

class _UniversalTestInterfaceState extends State<UniversalTestInterface>
    with SingleTickerProviderStateMixin {
  final _apiService = ApiService();
  List<Map<String, dynamic>> questions = [];
  bool isLoading = true;
  bool _hasInitialized = false; // Add flag to track initialization
  String username = "";
  String testType = "";
  String? testId; // Add testId to track the current test
  int currentQuestionIndex = 0;
  DateTime? currentQuestionStartTime;
  late Timer timer;
  int totalTime = 0;
  int remainingTime = 0;
  bool isSidebarVisible = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    currentQuestionStartTime = DateTime.now();

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

    if (!isSidebarVisible) {
      _animationController.reverse();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only initialize once
    if (!_hasInitialized) {
      final Map<String, String> args =
          ModalRoute.of(context)!.settings.arguments as Map<String, String>;
      username = args['username'] ?? "Unknown";
      testType = args['testType'] ?? "Unknown";

      totalTime = testType == "Full-length" ? 180 * 60 : 40 * 60;
      remainingTime = totalTime;

      fetchQuestions();
      startTimer();
      _hasInitialized = true;
    }
  }

  // Fetch questions from the API
  Future<void> fetchQuestions() async {
    try {
      final response = await _apiService
          .postRequest(addQuestionPaperEndpoint, {"testType": testType});

      if (response['addedQuestions'] == null) {
        throw Exception('No questions received from API');
      }

      setState(() {
        questions = List<Map<String, dynamic>>.from(
          (response['addedQuestions'] as List).asMap().entries.map((entry) => {
                'index': entry.key,
                'question': entry.value['Question'] as String,
                'options': <String>[
                  entry.value['OptionA'] as String,
                  entry.value['OptionB'] as String,
                  entry.value['OptionC'] as String,
                  entry.value['OptionD'] as String,
                ],
                'correctAnswer': entry.value['CorrectOption'] as String,
                'userAnswer': null,
                'markedForReview': false,
                'answerHistory': <String>[],
                'confidence': 100.0,
                'timeSpent': 0,
              }),
        );
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching questions: $e");
      setState(() {
        isLoading = false;
      });
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text("Failed to load test questions: $e"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Return to previous screen
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
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
      
      // Update confidence after marking for review
      updateConfidence();
    });
  }

  // Select an answer
  void selectAnswer(String? selectedAnswer) {
    if (selectedAnswer != null) {
      setState(() {
        // Update time spent
        if (currentQuestionStartTime != null) {
          final timeSpent =
              DateTime.now().difference(currentQuestionStartTime!).inSeconds;
          questions[currentQuestionIndex]['timeSpent'] =
              (questions[currentQuestionIndex]['timeSpent'] as int) + timeSpent;
        }
        currentQuestionStartTime = DateTime.now();

        // Update answer and history
        questions[currentQuestionIndex]['userAnswer'] = selectedAnswer;
        (questions[currentQuestionIndex]['answerHistory'] as List<String>)
            .add(selectedAnswer);
        
        // Update confidence after answer selection
        updateConfidence();
      });
    }
  }

  // Navigate to specific question
  void navigateToQuestion(int index) {
    // Calculate time spent on current question
    if (currentQuestionStartTime != null) {
      final timeSpent =
          DateTime.now().difference(currentQuestionStartTime!).inSeconds;
      questions[currentQuestionIndex]['timeSpent'] =
          (questions[currentQuestionIndex]['timeSpent'] as int) + timeSpent;
    }

    setState(() {
      currentQuestionIndex = index;
      currentQuestionStartTime = DateTime.now();
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

  // Helper function to convert HTML to plain text
  String convertHtmlToPlainText(String? htmlString) {
    if (htmlString == null) return '';
    
    // Remove HTML tags
    String plainText = htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // Decode HTML entities
    plainText = plainText
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    
    // Remove extra whitespace
    plainText = plainText.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return plainText;
  }

  // Final submission
  void _finalSubmit() {
    // Calculate time for last question
    if (currentQuestionStartTime != null) {
      final timeSpent =
          DateTime.now().difference(currentQuestionStartTime!).inSeconds;
      questions[currentQuestionIndex]['timeSpent'] =
          (questions[currentQuestionIndex]['timeSpent'] as int) + timeSpent;
    }

    // Sort questions by original index
    final sortedQuestions = List<Map<String, dynamic>>.from(questions)
      ..sort((a, b) => (a['index'] as int).compareTo(b['index'] as int));

    // Process questions for analysis
    final processedQuestions = sortedQuestions.map((q) {
      final plainUserAnswer = convertHtmlToPlainText(q['userAnswer'] as String?);
      final plainCorrectAnswer = convertHtmlToPlainText(q['correctAnswer'] as String);
      final plainOptions = (q['options'] as List<dynamic>)
          .map((option) => convertHtmlToPlainText(option.toString()))
          .toList();
      
      final isCorrect = plainUserAnswer != null && 
                       plainUserAnswer.isNotEmpty && 
                       plainUserAnswer == plainCorrectAnswer;

      return {
        'index': q['index'] as int,
        'question': convertHtmlToPlainText(q['question'] as String),
        'options': plainOptions,
        'userAnswer': plainUserAnswer,
        'correctAnswer': plainCorrectAnswer,
        'markedForReview': q['markedForReview'] as bool,
        'timeSpent': q['timeSpent'] as int,
        'confidence': q['confidence'] as double,
        'answerHistory': (q['answerHistory'] as List<String>)
            .map((answer) => convertHtmlToPlainText(answer))
            .toList(),
        'isCorrect': isCorrect,
      };
    }).toList();

    // Prepare analysis data locally
    final Map<String, dynamic> analysisData = {
      'correctAnswers': <Map<String, dynamic>>[],
      'incorrectAnswers': <Map<String, dynamic>>[],
      'markedReviewUnanswered': <Map<String, dynamic>>[],
      'markedReviewAnswered': <Map<String, dynamic>>[],
      'timeAnalysis': {
        'perQuestion': <int, int>{},
        'totalTime': totalTime - remainingTime,
      },
      'confidenceAnalysis': <int, double>{},
    };

    // Categorize questions
    for (var question in processedQuestions) {
      final originalIndex = question['index'] as int;
      
      if (question['markedForReview'] as bool) {
        if (question['userAnswer'] == null || (question['userAnswer'] as String).isEmpty) {
          analysisData['markedReviewUnanswered'].add(question);
        } else {
          analysisData['markedReviewAnswered'].add(question);
          if (question['isCorrect'] as bool) {
            analysisData['correctAnswers'].add(question);
          } else {
            analysisData['incorrectAnswers'].add(question);
          }
        }
      } else if (question['userAnswer'] != null && (question['userAnswer'] as String).isNotEmpty) {
        if (question['isCorrect'] as bool) {
          analysisData['correctAnswers'].add(question);
        } else {
          analysisData['incorrectAnswers'].add(question);
        }
      } else {
        analysisData['incorrectAnswers'].add(question);
      }

      // Record time and confidence
      analysisData['timeAnalysis']['perQuestion'][originalIndex] = question['timeSpent'] as int;
      analysisData['confidenceAnalysis'][originalIndex] = question['confidence'] as double;
    }

    // Navigate to analysis screen with local analysis data
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/testAnalysis',
      (route) => false, // Clear the entire stack
      arguments: {
        'analysisData': analysisData,
        'username': username,
        'testType': testType,
        'questions': processedQuestions,
      },
    );
  }

  // Calculate confidence based on time spent, answer changes, and review status
  double calculateConfidence(Map<String, dynamic> question) {
    double confidence = 100.0; // Start with 100%

    // Time factor: Reduce confidence if took too long
    int timeSpent = question['timeSpent'] as int;
    if (timeSpent > 120) { // If more than 2 minutes
      confidence -= min((timeSpent - 120) / 6, 30.0); // Reduce up to 30%
    }

    // Answer changes factor: Each change reduces confidence
    List<String> answerHistory = question['answerHistory'] as List<String>;
    if (answerHistory.length > 1) {
      confidence -= min(answerHistory.length * 10, 40.0); // Reduce 10% per change, up to 40%
    }

    // Marked for review factor: Reduce confidence if marked
    if (question['markedForReview'] as bool) {
      confidence -= 20.0; // Reduce by 20%
    }

    return max(confidence, 0.0); // Ensure confidence doesn't go below 0
  }

  // Update confidence for current question
  void updateConfidence() {
    if (currentQuestionIndex >= 0 && currentQuestionIndex < questions.length) {
      setState(() {
        questions[currentQuestionIndex]['confidence'] = 
            calculateConfidence(questions[currentQuestionIndex]);
      });
    }
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
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
            : Stack(
                children: [
                  // Main content area
                  _buildMainContent(),

                  // Animated Sidebar
                  if (isSidebarVisible)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return ClipRect(
                            child: SizeTransition(
                              sizeFactor: _animation,
                              axis: Axis.horizontal,
                              child: Container(
                                width: 280,
                                color: Colors.white,
                                child: _buildSidebar(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // Hamburger menu button
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            isSidebarVisible ? Icons.close : Icons.menu,
                            color: Colors.white,
                            size: 28,
                          ),
                          padding: const EdgeInsets.all(12),
                          onPressed: () {
                            setState(() {
                              isSidebarVisible = !isSidebarVisible;
                              if (isSidebarVisible) {
                                _animationController.forward();
                              } else {
                                _animationController.reverse();
                              }
                            });
                          },
                          tooltip: isSidebarVisible
                              ? 'Close sidebar'
                              : 'Open sidebar',
                        ),
                      ),
                    ),
                  ),
                ],
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
                  icon: const Icon(Icons.bookmark_border),
                  label: const Text("Review"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: currentQuestionIndex > 0
                      ? () => navigateToQuestion(currentQuestionIndex - 1)
                      : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Prev"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: currentQuestionIndex < questions.length - 1
                      ? () => navigateToQuestion(currentQuestionIndex + 1)
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text("Next"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: submitTest,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("Submit"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    // First, check if sidebar is open
    if (isSidebarVisible) {
      setState(() {
        isSidebarVisible = false;
        _animationController.reverse();
      });
      return false;
    }

    // Show confirmation dialog
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Exit Test?'),
              content: const Text(
                'Are you sure you want to exit the test? Your progress will be lost.',
                style: TextStyle(fontSize: 16),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  // ignore: sort_child_properties_last
                  child: const Text('EXIT'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            );
          },
        ) ??
        false; // Return false if dialog is dismissed
  }

  Widget _buildSidebar() {
    return Column(
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
                  isSidebarVisible ? Icons.chevron_right : Icons.chevron_left,
                ),
                onPressed: toggleSidebar,
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.0,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              Color buttonColor;

              if (questions[index]['markedForReview'] as bool) {
                buttonColor = questions[index]['userAnswer'] != null
                    ? Colors.orange
                    : Colors.purple;
              } else {
                buttonColor = questions[index]['userAnswer'] != null
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
              _buildLegendItem(Colors.purple, 'Marked for Review'),
              _buildLegendItem(Colors.orange, 'Marked for Review (Answered)'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 16.0,
        right: isSidebarVisible ? 280 + 13.0 : 13.0,
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
            data: questions[currentQuestionIndex]['question'] as String,
            style: {
              "body": Style(
                fontSize: FontSize(16.0),
                margin: Margins.zero,
                // padding: EdgeInsets.zero,
              ),
            },
          ),
          const SizedBox(height: 20),
          ...(questions[currentQuestionIndex]['options'] as List<String>)
              .asMap()
              .entries
              .map((entry) {
            final int idx = entry.key;
            final String option = entry.value;
            final String optionLabel =
                String.fromCharCode(65 + idx); // A, B, C, D

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                leading: Radio<String>(
                  value: optionLabel,
                  groupValue: questions[currentQuestionIndex]['userAnswer'],
                  onChanged: selectAnswer,
                ),
                title: Html(
                  data: option,
                  style: {
                    "body": Style(
                      fontSize: FontSize(14.0),
                      margin: Margins.zero,
                    ),
                  },
                ),
              ),
            );
          }).toList(),
        ],
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

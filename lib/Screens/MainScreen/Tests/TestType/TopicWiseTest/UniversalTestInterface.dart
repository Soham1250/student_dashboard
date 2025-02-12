import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:async';
import 'dart:math';
import '../../../../../api/api_service.dart';
import '../../../../../api/endpoints.dart';
import '../../TestAnalysis/universal_test_analysis.dart';

class ContentSegment {
  final String content;
  final bool isLatex;
  final bool isMathText;

  ContentSegment(this.content, this.isLatex, {this.isMathText = false});
}

class MixedContentParser {
  // Regex to match the entire span and capture the LaTeX content
  static final RegExp _latexSpanRegex = RegExp(
      r'<span[^>]*?class="ql-formula"[^>]*?data-value="([^"]*)"[^>]*?>.*?</span>',
      multiLine: true,
      dotAll: true);
  static final RegExp _mathTextRegex = RegExp(r'^[\s\d+\-=×÷*/.()]+$');
  static final RegExp _multipleWhitespaceRegex = RegExp(r'\s+');

  static bool _isOnlyMathText(String text) {
    return _mathTextRegex.hasMatch(text);
  }

  static String _normalizeWhitespace(String text) {
    return text.replaceAll(_multipleWhitespaceRegex, ' ').trim();
  }

  static List<ContentSegment> parseContent(String content) {
    final List<ContentSegment> segments = [];
    int lastIndex = 0;

    // Replace LaTeX spans with placeholders and collect LaTeX content
    final matches = _latexSpanRegex.allMatches(content).toList();
    String processedContent = content;

    // Process matches in reverse order to not affect positions of earlier matches
    for (int i = matches.length - 1; i >= 0; i--) {
      final match = matches[i];
      final latexContent = match.group(1);
      if (latexContent != null && latexContent.isNotEmpty) {
        // Remove the span from the HTML content
        processedContent =
            processedContent.replaceRange(match.start, match.end, '');
      }
    }

    // Now process the remaining HTML content
    if (processedContent.isNotEmpty) {
      final normalizedText = _normalizeWhitespace(processedContent);
      if (normalizedText.isNotEmpty && !_isOnlyMathText(normalizedText)) {
        segments.add(ContentSegment(normalizedText, false));
      }
    }

    // Add LaTeX segments in their original order
    for (final match in matches) {
      final latexContent = match.group(1);
      if (latexContent != null && latexContent.isNotEmpty) {
        segments.add(ContentSegment(latexContent, true));
      }
    }

    return segments;
  }

  static String sanitizeLatex(String latex) {
    return latex
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(r'\(', r'\left(')
        .replaceAll(r'\)', r'\right)')
        .replaceAll(r'\begin{matrix}', r'\begin{matrix}')
        .replaceAll(r'\end{matrix}', r'\end{matrix}');
  }
}

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
  // ignore: non_constant_identifier_names
  int UserID = 1;
  String? testId; // Add testId to track the current test
  int currentQuestionIndex = 0;
  DateTime? currentQuestionStartTime;
  late Timer timer;
  int totalTime = 0;
  int remainingTime = 0;
  bool isSidebarVisible = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final Color sidebarBackgroundColor =
      Color(0xFFFCE4EC); // Light pink background

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
      final response = await _apiService.postRequest(
          addQuestionPaperEndpoint, {"testType": testType, "UserID": UserID});

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
      setState(() {
        isLoading = false;
      });
      // Show error dialog
      showDialog(
        // ignore: use_build_context_synchronously
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
    // Calculate final statistics
    int correctCount = 0;
    int incorrectCount = 0;
    int unattemptedCount = 0;
    Map<String, Map<String, int>> subjectWiseBreakdown = {};

    for (var question in questions) {
      if (question['userAnswer'] == null) {
        unattemptedCount++;
      } else if (question['userAnswer'] == question['correctAnswer']) {
        correctCount++;
      } else {
        incorrectCount++;
      }

      // Track subject-wise performance if subject information is available
      final subject = question['subject'] as String? ?? 'General';
      if (!subjectWiseBreakdown.containsKey(subject)) {
        subjectWiseBreakdown[subject] = {
          'correct': 0,
          'incorrect': 0,
          'unattempted': 0,
        };
      }

      if (question['userAnswer'] == null) {
        subjectWiseBreakdown[subject]!['unattempted'] =
            (subjectWiseBreakdown[subject]!['unattempted'] ?? 0) + 1;
      } else if (question['userAnswer'] == question['correctAnswer']) {
        subjectWiseBreakdown[subject]!['correct'] =
            (subjectWiseBreakdown[subject]!['correct'] ?? 0) + 1;
      } else {
        subjectWiseBreakdown[subject]!['incorrect'] =
            (subjectWiseBreakdown[subject]!['incorrect'] ?? 0) + 1;
      }
    }

    // Prepare test data for analysis
    final testData = {
      'questions': questions
          .map((q) => {
                ...q,
                'isCorrect': q['userAnswer'] == q['correctAnswer'],
                'timeSpent': q['timeSpent'] ?? 0,
              })
          .toList(),
      'subjectWiseBreakdown': subjectWiseBreakdown,
      'totalTime': totalTime,
      'timeSpent': totalTime - remainingTime,
      'statistics': {
        'correct': correctCount,
        'incorrect': incorrectCount,
        'unattempted': unattemptedCount,
      }
    };

    // Navigate to the analysis screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UniversalTestAnalysis(
          testData: testData,
          username: username,
          testType: testType,
        ),
      ),
    );
  }

  // Calculate confidence based on time spent, answer changes, and review status
  double calculateConfidence(Map<String, dynamic> question) {
    double confidence = 100.0; // Start with 100%

    // Time factor: Reduce confidence if took too long
    int timeSpent = question['timeSpent'] as int;
    if (timeSpent > 120) {
      // If more than 2 minutes
      confidence -= min((timeSpent - 120) / 6, 30.0); // Reduce up to 30%
    }

    // Answer changes factor: Each change reduces confidence
    List<String> answerHistory = question['answerHistory'] as List<String>;
    if (answerHistory.length > 1) {
      confidence -= min(
          answerHistory.length * 10, 40.0); // Reduce 10% per change, up to 40%
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
    // Replace WillPopScope with PopScope
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }

        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Exit Test?'),
              content: const Text(
                  'Are you sure you want to exit the test? Your progress will be lost.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    Navigator.of(context).pop(); // Return to previous screen
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        );

        if (shouldPop ?? false) {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        }
      },
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
                  // Background container
                  Container(
                    color: sidebarBackgroundColor,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  ),
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
                                color: sidebarBackgroundColor,
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
                          onPressed: toggleSidebar,
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

  Widget _buildTeXView(String content) {
    final segments = MixedContentParser.parseContent(content);

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        children: segments.map((segment) {
          if (segment.isLatex) {
            try {
              final sanitizedLatex =
                  MixedContentParser.sanitizeLatex(segment.content);
              return WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: Transform.translate(
                  offset: const Offset(0, 2),
                  child: Math.tex(
                    sanitizedLatex,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    mathStyle: sanitizedLatex.contains(r'\begin{bmatrix}') ||
                            sanitizedLatex.contains(r'\[') ||
                            sanitizedLatex.contains(r'\]')
                        ? MathStyle.display
                        : MathStyle.text,
                    onErrorFallback: (error) {
                      debugPrint(
                          'LaTeX Error: $error for content: $sanitizedLatex');
                      return const SizedBox
                          .shrink(); // Return empty widget on error instead of raw text
                    },
                  ),
                ),
              );
            } catch (e) {
              debugPrint('LaTeX Exception: $e for content: ${segment.content}');
              return const WidgetSpan(
                  child: SizedBox.shrink()); // Return empty widget on exception
            }
          } else {
            return WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: Html(
                data: segment.content,
                style: {
                  "body": Style(
                    fontSize: FontSize(16),
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                    lineHeight: LineHeight.normal,
                  ),
                },
              ),
            );
          }
        }).toList(),
      ),
      softWrap: true,
      textAlign: TextAlign.left,
    );
  }

  Widget _buildSidebar() {
    return Container(
      color: sidebarBackgroundColor,
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: sidebarBackgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Questions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isSidebarVisible ? Icons.chevron_right : Icons.chevron_left,
                    color: Colors.black87,
                  ),
                  onPressed: toggleSidebar,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: sidebarBackgroundColor,
              child: GridView.builder(
                padding: const EdgeInsets.all(12.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
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
                      elevation: 3,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            color: sidebarBackgroundColor,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Question Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildLegendItem(Colors.red, 'Not Attempted'),
                _buildLegendItem(Colors.green, 'Answered'),
                _buildLegendItem(Colors.purple, 'Marked for Review'),
                _buildLegendItem(Colors.orange, 'Marked for Review (Answered)'),
              ],
            ),
          ),
        ],
      ),
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
          _buildTeXView(questions[currentQuestionIndex]['question'] as String),
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
                title: _buildTeXView(option),
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

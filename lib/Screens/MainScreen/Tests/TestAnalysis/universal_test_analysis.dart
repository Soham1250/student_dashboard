import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class UniversalTestAnalysis extends StatefulWidget {
  final Map<String, dynamic> testData;
  final String username;
  final String testType;

  const UniversalTestAnalysis({
    Key? key,
    required this.testData,
    required this.username,
    required this.testType,
  }) : super(key: key);

  @override
  _UniversalTestAnalysisState createState() => _UniversalTestAnalysisState();
}

class _UniversalTestAnalysisState extends State<UniversalTestAnalysis> {
  late Map<String, List<Map<String, dynamic>>> categorizedQuestions;
  late Map<String, dynamic> timeAnalysis;
  late Map<int, double> confidenceAnalysis;
  late int totalQuestions;
  late double averageConfidence;
  late double averageTimePerQuestion;
  late double accuracy;

  @override
  void initState() {
    super.initState();
    _processTestData();
  }

  String convertHtmlToPlainText(String? htmlString) {
    if (htmlString == null) return '';
    return htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  void _processTestData() {
    final questions = widget.testData['questions'] as List<dynamic>;
    totalQuestions = questions.length;

    categorizedQuestions = {
      'correctAnswers': [],
      'incorrectAnswers': [],
      'unansweredQuestions': [],
    };

    timeAnalysis = {
      'perQuestion': <int, int>{},
      'totalTime': widget.testData['timeSpent'] as int,
    };

    confidenceAnalysis = {};
    double totalConfidence = 0;
    int correctQuestionsCount = 0;

    for (var question in questions) {
      final questionData = question as Map<String, dynamic>;
      final index = questionData['index'] as int;
      final userAnswer = questionData['userAnswer'];
      final isCorrect = questionData['isCorrect'] as bool;
      final timeSpent = questionData['timeSpent'] as int;
      final confidence = questionData['confidence'] as double? ?? 0.0;

      // Store original confidence for correct answers, 0 for others
      if (isCorrect && userAnswer != null) {
        confidenceAnalysis[index] = confidence;
        totalConfidence += confidence;
        correctQuestionsCount++;
        questionData['displayConfidence'] = confidence;
      } else {
        confidenceAnalysis[index] = 0.0;
        questionData['displayConfidence'] = 0.0;
      }

      if (userAnswer == null) {
        categorizedQuestions['unansweredQuestions']!.add(questionData);
      } else if (isCorrect) {
        categorizedQuestions['correctAnswers']!.add(questionData);
      } else {
        categorizedQuestions['incorrectAnswers']!.add(questionData);
      }

      timeAnalysis['perQuestion'][index] = timeSpent;
    }

    // Calculate average confidence only from correct answers
    averageConfidence = correctQuestionsCount > 0
        ? totalConfidence / correctQuestionsCount
        : 0.0;
    averageTimePerQuestion = timeAnalysis['totalTime'] / totalQuestions;
    accuracy =
        (categorizedQuestions['correctAnswers']!.length / totalQuestions) * 100;
  }

  String _processLatexContent(String content) {
    // First extract the LaTeX content
    RegExp dataValueRegex = RegExp(r'data-value="([^"]*)"');
    var match = dataValueRegex.firstMatch(content);
    String latexContent = match?.group(1) ?? content;

    // Decode HTML entities
    latexContent = latexContent
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');

    // Process matrices
    if (latexContent.contains('\\begin{matrix}')) {
      latexContent = latexContent
          .replaceAll('amp;', '') // Remove amp;
          .replaceAll(r'\begin{matrix}', r'\begin{bmatrix}')
          .replaceAll(r'\end{matrix}', r'\end{bmatrix}');
    }

    // Handle fractions
    RegExp fractionRegex = RegExp(r'(\d+)/([a-zA-Z])');
    latexContent = latexContent.replaceAllMapped(
      fractionRegex,
      (match) => r'\frac{${match[1]}}{${match[2]}}',
    );

    // Handle subscripts and superscripts
    latexContent = latexContent
        .replaceAll('_', '_{')
        .replaceAll('^', '^{')
        .replaceAllMapped(
          RegExp(r'([_^]){(\w+)}'),
          (match) => '${match[1]}{${match[2]}}',
        );

    return latexContent;
  }

  Widget _buildTeXView(String content) {
    if (content.contains('\$') ||
        content.contains('\\[') ||
        content.contains('\\(') ||
        content.contains('ql-formula')) {
      String latexContent = _processLatexContent(content);

      // Handle display mode for matrices and equations
      if (latexContent.contains(r'\begin{bmatrix}') ||
          latexContent.contains('\\[') ||
          latexContent.contains('\\]')) {
        return Container(
          padding: EdgeInsets.all(8),
          child: Math.tex(
            latexContent,
            textStyle: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            mathStyle: MathStyle.display,
          ),
        );
      }

      // Handle inline mode for simple expressions
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Math.tex(
          latexContent,
          textStyle: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          mathStyle: MathStyle.text,
        ),
      );
    }

    // If no LaTeX, use regular HTML
    return Html(
      data: content,
      style: {
        "body": Style(
          fontSize: FontSize(16),
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
        ),
      },
    );
  }

  Widget _buildStatsRow() {
    final List<Map<String, dynamic>> stats = [
      {
        'title': 'Overall Accuracy',
        'value': '${accuracy.toStringAsFixed(1)}%',
        'icon': Icons.check_circle,
      },
      {
        'title': 'Total Time Spent',
        'value': '${(timeAnalysis['totalTime'] / 60).toStringAsFixed(1)} min',
        'icon': Icons.timer,
      },
      {
        'title': 'Average Confidence',
        'value': '${(averageConfidence).toStringAsFixed(1)}%',
        'icon': Icons.trending_up,
      },
      {
        'title': 'Avg Time/Question',
        'value': '${averageTimePerQuestion.toStringAsFixed(1)} sec',
        'icon': Icons.schedule,
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: stats.map((Map<String, dynamic> stat) {
          return Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  stat['icon'] as IconData,
                  color: Colors.blue.shade400,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  stat['title'] as String,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat['value'] as String,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPerformanceChart() {
    final correct = categorizedQuestions['correctAnswers']!.length.toDouble();
    final incorrect =
        categorizedQuestions['incorrectAnswers']!.length.toDouble();
    final unanswered =
        categorizedQuestions['unansweredQuestions']!.length.toDouble();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Performance Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: Colors.green.shade400,
                    value: correct,
                    title:
                        '${(correct / totalQuestions * 100).toStringAsFixed(1)}%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.red.shade400,
                    value: incorrect,
                    title:
                        '${(incorrect / totalQuestions * 100).toStringAsFixed(1)}%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    color: Colors.grey.shade400,
                    value: unanswered,
                    title:
                        '${(unanswered / totalQuestions * 100).toStringAsFixed(1)}%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.green.shade400, 'Correct'),
              const SizedBox(width: 20),
              _buildLegendItem(Colors.red.shade400, 'Incorrect'),
              const SizedBox(width: 20),
              _buildLegendItem(Colors.grey.shade400, 'Unanswered'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
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
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionList(
      String title, List<Map<String, dynamic>> questions, Color color) {
    if (questions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                title.contains('Correct')
                    ? Icons.check_circle
                    : title.contains('Incorrect')
                        ? Icons.cancel
                        : Icons.help_outline,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 500, // You can adjust this height as needed
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              return Container(
                width: MediaQuery.of(context).size.width * 0.85,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.quiz,
                              color: color,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Question ${index + 1}',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: _buildTeXView(
                                    question['question'] as String ??
                                        'Question text not available'),
                              ),
                              const SizedBox(height: 20),
                              if (question['userAnswer'] != null) ...[
                                Row(
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: Colors.grey.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Your Answer:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: (question['isCorrect'] ?? false)
                                        ? Colors.green.shade50
                                        : Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: (question['isCorrect'] ?? false)
                                          ? Colors.green.shade300
                                          : Colors.red.shade300,
                                    ),
                                  ),
                                  child: _buildTeXView(
                                      question['userAnswer'] as String),
                                ),
                                const SizedBox(height: 20),
                              ],
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 18,
                                    color: Colors.grey.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Correct Answer:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.green.shade300,
                                  ),
                                ),
                                child: _buildTeXView(
                                    question['correctAnswer'] as String),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/main',
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Test Analysis - ${widget.username}'),
          backgroundColor: Colors.teal,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/main',
                (route) => false,
              );
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: _buildStatsRow(),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: _buildPerformanceChart(),
                      ),
                    ),
                    _buildQuestionList(
                      'Correct Questions',
                      categorizedQuestions['correctAnswers']!,
                      Colors.green,
                    ),
                    _buildQuestionList(
                      'Incorrect Questions',
                      categorizedQuestions['incorrectAnswers']!,
                      Colors.red,
                    ),
                    _buildQuestionList(
                      'Unanswered Questions',
                      categorizedQuestions['unansweredQuestions']!,
                      Colors.grey,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/main',
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Back to Main Menu'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

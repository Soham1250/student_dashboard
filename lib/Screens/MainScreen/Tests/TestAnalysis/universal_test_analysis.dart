import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_html/flutter_html.dart';

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
    averageConfidence = correctQuestionsCount > 0 ? totalConfidence / correctQuestionsCount : 0.0;
    averageTimePerQuestion = timeAnalysis['totalTime'] / totalQuestions;
    accuracy = (categorizedQuestions['correctAnswers']!.length / totalQuestions) * 100;
  }

  Widget _buildStatsRow() {
    final stats = [
      {
        'title': 'Overall Accuracy',
        'value': '${accuracy.toStringAsFixed(1)}%',
      },
      {
        'title': 'Total Time Spent',
        'value': '${(timeAnalysis['totalTime'] / 60).toStringAsFixed(1)} min',
      },
      {
        'title': 'Average Confidence',
        'value': '${(averageConfidence).toStringAsFixed(1)}%',
      },
      {
        'title': 'Avg Time/Question',
        'value': '${averageTimePerQuestion.toStringAsFixed(1)} sec',
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: stats.map((stat) {
          return Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.shade700,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stat['title']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  stat['value']!,
                  style: const TextStyle(
                    color: Colors.white,
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
    final incorrect = categorizedQuestions['incorrectAnswers']!.length.toDouble();
    final unanswered = categorizedQuestions['unansweredQuestions']!.length.toDouble();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: correct,
                      title: '${(correct / totalQuestions * 100).toStringAsFixed(1)}%',
                      radius: 60,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: incorrect,
                      title: '${(incorrect / totalQuestions * 100).toStringAsFixed(1)}%',
                      radius: 60,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.grey,
                      value: unanswered,
                      title: '${(unanswered / totalQuestions * 100).toStringAsFixed(1)}%',
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Colors.green, 'Correct'),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.red, 'Incorrect'),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.grey, 'Unanswered'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  Widget _buildQuestionList(String title, List<Map<String, dynamic>> questions, Color color) {
    if (questions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 500,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              return Container(
                width: MediaQuery.of(context).size.width * 0.85,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Question ${question['index'] + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Html(
                                    data: question['question'] as String,
                                    style: {
                                      "body": Style(
                                        fontSize: FontSize(16),
                                        margin: Margins.zero,
                                        padding: HtmlPaddings.zero,
                                      ),
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (question['userAnswer'] != null) ...[
                                  Text(
                                    'Your Answer:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: question['isCorrect'] as bool
                                          ? Colors.green[50]
                                          : Colors.red[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: question['isCorrect'] as bool
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                    child: Text(
                                      convertHtmlToPlainText(question['userAnswer'] as String),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: question['isCorrect'] as bool
                                            ? Colors.green[900]
                                            : Colors.red[900],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                Text(
                                  'Correct Answer:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.green),
                                  ),
                                  child: Text(
                                    convertHtmlToPlainText(question['correctAnswer'] as String),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.green[900],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Time Spent',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          Text(
                                            '${question['timeSpent']} seconds',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Confidence',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          Text(
                                            '${(question['displayConfidence'] as double).toStringAsFixed(1)}%',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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

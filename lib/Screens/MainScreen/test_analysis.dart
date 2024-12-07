import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_html/flutter_html.dart';

class TestAnalysisScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final analysisData = args['analysisData'] as Map<String, dynamic>;
    final username = args['username'] as String;
    final testType = args['testType'] as String;
    final questions = List<Map<String, dynamic>>.from(args['questions'] as List)
      ..sort((a, b) => (a['index'] as int).compareTo(b['index'] as int));

    final correctAnswers =
        analysisData['correctAnswers'] as List<Map<String, dynamic>>;
    final incorrectAnswers =
        analysisData['incorrectAnswers'] as List<Map<String, dynamic>>;
    final markedReviewUnanswered =
        analysisData['markedReviewUnanswered'] as List<Map<String, dynamic>>;
    final markedReviewAnswered =
        analysisData['markedReviewAnswered'] as List<Map<String, dynamic>>;
    final timeAnalysis = analysisData['timeAnalysis'] as Map<String, dynamic>;

    // Calculate statistics
    int totalQuestions = questions.length;
    int totalAnswered = correctAnswers.length + incorrectAnswers.length;
    double accuracy =
        totalAnswered > 0 ? (correctAnswers.length / totalAnswered) * 100 : 0;
    int totalTime = timeAnalysis['totalTime'] as int;
    double avgTimePerQuestion =
        totalQuestions > 0 ? totalTime / totalQuestions : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('$testType Analysis'),
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back arrow
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Performance Overview Cards
                    SizedBox(
                      height: 160,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          _buildStatCard(
                            'Accuracy',
                            '${accuracy.toStringAsFixed(1)}%',
                            Icons.analytics,
                            Colors.blue,
                          ),
                          _buildStatCard(
                            'Correct',
                            '${correctAnswers.length}/$totalAnswered',
                            Icons.check_circle,
                            Colors.green,
                          ),
                          _buildStatCard(
                            'Incorrect',
                            '${incorrectAnswers.length}',
                            Icons.cancel,
                            Colors.red,
                          ),
                          _buildStatCard(
                            'Avg. Time',
                            '${(avgTimePerQuestion / 60).toStringAsFixed(1)} min',
                            Icons.timer,
                            Colors.orange,
                          ),
                        ],
                      ),
                    ),

                    // Performance Chart
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        height: 200,
                        child: Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 0,
                                centerSpaceRadius: 40,
                                sections: [
                                  PieChartSectionData(
                                    color: Colors.green,
                                    value: correctAnswers.length.toDouble(),
                                    title: 'Correct',
                                    radius: 50,
                                    titleStyle: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                  PieChartSectionData(
                                    color: Colors.red,
                                    value: incorrectAnswers.length.toDouble(),
                                    title: 'Incorrect',
                                    radius: 50,
                                    titleStyle: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                  if (markedReviewUnanswered.isNotEmpty)
                                    PieChartSectionData(
                                      color: Colors.grey,
                                      value: markedReviewUnanswered.length
                                          .toDouble(),
                                      title: 'Unanswered',
                                      radius: 50,
                                      titleStyle: TextStyle(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Question Review Section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question Review',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 280,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: questions.length,
                              itemBuilder: (context, index) {
                                final question = questions[index];
                                return _buildQuestionCard(
                                  question,
                                  question['isCorrect'] as bool,
                                  index + 1,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Add bottom padding to prevent overlap with button
                    SizedBox(height: 80),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/main',
                              arguments: {'username': username},
                              (route) => false, // Clear the entire stack
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Back to Dashboard',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      width: 150,
      margin: EdgeInsets.only(right: 16),
      child: Card(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          constraints: BoxConstraints(minHeight: 120),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(
      Map<String, dynamic> question, bool isCorrect, int questionNumber) {
    final options = question['options'] as List<dynamic>;
    final confidence = question['confidence'] as double?;
    final userAnswer = question['userAnswer'] as String?;
    final correctAnswer = question['correctAnswer'] as String;
    final isAnswerCorrect = question['isCorrect'] as bool;

    return Container(
      width: 300,
      margin: EdgeInsets.only(right: 16),
      child: Card(
        elevation: 4,
        color: isAnswerCorrect ? Colors.green[50] : Colors.red[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question $questionNumber',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (question['markedForReview'] as bool)
                    Icon(Icons.bookmark, color: Colors.blue),
                ],
              ),
              Divider(),
              Flexible(
                child: Html(
                  data: question['question'] as String,
                  style: {
                    "body": Style(
                      fontSize: FontSize(16.0),
                      margin: Margins.zero,
                      // padding: EdgeInsets.zero,
                    ),
                  },
                ),
              ),
              SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isUserAnswer = userAnswer == option;
                    final isCorrectAnswer = correctAnswer == option;

                    return Container(
                      margin: EdgeInsets.only(bottom: 4),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isUserAnswer
                            ? (isAnswerCorrect
                                ? Colors.green[100]
                                : Colors.red[100])
                            : isCorrectAnswer
                                ? Colors.green[100]
                                : Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Text(
                            String.fromCharCode(65 + index), // A, B, C, D
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isUserAnswer
                                  ? (isAnswerCorrect
                                      ? Colors.green[900]
                                      : Colors.red[900])
                                  : isCorrectAnswer
                                      ? Colors.green[900]
                                      : Colors.grey[900],
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 12,
                                color: isUserAnswer
                                    ? (isAnswerCorrect
                                        ? Colors.green[900]
                                        : Colors.red[900])
                                    : isCorrectAnswer
                                        ? Colors.green[900]
                                        : Colors.grey[900],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Time: ${((question['timeSpent'] as int)).toStringAsFixed(1)} sec',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (confidence != null)
                    Text(
                      'Confidence: ${isAnswerCorrect ? confidence.toStringAsFixed(0) : 0}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: isAnswerCorrect
                            ? Colors.green[700]
                            : Colors.red[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

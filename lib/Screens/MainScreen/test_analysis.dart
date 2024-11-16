import 'package:flutter/material.dart';

class TestAnalysisScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get arguments passed from TestInterfaceScreen
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final List<Map<String, dynamic>> questions = args['questions'];

    // Calculate statistics
    int totalQuestions = questions.length;
    int correctAnswers = questions.where((q) => q['userAnswer'] == q['correctAnswer']).length;

    double accuracy = (correctAnswers / totalQuestions) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Analysis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Accuracy Score Display
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Accuracy: ${(accuracy).toStringAsFixed(2)}%',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Correct: $correctAnswers / $totalQuestions',
                      style: const TextStyle(fontSize: 18, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // List of Question Cards
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  bool isCorrect = question['userAnswer'] == question['correctAnswer'];

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    color: isCorrect ? Colors.green[50] : Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question Text
                          Text(
                            'Q${index + 1}: ${question['question']}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // User's Answer
                          Text(
                            'Your Answer: ${question['userAnswer'] ?? 'Not Answered'}',
                            style: TextStyle(
                              fontSize: 16,
                              color: isCorrect ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),

                          // Correct Answer
                          if (!isCorrect)
                            Text(
                              'Correct Answer: ${question['correctAnswer']}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
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
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Back to Dashboard'),
        ),
      ),
    );
  }
}

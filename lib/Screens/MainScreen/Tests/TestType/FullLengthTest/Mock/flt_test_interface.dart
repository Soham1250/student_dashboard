import 'package:flutter/material.dart';
import '../../../../test_analysis.dart';

class FltTestInterfaceScreen extends StatefulWidget {
  @override
  _FltTestInterfaceScreen createState() => _FltTestInterfaceScreen();
}

class _FltTestInterfaceScreen extends State<FltTestInterfaceScreen> {
  List<Map<String, dynamic>> questions = [
    {
      'question': 'What is the determinant of the matrix [[2, 3], [1, 4]]?',
      'options': ['5', '7', '8', '6'],
      'correctAnswer': '5',
      'userAnswer': null,
      'markedForReview': false,
    },
    {
      'question': 'Which of the following is an identity matrix?',
      'options': [
        '[[1, 0], [0, 1]]',
        '[[2, 0], [0, 2]]',
        '[[0, 1], [1, 0]]',
        '[[1, 1], [1, 1]]'
      ],
      'correctAnswer': '[[1, 0], [0, 1]]',
      'userAnswer': null,
      'markedForReview': false,
    },
    {
      'question': 'What is the trace of the matrix [[1, 2], [3, 4]]?',
      'options': ['5', '4', '7', '6'],
      'correctAnswer': '5',
      'userAnswer': null,
      'markedForReview': false,
    },
    {
      'question':
          'Matrix A is 2x3 and Matrix B is 3x2. What is the size of the resulting matrix when A is multiplied by B?',
      'options': ['2x2', '2x3', '3x3', '3x2'],
      'correctAnswer': '2x2',
      'userAnswer': null,
      'markedForReview': false,
    },
    {
      'question': 'If A is a 3x3 matrix and det(A) = 4, what is det(2A)?',
      'options': ['32', '16', '8', '64'],
      'correctAnswer': '32',
      'userAnswer': null,
      'markedForReview': false,
    },
    {
      'question': 'Which of the following is a scalar matrix?',
      'options': [
        '[[3, 0], [0, 3]]',
        '[[2, 1], [1, 2]]',
        '[[1, 2], [2, 1]]',
        '[[4, 0], [0, 2]]'
      ],
      'correctAnswer': '[[3, 0], [0, 3]]',
      'userAnswer': null,
      'markedForReview': false,
    },
    {
      'question': 'Which operation is required to invert a matrix?',
      'options': [
        'Multiplication by identity',
        'Matrix multiplication',
        'Matrix determinant',
        'Matrix adjugate'
      ],
      'correctAnswer': 'Matrix adjugate',
      'userAnswer': null,
      'markedForReview': false,
    },
    {
      'question': 'What is the inverse of the matrix [[1, 0], [0, 1]]?',
      'options': [
        '[[1, 0], [0, 1]]',
        '[[0, 1], [1, 0]]',
        '[[1, 1], [1, 1]]',
        'No inverse exists'
      ],
      'correctAnswer': '[[1, 0], [0, 1]]',
      'userAnswer': null,
      'markedForReview': false,
    },
    {
      'question': 'Which matrix is a diagonal matrix?',
      'options': [
        '[[2, 0], [0, 3]]',
        '[[1, 1], [1, 1]]',
        '[[0, 0], [0, 0]]',
        '[[2, 3], [3, 2]]'
      ],
      'correctAnswer': '[[2, 0], [0, 3]]',
      'userAnswer': null,
      'markedForReview': false,
    },
    {
      'question': 'What is the rank of a 3x3 identity matrix?',
      'options': ['3', '1', '0', '2'],
      'correctAnswer': '3',
      'userAnswer': null,
      'markedForReview': false,
    },
  ];

  int currentQuestionIndex = 0;
  int remainingTime = 600; // 10 minutes in seconds

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
        });
        startTimer();
      }
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void toggleMarkForReview() {
    setState(() {
      questions[currentQuestionIndex]['markedForReview'] =
          !questions[currentQuestionIndex]['markedForReview'];
    });
  }

  void selectAnswer(String? selectedAnswer) {
    setState(() {
      questions[currentQuestionIndex]['userAnswer'] = selectedAnswer;
    });
  }

  void navigateToQuestion(int index) {
    setState(() {
      currentQuestionIndex = index;
    });
  }

  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  void submitTest(BuildContext context) {
    // Navigate to the Test Analysis Screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TestAnalysisScreen(),
        settings: RouteSettings(arguments: {'questions': questions}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Topic-wise'),
      ),
      body: Row(
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
                    'Question ${currentQuestionIndex + 1}:',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentQuestion['question'],
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ...currentQuestion['options'].map<Widget>((option) {
                    return ListTile(
                      leading: Radio<String>(
                        value: option,
                        groupValue: currentQuestion['userAnswer'],
                        onChanged: selectAnswer,
                      ),
                      title: Text(option),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          // Sidebar with timer and navigation
          Container(
            width: 250,
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Time Left',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        formatTime(remainingTime),
                        style: const TextStyle(fontSize: 24, color: Colors.red),
                      ),
                    ],
                  ),
                ),
                const Divider(),
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
                        child: Text('${index + 1}',
                            style: const TextStyle(color: Colors.white)),
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
            // Mark for Review Button
            ElevatedButton(
              onPressed: toggleMarkForReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Blue background
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                questions[currentQuestionIndex]['markedForReview']
                    ? 'Unmark'
                    : 'Mark for Review',
                style: const TextStyle(
                  color: Colors.white, // White text
                  fontWeight: FontWeight.bold, // Bold text
                ),
              ),
            ),

            // Previous Button
            ElevatedButton(
              onPressed: previousQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Blue background
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Previous',
                style: TextStyle(
                  color: Colors.white, // White text
                  fontWeight: FontWeight.bold, // Bold text
                ),
              ),
            ),

            // Next Button
            ElevatedButton(
              onPressed: nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Blue background
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Next',
                style: TextStyle(
                  color: Colors.white, // White text
                  fontWeight: FontWeight.bold, // Bold text
                ),
              ),
            ),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                submitTest(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Blue background
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(
                  color: Colors.white, // White text
                  fontWeight: FontWeight.bold, // Bold text
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class TopicWiseTestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, String> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final String username = args?['username'] ?? 'Unknown';
    final String testType = args?['testType'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Topic-Wise Test'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Greeting and Test Type
            Text(
              'Hello, $username\nTest Type: $testType',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),

            // Subject Cards Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _buildSubjectCard(
                      context,
                      'Physics',
                      'assets/images/physics.png',
                      '/physicsTopics',
                      username,
                      testType,
                      'physics'),
                  _buildSubjectCard(
                      context,
                      'Mathematics',
                      'assets/images/maths.png',
                      '/mathTopics',
                      username,
                      testType,
                      'mathematics'),
                  _buildSubjectCard(
                      context,
                      'Chemistry',
                      'assets/images/chemistry.png',
                      '/chemistryTopics',
                      username,
                      testType,
                      'chemistry'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create subject cards with icon and text
  Widget _buildSubjectCard(
      BuildContext context,
      String subject,
      String imagePath,
      String route,
      String username,
      String testType,
      String subjectId) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          route,
          arguments: {
            'username': username,
            'testType': testType,
            'subjectId': subjectId,
          },
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        backgroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: 80,
            width: 80,
          ),
          const SizedBox(height: 10),
          Text(
            subject,
            style: const TextStyle(
                fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

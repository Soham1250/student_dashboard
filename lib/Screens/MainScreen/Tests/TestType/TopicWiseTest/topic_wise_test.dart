import 'package:flutter/material.dart';

class TopicWiseTestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, String> args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final String username = args['username']!;
    final String testType = args['testType']!;

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
                  _buildSubjectCard(context, 'Physics', Icons.science, '/physicsTopics', username, testType, 'physics'),
                  _buildSubjectCard(context, 'Mathematics', Icons.calculate, '/mathTopics', username, testType, 'mathematics'),
                  _buildSubjectCard(context, 'Chemistry', Icons.biotech, '/chemistryTopics', username, testType, 'chemistry'),
                  _buildSubjectCard(context, 'Biology', Icons.eco, '/biologyTopics', username, testType, 'biology'),
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
      BuildContext context, String subject, IconData icon, String route, String username, String testType, String subjectId) {
    return GestureDetector(
      onTap: () {
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              subject,
              style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

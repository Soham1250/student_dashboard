import 'package:flutter/material.dart';

class SubjectWiseTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
    final String username = args?['username'] ?? 'Unknown';
    final String testType = args?['testType'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subject-Wise Test'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Hello, $username\nTest Type: $testType',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildSubjectCard(context, 'Physics', Icons.science, '/selectSubjectWiseDifficulty', username, testType, 'physics'),
                  _buildSubjectCard(context, 'Mathematics', Icons.calculate, '/selectSubjectWiseDifficulty', username, testType, 'mathematics'),
                  _buildSubjectCard(context, 'Chemistry', Icons.biotech, '/selectSubjectWiseDifficulty', username, testType, 'chemistry'),
                  _buildSubjectCard(context, 'Biology', Icons.eco, '/selectSubjectWiseDifficulty', username, testType, 'biology'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, String subject, IconData icon, String route, String username, String testType, String subjectId) {
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
      child: Card(
        color: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              subject,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

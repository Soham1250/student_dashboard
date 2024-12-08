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
                  _buildSubjectCard(context, 'Physics', 'assets/images/physics.png', '/selectSubjectWiseDifficulty', username, testType, 'physics'),
                  _buildSubjectCard(context, 'Mathematics', 'assets/images/maths.png', '/selectSubjectWiseDifficulty', username, testType, 'mathematics'),
                  _buildSubjectCard(context, 'Chemistry', 'assets/images/chemistry.png', '/selectSubjectWiseDifficulty', username, testType, 'chemistry'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, String subject, String imagePath, String route, String username, String testType, String subjectId) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          route,
          arguments: {
            'username': username,
            'testType': testType,
            'subject': subjectId,
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
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

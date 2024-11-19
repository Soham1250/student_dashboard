import 'package:flutter/material.dart';

class TestSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Retrieve the username parameter
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
    final String username = args?["username"] ?? "Unknown";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Test Selection',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch buttons to fill width
          children: [
            Text(
              'Welcome, $username',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Button for Topic-Wise Test
            _buildTestSelectionButton(
              label: 'Topic-Wise Test',
              context: context,
              route: '/topicWiseTest',
              username: username,
              testType: 'topic-wise',
            ),
            const SizedBox(height: 20), // Space between buttons

            // Button for Subject-Wise Test
            _buildTestSelectionButton(
              label: 'Subject-Wise Test',
              context: context,
              route: '/subjectWise',
              username: username,
              testType: 'subject-wise',
            ),
            const SizedBox(height: 20),

            // Button for Full Syllabus Test
            _buildTestSelectionButton(
              label: 'Full Syllabus Test',
              context: context,
              route: '/fullSyllabus',
              username: username,
              testType: 'Full-length',
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create test selection buttons
  Widget _buildTestSelectionButton({
    required String label,
    required BuildContext context,
    required String route,
    required String username,
    required String testType,
  }) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          route,
          arguments: {
            'username': username,
            'testType': testType,
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(vertical: 20), // Button height
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

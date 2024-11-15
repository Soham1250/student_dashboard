import 'package:flutter/material.dart';

class LearnScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
    final String username = args?['username'] ?? 'Unknown';
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'What would you like to learn today?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 30),

            const Text(
              'Select Subject',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _buildSubjectButton(context, '/learnsubject', Icons.science, screenWidth, username, 'physics'),
                  _buildSubjectButton(context, '/learnsubject', Icons.biotech, screenWidth, username, 'chemistry'),
                  _buildSubjectButton(context, '/learnsubject', Icons.calculate, screenWidth, username, 'mathematics'),
                  _buildSubjectButton(context, '/learnsubject', Icons.eco, screenWidth, username, 'biology'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectButton(
    BuildContext context,
    String route,
    IconData icon,
    double screenWidth,
    String username,
    String subjectID,
  ) {
    return SizedBox(
      width: screenWidth * 0.4,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, route, arguments: {
            'username': username,
            'subjectID': subjectID,
          });
        },
        icon: Icon(icon, size: 30, color: Colors.white),
        label: Text(subjectID, style: const TextStyle(color: Colors.white, fontSize: 16)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class LearnScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
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
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 30),
            const Text(
              'Select Subject',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _buildSubjectButton(
                    context,
                    '/learnsubject',
                    'assets/images/physics.png', // Path to the physics image
                    screenWidth,
                    username,
                    'physics',
                    'Physics'
                  ),
                  _buildSubjectButton(
                    context,
                    '/learnsubject',
                    'assets/images/chemistry.png', // Path to the chemistry image
                    screenWidth,
                    username,
                    'chemistry',
                    'Chemistry',
                  ),
                  _buildSubjectButton(
                    context,
                    '/learnsubject',
                    'assets/images/maths.png', // Path to the mathematics image
                    screenWidth,
                    username,
                    'mathematics',
                    'Maths',
                  ),
                  // _buildSubjectButton(
                  //   context,
                  //   '/learnsubject',
                  //   'assets/images/biology.png', // Path to the biology image
                  //   screenWidth,
                  //   username,
                  //   'Biology',
                  // ),
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
    String imagePath, // Path to the image
    double screenWidth,
    String username,
    String subjectID,
    String subject,
  ) {
    return SizedBox(
      width: screenWidth * 0.4,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, route, arguments: {
            'username': username,
            'subjectID': subjectID,
          });
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 100, // Adjust the size as needed
              height: 100,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10),
            Text(
              subject,
              style: const TextStyle(color: Colors.black, fontSize: 16,fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

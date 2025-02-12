import 'package:flutter/material.dart';

class SubjectWiseTest extends StatelessWidget {
  final Map<String, Color> subjectColors = {
    'Physics': Colors.blue.shade400,
    'Mathematics': Colors.orange.shade400,
    'Chemistry': Colors.purple.shade400,
  };

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
    final String username = args?['username'] ?? 'Unknown';
    final String testType = args?['testType'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Subject-Wise Test',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blueAccent,
              Colors.blue.shade50,
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.school,
                        size: 50,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Select Your Subject',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Choose a subject to start your subject-wise test',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
                        '/selectSubjectWiseDifficulty',
                        username,
                        testType,
                        'physics',
                      ),
                      _buildSubjectCard(
                        context,
                        'Mathematics',
                        'assets/images/maths.png',
                        '/selectSubjectWiseDifficulty',
                        username,
                        testType,
                        'mathematics',
                      ),
                      _buildSubjectCard(
                        context,
                        'Chemistry',
                        'assets/images/chemistry.png',
                        '/selectSubjectWiseDifficulty',
                        username,
                        testType,
                        'chemistry',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectCard(
    BuildContext context,
    String subject,
    String imagePath,
    String route,
    String username,
    String testType,
    String subjectId,
  ) {
    final Color subjectColor = subjectColors[subject] ?? Colors.grey;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: subjectColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
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
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: subjectColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                imagePath,
                height: 80,
                width: 80,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              subject,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: subjectColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class StatisticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
    final String username = args?['username'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Hello $username, All the statistics here are based on your test performance.',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Strongest Subject
            _buildStatisticsButton(
              context,
              'Strongest Subject: Physics',
              'You can always improve!',
              Colors.green,
              Icons.check_circle,
              username,
              'strong',
              'physics',
            ),
            const SizedBox(height: 20),

            // Needs Revision
            _buildStatisticsButton(
              context,
              'Needs Revision: Chemistry',
              'Try hard champ!',
              Colors.orange,
              Icons.refresh,
              username,
              'revision',
              'chemistry',
            ),
            const SizedBox(height: 20),

            // Weakest Subject
            _buildStatisticsButton(
              context,
              'Weakest Subject: Mathematics',
              'The start is always difficult.',
              Colors.red,
              Icons.warning,
              username,
              'weak',
              'mathematics',
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create buttons for statistics and pass parameters
  Widget _buildStatisticsButton(
    BuildContext context,
    String title,
    String description,
    Color color,
    IconData icon,
    String username,
    String subjectType,
    String subjectID,
  ) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          '/subjectreview',
          arguments: {
            'username': username,
            'subjectType': subjectType,
            'subjectID': subjectID,
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center horizontally
          crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SelectFLTScreen extends StatelessWidget {
  final Map<String, Color> testColors = {
    'Mock Full Length Test': Colors.orange.shade400,
    'Previous Year MHT CET Test': Colors.purple.shade400,
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
          'Full Length Test',
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
                        Icons.assignment,
                        size: 50,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Full Length Tests',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Choose your test type to begin',
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

                // Test Type Grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    children: [
                      _buildTestTile(
                        label: 'Mock Full Length Test',
                        icon: Icons.quiz,
                        context: context,
                        route: '/testInterface',
                        username: username,
                        testType: testType,
                        flttype: 'mock',
                      ),
                      _buildTestTile(
                        label: 'Previous Year MHT CET Test',
                        icon: Icons.history_edu,
                        context: context,
                        route: '/selectcetyear',
                        username: username,
                        testType: testType,
                        flttype: 'previousYear',
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

  Widget _buildTestTile({
    required String label,
    required IconData icon,
    required BuildContext context,
    required String route,
    required String username,
    required String testType,
    required String flttype,
  }) {
    final Color tileColor = testColors[label] ?? Colors.grey;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: tileColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, route, arguments: {
            'username': username,
            'testType': testType,
            'flttype': flttype,
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: tileColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: tileColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: tileColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

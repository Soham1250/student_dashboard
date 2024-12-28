import 'package:flutter/material.dart';

class SelectFLTScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
    final String username = args?['username'] ?? 'Unknown';
    final String testType = args?['testType'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Full Length Test Selection',
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                shrinkWrap: true,
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
            ],
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
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route, arguments: {
          'username': username,
          'testType': testType,
          'flttype': flttype,
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blueAccent, size: 40),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.blueAccent),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PerformanceScreen extends StatelessWidget {
  final List<String> testList = [
    'Test 1',
    'Test 2',
    'Test 3',
    'Test 4',
    'Test 5',
    'Test 6',
    'Test 7',
    'Test 8',
    'Test 9',
    'Test 10',
    'Test 11',
    'Test 12',
  ]; // Add more test names as required

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
    final String username = args?['username'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Performance So Far...'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Here are your latest 10 test results:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Scrollable ListView to display the tests
            Expanded(
              child: ListView.builder(
                itemCount: testList.length > 10 ? 10 : testList.length, // Limit to 10 tests
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SizedBox(
                      width: double.infinity, // Each button takes the full width
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to detailed analysis with the specific testId
                          Navigator.pushNamed(
                            context,
                            '/detailedanalysis',
                            arguments: {
                              'username': username,
                              'testId': testList[index],
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent, // Match color scheme
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5, // Add shadow for 3D effect
                        ),
                        child: Text(
                          testList[index],
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white, // White text color for readability
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date and time formatting

class NewGrievanceScreen extends StatefulWidget {
  @override
  _NewGrievanceScreenState createState() => _NewGrievanceScreenState();
}

class _NewGrievanceScreenState extends State<NewGrievanceScreen> {
  final TextEditingController _grievanceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
    final String username = args?["username"] ?? 'Unknown';
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit New Grievance', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Let us know what is bothering you',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            Expanded(
              child: TextField(
                controller: _grievanceController,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: 'Describe your grievance here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: screenWidth * 0.4,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('Back', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.4,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_grievanceController.text.isNotEmpty) {
                        String grievanceId = _generateGrievanceId(username);
                        _showGrievanceDialog(grievanceId);
                        _grievanceController.clear();
                      } else {
                        _showErrorDialog();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('Submit', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _generateGrievanceId(String username) {
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyyMMdd').format(now);
    final String formattedTime = DateFormat('HHmmss').format(now);
    return '$formattedDate$formattedTime-$username';
  }

  void _showGrievanceDialog(String grievanceId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("We've got your grievance"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Your Grievance ID is: $grievanceId'),
              const SizedBox(height: 20),
              const Text("We're looking into it, relax."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Please enter your grievance before submitting.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

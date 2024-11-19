import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../../api/endpoints.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _username = "Student"; // Default value while loading

  
  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    try {
      // Call the API using ID 1 for testing purposes
      final response = await ApiService().getRequest('$getStudentByIdEndpoint/1');
      
      if (response != null && response.containsKey('FirstName')) {
        setState(() {
          _username = response['FirstName']; // Extract only FirstName
        });
      } else {
        setState(() {
          _username = 'Student'; // Default value if FirstName is not found
        });
      }
    } catch (error) {
      setState(() {
        _username = 'Student'; // Default in case of error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Dashboard', style: TextStyle(fontSize: 24, color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue[100],
                  child: const Icon(Icons.person, size: 40, color: Colors.blueAccent),
                ),
                const SizedBox(width: 20),
                Text(
                  'Hello, $_username',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _buildGridButton('Tests', Icons.assignment, context, '/testSelection'),
                  _buildGridButton('Performance', Icons.bar_chart, context, '/performance'),
                  _buildGridButton('Statistics', Icons.insert_chart, context, '/statistics'),
                  _buildGridButton('Learn', Icons.school, context, '/learn'),
                  _buildGridButton('Feedback', Icons.feedback, context, '/feedback'),
                  _buildGridButton('Grievances', Icons.report_problem, context, '/grievances'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridButton(String label, IconData icon, BuildContext context, String route) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, route, arguments: {'username': _username});
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

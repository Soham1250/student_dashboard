import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../../api/endpoints.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _username = "Student"; // Default value while loading
  final ApiService _apiService = ApiService(); // Initialize API service

  
  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    try {
      // Call the API using ID 1 for testing purposes
      final response = await _apiService.getRequest(getStudentByIdEndpoint('1'));
      
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
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Container(
        color: Colors.black87, // Dark background color
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.deepPurple[100],
                    child: const Icon(Icons.person, size: 40, color: Colors.deepPurple),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    'Hello, $_username',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  children: [
                    _buildGridButton('Tests', Icons.assignment, context, '/testSelection', Colors.orange),
                    _buildGridButton('Performance', Icons.bar_chart, context, '/performance', Colors.green),
                    _buildGridButton('Statistics', Icons.insert_chart, context, '/statistics', Colors.blue),
                    _buildGridButton('Learn', Icons.school, context, '/learn', Colors.red),
                    _buildGridButton('Feedback', Icons.feedback, context, '/feedback', Colors.purple),
                    _buildGridButton('Grievances', Icons.report_problem, context, '/grievances', Colors.teal),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridButton(String label, IconData icon, BuildContext context, String route, Color color) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, route, arguments: {'username': _username});
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
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

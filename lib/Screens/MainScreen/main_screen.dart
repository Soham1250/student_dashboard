import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../profile_screen.dart';

class MainScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const MainScreen({Key? key, this.userData}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _username = "Student"; // Default value

  @override
  void initState() {
    super.initState();
    _setUsername();
  }

  void _setUsername() {
    if (widget.userData != null) {
      final firstName = widget.userData!['FirstName'] as String?;

      if (firstName != null) {
        setState(() {
          _username = '$firstName ';
        });
      }
    }
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const ProfileScreen(studentId: '1'), // Using ID 1 for testing
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      // ignore: deprecated_member_use
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        // Show exit confirmation dialog
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Do you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  SystemNavigator.pop(); // This will close the app
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        );

        if (shouldExit ?? false) {
          SystemNavigator.pop(); // This will close the app
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Main Dashboard',
              style: TextStyle(fontSize: 24, color: Colors.white)),
          backgroundColor: Colors.deepPurple,
          elevation: 0,
          automaticallyImplyLeading: false, // This removes the back button
        ),
        body: Container(
          color: const Color.fromARGB(221, 40, 8, 26), // Dark background color
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: _navigateToProfile,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.deepPurple[100],
                        child: const Icon(Icons.person,
                            size: 40, color: Colors.deepPurple),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      'Hello, $_username',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
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
                      _buildGridButton('Tests', Icons.assignment, context,
                          '/testSelection', Colors.orange),
                      _buildGridButton('Performance', Icons.bar_chart, context,
                          '/performance', Colors.green),
                      _buildGridButton('Statistics', Icons.insert_chart,
                          context, '/statistics', Colors.blue),
                      _buildGridButton(
                          'Learn', Icons.school, context, '/learn', Colors.red),
                      _buildGridButton('Feedback', Icons.feedback, context,
                          '/feedback', Colors.purple),
                      _buildGridButton('Grievances', Icons.report_problem,
                          context, '/grievance', Colors.teal),
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

  Widget _buildGridButton(String label, IconData icon, BuildContext context,
      String route, Color color) {
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

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
  String _username = "Soham"; // Default value

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
          _username = firstName;
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.deepPurple,
                Colors.deepPurple.shade100,
              ],
              stops: [0.0, 0.3],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Profile Card
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
                    child: Row(
                      children: [
                        InkWell(
                          onTap: _navigateToProfile,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.deepPurple,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.deepPurple.shade50,
                              child: const Icon(
                                Icons.person,
                                size: 35,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome back',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _username,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Grid of Options
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      children: [
                        _buildGridButton('Tests', Icons.assignment, context,
                            '/testSelection', Colors.orange.shade400),
                        _buildGridButton('Performance', Icons.bar_chart, context,
                            '/performance', Colors.green.shade400),
                        _buildGridButton('Statistics', Icons.insert_chart,
                            context, '/statistics', Colors.blue.shade400),
                        _buildGridButton(
                            'Learn', Icons.school, context, '/learn', Colors.red.shade400),
                        _buildGridButton('Feedback', Icons.feedback, context,
                            '/feedback', Colors.purple.shade400),
                        _buildGridButton('Grievances', Icons.report_problem,
                            context, '/grievance', Colors.teal.shade400),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridButton(String label, IconData icon, BuildContext context,
      String route, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, route, arguments: {'username': _username});
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
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';  

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isPasswordVisible = false;
  bool _isLoading = false; // Loading state

  // Method to handle login with API
  void _login() async {
  final loginId = _loginController.text;
  final password = _passwordController.text;

  setState(() {
    _isLoading = true; // Show loading indicator
    _errorMessage = ''; // Clear previous error message
  });

  const url = 'http://localhost:4000/api/login';
  final body = jsonEncode({
    'Email': loginId,
    'Password': password,
  });

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      // Move to the main screen regardless of the response content
      Navigator.pushNamed(context, '/main', arguments: loginId);
    } else {
      // Display a generic error message if not 200
      setState(() {
        _errorMessage = 'Server error. Please try again later.';
      });
    }
  } catch (e) {
    // Handle network or unexpected errors
    setState(() {
      _errorMessage = 'An error occurred. Please check your connection.';
    });
  } finally {
    // Hide loading indicator
    setState(() {
      _isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login', style: TextStyle(fontSize: 24, color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blue[100],
                child: const Icon(Icons.person, size: 60, color: Colors.blue),
              ),
              const SizedBox(height: 40),

              // Login ID TextField
              TextField(
                controller: _loginController,
                decoration: InputDecoration(
                  labelText: 'Login',
                  labelStyle: const TextStyle(color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
                  ),
                  prefixIcon: const Icon(Icons.person, color: Colors.blueAccent),
                ),
              ),
              const SizedBox(height: 20),

              // Password TextField
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
                  ),
                  prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Display error message if present
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 20),

              // Login button with loading state
              SizedBox(
                width: screenWidth * 0.8,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,  // Disable button if loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : const Text('Login', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgotpassword');
                    },
                    child: const Text('Forgot Password?', style: TextStyle(color: Colors.blueAccent)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text('New? Register!', style: TextStyle(color: Colors.blueAccent)),
                  ),
                ],
              ),

              const SizedBox(height: 50),
              const Text(
                'Made with ❤️ in SAKEC',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

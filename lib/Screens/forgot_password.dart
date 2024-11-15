import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();
  String _errorMessage = '';

  void _sendRequest() {
    final loginEmail = _loginEmailController.text.trim();
    final confirmEmail = _confirmEmailController.text.trim();

    if (loginEmail.isEmpty || confirmEmail.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in both fields.';
      });
    } else if (loginEmail != confirmEmail) {
      setState(() {
        _errorMessage = 'The emails do not match.';
      });
    } else {
      setState(() {
        _errorMessage = '';
      });

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Request Sent"),
            content: const Text("We've got your request, relax."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/');
                },
                child: const Text("Back"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password', style: TextStyle(fontSize: 24, color: Colors.white)),
        backgroundColor: Colors.deepOrangeAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Oops, Forgot your password?',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.deepOrangeAccent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'No worries, enter your email below and we’ll help you out.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            TextField(
              controller: _loginEmailController,
              decoration: InputDecoration(
                labelText: 'Your loginID/Email',
                labelStyle: const TextStyle(color: Colors.deepOrangeAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                prefixIcon: const Icon(Icons.email, color: Colors.deepOrangeAccent),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.deepOrangeAccent, width: 2.0),
                ),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _confirmEmailController,
              decoration: InputDecoration(
                labelText: 'Confirm LoginID/Email',
                labelStyle: const TextStyle(color: Colors.deepOrangeAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                prefixIcon: const Icon(Icons.email_outlined, color: Colors.deepOrangeAccent),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.deepOrangeAccent, width: 2.0),
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[400],
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('< Back', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: _sendRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Send >', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

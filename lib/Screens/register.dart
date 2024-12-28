import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../api/endpoints.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _receiveUpdates = false;

  String _errorMessage = '';
  bool _isLoading = false;
  bool _isOtpFieldVisible = false;
  bool _isEmailVerified = false;

  // New method to check if registration is allowed
  bool _isRegistrationAllowed() {
    return _isFormValid() && _receiveUpdates && _isEmailVerified;
  }

  // Method to get helper text for registration requirements
  String _getRegistrationHelperText() {
    if (!_isEmailVerified) {
      return 'Please verify your email to continue';
    }
    if (!_receiveUpdates) {
      return 'Please accept to receive updates from SAKEC';
    }
    if (!_isFormValid()) {
      return 'Please fill in all required fields';
    }
    return '';
  }

  void _updateFormValidity() {
    setState(() {}); // Triggers a rebuild to update the register button's enabled/disabled state
  }

  Future<void> _sendOtp() async {
    final String email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an email address.';
      });
      return;
    }

    setState(() => _isLoading = true);

    await ApiService().postRequest(emailOtpEndpoint, {'Email': email});

    setState(() {
      _isOtpFieldVisible = true;
      _isLoading = false;
      _errorMessage = 'An OTP has been sent to your email.';
    });
  }

  Future<void> _verifyOtp() async {
    final String otp = _otpController.text.trim();
    if (otp.isEmpty) {
      setState(() => _errorMessage = 'Please enter the OTP.');
      return;
    }

    setState(() => _isLoading = true);

    // Make the API call to verify OTP
    final response = await ApiService().postRequest(verifyOtpEndpoint, {
      'Email': _emailController.text.trim(),
      'OTP': otp,
    });

    setState(() {
      _isLoading = false;

      // Check if the response contains the success message
      if (response != null &&
          response['message'] == "OTP verified successfully") {
        _isEmailVerified = true;
        _errorMessage = 'Email verified successfully!';
        _updateFormValidity(); // Update form validity to enable Register button
      } else {
        _isEmailVerified = false;
        _errorMessage = 'OTP verification failed. Try again.';
      }
    });
  }

  // Method to validate if form fields are filled and email is verified
  bool _isFormValid() {
    return _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty;
  }

  Future<void> _register() async {
    if (!_isRegistrationAllowed()) {
      setState(() {
        _errorMessage = 'Please fill in all the fields and verify your email.';
      });
      return;
    }

    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    final Map<String, dynamic> requestData = {
      'FirstName': _firstNameController.text.trim(),
      'LastName': _lastNameController.text.trim(),
      'Email': _emailController.text.trim(),
      'Password': _passwordController.text.trim(),
      'PhoneNumber': _phoneController.text.trim(),
    };

    try {
      final response =
          await ApiService().postRequest(registerEndpoint, requestData);

      setState(() => _isLoading = false);

      // Check if registration was successful based on the presence of `UserID`
      if (response != null && response.containsKey('UserID')) {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Registration Successful"),
              content: const Text(
                  "You have registered successfully! Please log in to continue."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false);
                  },
                  child: const Text("Go to Login"),
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          _errorMessage =
              response?['message'] ?? 'Registration failed. Please try again.';
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'An error occurred. Please check your network connection.';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_updateFormValidity);
    _lastNameController.addListener(_updateFormValidity);
    _emailController.addListener(_updateFormValidity);
    _passwordController.addListener(_updateFormValidity);
    _phoneController.addListener(_updateFormValidity);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register',
            style: TextStyle(fontSize: 24, color: Colors.white)),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Welcome to the Club Champ!',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'What should we call you?',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.teal),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // First Name and Last Name fields
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.teal, width: 2.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.teal, width: 2.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Password field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Enter your Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                prefixIcon: const Icon(Icons.lock, color: Colors.teal),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.teal, width: 2.0),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Phone Number field
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Enter your Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                prefixIcon: const Icon(Icons.phone, color: Colors.teal),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.teal, width: 2.0),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Email field with "Send OTP" button inside the text field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Enter your Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                prefixIcon: const Icon(Icons.email, color: Colors.teal),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Text("Send OTP"),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.teal, width: 2.0),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // OTP Field
            if (_isOtpFieldVisible)
              TextField(
                controller: _otpController,
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: const Icon(Icons.lock, color: Colors.teal),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text("Verify OTP"),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.teal, width: 2.0),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Checkbox for SAKEC updates with required indicator
            CheckboxListTile(
              title: Row(
                children: [
                  const Text(
                    'Send me updates from SAKEC',
                    style: TextStyle(
                      color: Colors.teal,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '*',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              value: _receiveUpdates,
              onChanged: (bool? value) {
                setState(() {
                  _receiveUpdates = value ?? false;
                  _updateFormValidity();
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: Colors.teal,
            ),
            const SizedBox(height: 10),

            // Helper text for registration requirements
            if (_getRegistrationHelperText().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  _getRegistrationHelperText(),
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            // Display error message if present
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  _errorMessage,
                  style: TextStyle(
                    color: _isEmailVerified ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // Register button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isRegistrationAllowed() ? _register : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 18,
                          color: _isRegistrationAllowed()
                              ? Colors.white
                              : Colors.grey[600],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
  bool _isPasswordVisible = false;

  bool _isRegistrationAllowed() {
    return _isFormValid() && _receiveUpdates && _isEmailVerified;
  }

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
    setState(() {});
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

    final response = await ApiService().postRequest(verifyOtpEndpoint, {
      'Email': _emailController.text.trim(),
      'OTP': otp,
    });

    setState(() {
      _isLoading = false;

      if (response != null && response['message'] == "OTP verified successfully") {
        _isEmailVerified = true;
        _errorMessage = 'Email verified successfully!';
        _updateFormValidity();
      } else {
        _isEmailVerified = false;
        _errorMessage = 'OTP verification failed. Try again.';
      }
    });
  }

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
      final response = await ApiService().postRequest(registerEndpoint, requestData);

      setState(() => _isLoading = false);

      if (response != null && response.containsKey('UserID')) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade400, size: 30),
                  const SizedBox(width: 10),
                  const Text("Registration Successful"),
                ],
              ),
              content: const Text(
                "You have registered successfully! Please log in to continue.",
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text(
                    "Go to Login",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          _errorMessage = response?['message'] ?? 'Registration failed. Please try again.';
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred. Please check your network connection.';
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isPhone = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.teal.shade400, width: 2),
        ),
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey.shade600,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : suffix,
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal,
              Colors.teal.shade50,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Header with back button
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      ),
                      const Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Main Content Card
                  Container(
                    padding: const EdgeInsets.all(24),
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
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_add,
                            size: 50,
                            color: Colors.teal.shade400,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Welcome to the Club!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Let\'s get you started with your account',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Name Fields
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                controller: _firstNameController,
                                label: 'First Name',
                                icon: Icons.person_outline,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildInputField(
                                controller: _lastNameController,
                                label: 'Last Name',
                                icon: Icons.person_outline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Password field
                        _buildInputField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),
                        const SizedBox(height: 20),

                        // Phone Number field
                        _buildInputField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          icon: Icons.phone_outlined,
                          isPhone: true,
                        ),
                        const SizedBox(height: 20),

                        // Email field with OTP button
                        _buildInputField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          suffix: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _sendOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal.shade400,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(_isOtpFieldVisible ? "Resend OTP" : "Send OTP"),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // OTP Field
                        if (_isOtpFieldVisible)
                          Column(
                            children: [
                              _buildInputField(
                                controller: _otpController,
                                label: 'Enter OTP',
                                icon: Icons.lock_clock_outlined,
                                suffix: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _verifyOtp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal.shade400,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text("Verify"),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),

                        // Updates Checkbox
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CheckboxListTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Send me updates from SAKEC',
                                    style: TextStyle(
                                      color: Colors.teal.shade700,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Text(
                                  '*',
                                  style: TextStyle(
                                    color: Colors.red.shade400,
                                    fontSize: 16,
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
                            activeColor: Colors.teal.shade400,
                            checkColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Helper and Error Messages
                        if (_getRegistrationHelperText().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.orange.shade400),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _getRegistrationHelperText(),
                                    style: TextStyle(
                                      color: Colors.orange.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (_errorMessage.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _isEmailVerified ? Colors.green.shade50 : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _isEmailVerified ? Colors.green.shade200 : Colors.red.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isEmailVerified ? Icons.check_circle : Icons.error_outline,
                                  color: _isEmailVerified ? Colors.green.shade400 : Colors.red.shade400,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorMessage,
                                    style: TextStyle(
                                      color: _isEmailVerified ? Colors.green.shade700 : Colors.red.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isRegistrationAllowed() ? _register : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade400,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade300,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 2,
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
                                : const Text(
                                    'Register',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.teal.shade400,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              child: const Text(
                                'Login here',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
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
}

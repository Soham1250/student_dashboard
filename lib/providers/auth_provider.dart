// providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../api/auth_api.dart';

class AuthProvider with ChangeNotifier {
  final AuthApi _authApi = AuthApi();
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<void> login(String email, String password) async {
    try {
      final response = await _authApi.login(email, password);
      if (response != null) {
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      print(e); // Handle error (e.g., show a message to the user)
    }
  }

  Future<void> register(Map<String, dynamic> userData) async {
    try {
      await _authApi.register(userData);
      // Handle successful registration
    } catch (e) {
      print(e); // Handle error
    }
  }
}
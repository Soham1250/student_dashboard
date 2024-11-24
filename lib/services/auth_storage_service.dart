import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';

class AuthStorageService {
  static const String KEY_USERNAME = 'username';
  static const String KEY_PASSWORD = 'password';
  
  final ApiService _apiService = ApiService();

  // Save user credentials
  Future<void> saveCredentials(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(KEY_USERNAME, username);
    await prefs.setString(KEY_PASSWORD, password);
  }

  // Check if credentials exist
  Future<bool> hasStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(KEY_USERNAME) && prefs.containsKey(KEY_PASSWORD);
  }

  // Get stored credentials
  Future<Map<String, String>?> getStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(KEY_USERNAME);
    final password = prefs.getString(KEY_PASSWORD);
    
    if (username != null && password != null) {
      return {
        'username': username,
        'password': password,
      };
    }
    return null;
  }

  // Clear stored credentials
  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(KEY_USERNAME);
    await prefs.remove(KEY_PASSWORD);
  }

  // Validate stored credentials with API
  Future<bool> validateStoredCredentials() async {
    try {
      final credentials = await getStoredCredentials();
      if (credentials == null) return false;

      await _apiService.login(
        credentials['username']!,
        credentials['password']!,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}

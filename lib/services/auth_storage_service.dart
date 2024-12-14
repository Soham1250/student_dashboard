import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';

class AuthStorageService {
  static const String key_username = 'username';
  static const String key_password = 'password';
  
  final ApiService _apiService = ApiService();

  // Save user credentials
  Future<void> saveCredentials(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key_username, username);
    await prefs.setString(key_password, password);
  }

  // Check if credentials exist
  Future<bool> hasStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key_username) && prefs.containsKey(key_password);
  }

  // Get stored credentials
  Future<Map<String, String>?> getStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(key_username);
    final password = prefs.getString(key_password);
    
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
    await prefs.remove(key_username);
    await prefs.remove(key_password);
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

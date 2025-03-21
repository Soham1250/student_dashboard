// api/auth_api.dart
import 'api_service.dart';
import 'endpoints.dart';

class AuthApi {
  final ApiService _apiService = ApiService();

  Future<dynamic> login(String email, String password) async {
    return await _apiService.postRequest(
      loginEndpoint,
      {'email': email, 'password': password},
    );
  }

  Future<dynamic> register(Map<String, dynamic> userData) async {
    return await _apiService.postRequest(registerEndpoint, userData);
  }

  // Add other auth-related methods as needed
}

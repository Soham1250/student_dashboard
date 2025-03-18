// api/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'endpoints.dart';

class ApiService {
  // A generic GET request method
  Future<dynamic> getRequest(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return _processResponse(response);
    } catch (error) {
      throw Exception('Network error: $error');
    }
  }

  // A generic POST request method
  Future<dynamic> postRequest(String url, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } catch (error) {
      throw Exception('Network error: $error');
    }
  }

  // Login method
  Future<Map<String, dynamic>> login(String loginId, String password) async {
    final body = {
      'Email': loginId,
      'Password': password,
      'fields': [
        'UserID',
        'FirstName',
        'LastName',
        'Email',
        'Password',
        'PhoneNumber',
        'CurrentClass',
        'Gap',
        'Role',
        'isAdmin',
        'TimeStamp'
      ]
    };
    return await postRequest(loginEndpoint, body);
  }

  // Get student details
  Future<Map<String, dynamic>> getStudentDetails(String studentId) async {
    final url = getStudentByIdEndpoint(studentId);
    return await getRequest(url);
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      // Add default values for missing fields
      if (responseData is Map<String, dynamic>) {
        responseData['isFaculty'] ??= false; // Add default value if missing
      }
      return responseData;
    } else {
      try {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Unknown error occurred');
      } catch (e) {
        throw Exception('Failed to process response: ${response.statusCode}');
      }
    }
  }
}

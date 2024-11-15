// api/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/error_handler.dart';

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

  // Private method to process HTTP responses
  dynamic _processResponse(http.Response response) {
  print(response.body); // Debug line
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    handleError(response); 
  }
}

}

// utils/error_handler.dart
import 'package:http/http.dart' as http;

void handleError(http.Response response) {
  // Handle specific status codes or default error message
  switch (response.statusCode) {
    case 400:
      throw Exception('Bad Request');
    case 401:
      throw Exception('Unauthorized');
    case 404:
      throw Exception('Not Found');
    case 500:
      throw Exception('Server Error');
    default:
      throw Exception('Unexpected error: ${response.statusCode}');
  }
}

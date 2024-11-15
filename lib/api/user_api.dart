import 'api_service.dart';
import 'endpoints.dart';

class UserApi {
  final ApiService _apiService = ApiService();

  Future<dynamic> getUserById(String userId) async {
    return await _apiService.getRequest(getStudentByIdEndpoint(userId));
  }

  Future<dynamic> getFacultyById(String userId) async {
    return await _apiService.getRequest(getFacultyByIdEndpoint(userId));
  }

  // Add other user-related methods here as needed
}

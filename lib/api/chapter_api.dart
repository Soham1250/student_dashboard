import 'package:student_dashboard/api/api_service.dart';
import 'package:student_dashboard/api/endpoints.dart';
import 'package:student_dashboard/models/chapter.dart';

class ChapterApi {
  final ApiService _apiService = ApiService();

  // Get chapters by subject ID
  Future<List<Chapter>> getChaptersBySubject(String subjectId) async {
    try {
      final String endpoint = '$baseUrl/getsubjectchapters/$subjectId';
      final response = await _apiService.getRequest(endpoint);
      
      if (response is List) {
        return response.map((json) => Chapter.fromJson(json)).toList();
      }
      
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to fetch chapters: $e');
    }
  }

  // Get a specific chapter by ID
  Future<Chapter> getChapterById(String chapterId) async {
    try {
      final String endpoint = '$baseUrl/getchapterbyid/$chapterId';
      final response = await _apiService.getRequest(endpoint);
      return Chapter.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch chapter: $e');
    }
  }
}

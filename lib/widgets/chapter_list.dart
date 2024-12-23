import 'package:flutter/material.dart';
import 'package:student_dashboard/models/chapter.dart';
import 'package:student_dashboard/api/api_service.dart';
import 'package:student_dashboard/api/endpoints.dart';

class ChapterList extends StatelessWidget {
  final String subjectId;
  final Function(Chapter) onChapterTap;
  final _apiService = ApiService();

  ChapterList({
    super.key,
    required this.subjectId,
    required this.onChapterTap,
  });

  Future<List<Chapter>> _getChapters() async {
    try {
      // Convert subjectId to the correct format
      final endpoint = '$baseUrl/getsubjectchapters/${int.parse(subjectId)}';
      print('Fetching chapters from: $endpoint'); // Debug print
      
      final response = await _apiService.getRequest(endpoint);
      print('API Response: $response'); // Debug print
      
      if (response is List) {
        return response.map((json) => Chapter.fromJson(json)).toList();
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('Error fetching chapters: $e'); // Debug print
      throw Exception('Failed to fetch chapters: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Chapter>>(
      future: _getChapters(),
      builder: (context, snapshot) {
        // Debug prints
        print('Connection state: ${snapshot.connectionState}');
        if (snapshot.hasError) print('Error: ${snapshot.error}');
        if (snapshot.hasData) print('Data length: ${snapshot.data?.length}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Loading chapters...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Force a rebuild to retry
                    (context as Element).markNeedsBuild();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book_outlined, color: Colors.white, size: 48),
                SizedBox(height: 16),
                Text(
                  'No chapters available',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final chapter = snapshot.data![index];
            return ChapterCard(
              chapter: chapter,
              onTap: () => onChapterTap(chapter),
            );
          },
        );
      },
    );
  }
}

class ChapterCard extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback onTap;

  const ChapterCard({
    super.key,
    required this.chapter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF303030),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          chapter.chapterName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, 
          color: Colors.white, 
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}

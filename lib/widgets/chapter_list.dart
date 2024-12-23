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
      final endpoint = '$baseUrl/getsubjectchapters/${int.parse(subjectId)}';
      final response = await _apiService.getRequest(endpoint);
      
      if (response is List) {
        return response.map((json) => Chapter.fromJson(json)).toList();
      }
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to fetch chapters: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Chapter>>(
      future: _getChapters(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.blueAccent),
                SizedBox(height: 16),
                Text(
                  'Loading chapters...',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 16,
                  ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
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
                Icon(Icons.book_outlined, color: Colors.blueAccent, size: 48),
                SizedBox(height: 16),
                Text(
                  'No chapters available',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 16,
                  ),
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
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            border: Border.all(
              color: Colors.blueAccent.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.book_outlined,
                color: Colors.blueAccent,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  chapter.chapterName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.blueAccent,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

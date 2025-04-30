import 'package:flutter/material.dart';
import 'package:personalized_cet_mastery/api/api_service.dart';
import 'package:personalized_cet_mastery/models/chapter.dart';
import 'package:personalized_cet_mastery/api/endpoints.dart';

class ChapterList extends StatelessWidget {
  final String subjectId;
  final Function(Chapter) onChapterTap;
  final Color accentColor;
  final _apiService = ApiService();

  ChapterList({
    super.key,
    required this.subjectId,
    required this.onChapterTap,
    required this.accentColor,
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
              accentColor: accentColor,
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
  final Color accentColor;

  const ChapterCard({
    super.key,
    required this.chapter,
    required this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: accentColor.withOpacity(0.12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            border: Border.all(
              color: accentColor.withOpacity(0.22),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.book_outlined,
                  color: accentColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  chapter.chapterName,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: accentColor,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

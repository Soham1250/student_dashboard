import 'package:flutter/material.dart';
import 'package:student_dashboard/widgets/chapter_list.dart';

class LearnChapterScreen extends StatelessWidget {
  const LearnChapterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String username = args['username'] as String? ?? 'Unknown';
    final String subjectID = args['subjectID'] as String? ?? 'Unknown';
    final String subjectName = args['subjectName'] as String? ?? 'Unknown';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          '$subjectName Chapters',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
          Expanded(
            child: ChapterList(
              subjectId: subjectID,
              onChapterTap: (chapter) {
                Navigator.pushNamed(
                  context,
                  '/learnContent',
                  arguments: {
                    'username': username,
                    'subjectName': subjectName,
                    'chapterName': chapter.chapterName,
                    'chapterId': chapter.chapterId,
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:student_dashboard/widgets/chapter_list.dart';

class MathChapterScreen extends StatelessWidget {
  const MathChapterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final String username = args?['username'] ?? "Unknown";
    final String testType = args?['testType'] ?? "Unknown";
    final String subjectId = args?['subjectId'] ?? "1"; // Default to 1 if not provided

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF303030),
        title: const Text(
          'Mathematics Chapters',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Chapters from Database',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ChapterList(
              subjectId: subjectId,
              onChapterTap: (chapter) {
                Navigator.pushNamed(
                  context,
                  '/selectDifficulty',
                  arguments: {
                    'username': username,
                    'testType': testType,
                    'subjectId': subjectId,
                    'chapt': chapter.chapterName,
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

import 'package:flutter/material.dart';
import 'package:student_dashboard/widgets/chapter_list.dart';

class LearnSubjectScreen extends StatelessWidget {
  const LearnSubjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final String subjectId = args['subjectId'] ?? "Unknown";
    final String subjectName = args['subjectName'] ?? "Unknown";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF303030),
        title: Text(
          '$subjectName Chapters',
          style: const TextStyle(color: Colors.white),
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
                  '/learnchapter',
                  arguments: {
                    'subjectName': subjectName,
                    'chapterName': chapter.chapterName,
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

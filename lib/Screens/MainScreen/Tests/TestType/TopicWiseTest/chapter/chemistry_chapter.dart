import 'package:flutter/material.dart';
import 'package:student_dashboard/widgets/chapter_list.dart';

class ChemistryChapterScreen extends StatelessWidget {
  const ChemistryChapterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final String username = args?['username'] ?? "Unknown";
    final String testType = args?['testType'] ?? "Unknown";
    final String subjectId =
        args?['subjectId'] ?? "3"; // Default to 3 if not provided

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        title: const Text(
          'Chemistry Chapters',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
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
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Select a Chapter',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 20,
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

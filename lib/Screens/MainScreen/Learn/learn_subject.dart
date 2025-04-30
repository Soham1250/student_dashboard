import 'package:flutter/material.dart';
import 'package:personalized_cet_mastery/widgets/chapter_list.dart';

class LearnSubjectScreen extends StatelessWidget {
  const LearnSubjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final String subjectId = args['subjectId'] ?? "Unknown";
    final String subjectName = args['subjectName'] ?? "Unknown";

    // Choose accent color based on subject name
    Color accentColor;
    switch (subjectName) {
      case 'Physics':
        accentColor = Colors.blueAccent;
        break;
      case 'Chemistry':
        accentColor = Colors.purple;
        break;
      case 'Mathematics':
        accentColor = Colors.orange;
        break;
      default:
        accentColor = Colors.blueAccent;
    }

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
              accentColor: accentColor,
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

import 'package:flutter/material.dart';
import 'package:personalized_cet_mastery/widgets/chapter_list.dart';

class PhysicsChapterScreen extends StatelessWidget {
  const PhysicsChapterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final String username = args?['username'] ?? "Unknown";
    final String testType = args?['testType'] ?? "Unknown";
    final String subjectId =
        args?['subjectId'] ?? "2"; // Default to 2 if not provided

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        title: const Text(
          'Physics Chapters',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueAccent, Colors.white],
            stops: [0.0, 0.5],
          ),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Select a Chapter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ChapterList(
                subjectId: subjectId,
                accentColor: Colors.blueAccent,
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
      ),
    );
  }
}

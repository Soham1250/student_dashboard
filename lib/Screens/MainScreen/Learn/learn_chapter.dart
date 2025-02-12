import 'package:flutter/material.dart';
import 'package:student_dashboard/widgets/chapter_list.dart';

class LearnChapterScreen extends StatelessWidget {
  final Map<String, Color> subjectColors = {
    'Physics': Colors.blue.shade400,
    'Chemistry': Colors.purple.shade400,
    'Mathematics': Colors.orange.shade400,
  };

  LearnChapterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String username = args['username'] as String? ?? 'Unknown';
    final String subjectID = args['subjectID'] as String? ?? 'Unknown';
    final String subjectName = args['subjectName'] as String? ?? 'Unknown';
    final Color subjectColor = subjectColors[subjectName] ?? Colors.blue.shade400;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$subjectName Chapters',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blueAccent,
              Colors.blue.shade50,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Card
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.menu_book,
                      size: 50,
                      color: subjectColor,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      '$subjectName Chapters',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: subjectColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Select a chapter to start learning',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Chapter List
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

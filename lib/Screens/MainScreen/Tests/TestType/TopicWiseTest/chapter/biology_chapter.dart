import 'package:flutter/material.dart';

class BiologyChapterScreen extends StatelessWidget {
  final List<String> bioChapters = [
    "Biochemistry of Cell",
    "Diversity in Organisms",
    "Plant Growth and Development",
    "Plant Water Relations and Mineral Nutrition",
    "Genetic Basis of Inheritance",
    "Gene: Its Nature",
    "Expression and Regulation",
    "Biotechnology: Process and Application",
    "Enhancement in Food Production",
    "Microbes in Human Welfare",
    "Photosynthesis",
    "Respiration",
    "Reproduction in Plants",
    "Organisms and Environment-II",
  ];

  @override
  Widget build(BuildContext context) {
    final Map<String, String> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    final String username = args['username'] ?? "Unknown";
    final String testType = args['testType'] ?? "Unknown";
    final String subjectId = args['subjectId'] ?? "Unknown";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Topic'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Chapter',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: bioChapters.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildChapterButton(
                        context,
                        bioChapters[index],
                        username,
                        testType,
                        subjectId,
                        bioChapters[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterButton(BuildContext context, String chapter,
      String username, String testType, String subjectId, String chapterName) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/selectDifficulty', arguments: {
            'username': username,
            'testType': testType,
            'subjectId': subjectId,
            'chapt': chapterName,
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 5,
        ),
        child: Text(
          chapter,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ChemistryChapterScreen extends StatelessWidget {
  final List<String> chemChapters = [
    "Solid State",
    "Chemical Thermodynamics and Energetic",
    "Electrochemistry",
    "General Principles and Processes of Isolation",
    "Solutions and Colligative Properties",
    "p-Block elements",
    "Group 15 elements",
    "d and f Block Elements",
    "Chemical Kinetics",
    "Coordination Compounds",
    "Halogen Derivatives of Alkanes (and arenes)",
    "Aldehydes",
    "Ketones and Carboxylic Acids",
    "Organic Compounds Containing Nitrogen",
    "Alcohols",
    "Phenols and Ether Alcohol",
    "Polymers",
    "Chemistry in Everyday Life",
    "Biomolecules Carbohydrates",
    "Some basic concepts of chemistry",
    "States of matter: Gasses and liquids",
    "Redox reaction",
    "Surface chemistry",
    "Nature of chemical bond",
    "Hydrogen",
    "s-Block elements (Alkali and alkaline earth metals)",
    "Fundamental concepts and methods in organic chemistry",
    "Alkanes",
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
                itemCount: chemChapters.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildChapterButton(
                        context,
                        chemChapters[index],
                        username,
                        testType,
                        subjectId,
                        chemChapters[index]),
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

import 'package:flutter/material.dart';

class PhysicsChapterScreen extends StatelessWidget {
  final List<String> phyChapters = [
    "Circular motion",
    "Rotational motion",
    "Oscillations",
    "Gravitation",
    "Elasticity",
    "Electrostatics",
    "Wave Motion",
    "Magnetism",
    "Surface Tension",
    "Wave Theory of Light",
    "Stationary Waves",
    "Kinetic Theory of Gases and Radiation",
    "Interference and Diffraction",
    "Current Electricity",
    "Magnetic Effects of Electric Current",
    "Electromagnetic Inductions",
    "Electrons and Photons",
    "Atoms",
    "Molecules",
    "Nuclei",
    "Semiconductors",
    "Communication Systems",
    "Measurements",
    "Scalars and Vectors",
    "Force",
    "Friction in solids and liquids",
    "Refraction of Light",
    "Ray optics",
    "Magnetic effect of electric current",
    "Magnetism",
  ];

  @override
  Widget build(BuildContext context) {
    final Map<String, String> args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;

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
                itemCount: phyChapters.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildChapterButton(
                      context,
                      phyChapters[index],
                      username,
                      testType,
                      subjectId,
                      phyChapters[index],
                    ),
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

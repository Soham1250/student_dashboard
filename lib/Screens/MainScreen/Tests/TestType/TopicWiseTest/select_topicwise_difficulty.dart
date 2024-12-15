import 'package:flutter/material.dart';
import '../../../../../services/difficulty_progression_service.dart';

class SelectTopicWiseDifficultyScreen extends StatefulWidget {
  @override
  _SelectTopicWiseDifficultyScreenState createState() =>
      _SelectTopicWiseDifficultyScreenState();
}

class _SelectTopicWiseDifficultyScreenState
    extends State<SelectTopicWiseDifficultyScreen> {
  final DifficultyProgressionService _progressionService =
      DifficultyProgressionService();
  final Map<String, bool> _unlockedDifficulties = {
    'easy': true,
    'medium': false,
    'hard': false,
    'mixed': false,
  };

  @override
  void initState() {
    super.initState();
    _loadUnlockedDifficulties();
  }

  Future<void> _loadUnlockedDifficulties() async {
    final Map<String, String> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final String username = args['username'] ?? "Unknown";
    final String subjectId = args['subjectId'] ?? "Unknown";

    // Check each difficulty level
    for (String difficulty in ['medium', 'hard', 'mixed']) {
      _unlockedDifficulties[difficulty] =
          await _progressionService.isDifficultyUnlocked(
        username,
        difficulty,
        subjectId,
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;

    final String username = args['username'] ?? "Unknown";
    final String testType = args['testType'] ?? "Unknown";
    final String subjectId = args['subjectId'] ?? "Unknown";
    final String chapt = args['chapt'] ?? "Unknown";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Difficulty'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select Difficulty',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),

            // Row 1: Easy and Medium
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildDifficultyButton(
                      context,
                      'Easy',
                      Icons.check_circle,
                      Colors.green,
                      '/testInterface',
                      username,
                      testType,
                      subjectId,
                      chapt,
                      'easy',
                      true,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildDifficultyButton(
                      context,
                      'Medium',
                      Icons.trending_up,
                      Colors.orange,
                      '/testInterface',
                      username,
                      testType,
                      subjectId,
                      chapt,
                      'medium',
                      _unlockedDifficulties['medium'] ?? false,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Row 2: Hard and Mixed
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildDifficultyButton(
                      context,
                      'Hard',
                      Icons.whatshot,
                      Colors.red,
                      '/testInterface',
                      username,
                      testType,
                      subjectId,
                      chapt,
                      'hard',
                      _unlockedDifficulties['hard'] ?? false,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildDifficultyButton(
                      context,
                      'Mixed',
                      Icons.shuffle,
                      Colors.blue,
                      '/testInterface',
                      username,
                      testType,
                      subjectId,
                      chapt,
                      'mixed',
                      _unlockedDifficulties['mixed'] ?? false,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    String route,
    String username,
    String testType,
    String subjectId,
    String chapt,
    String difficulty,
    bool isUnlocked,
  ) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 80,
          child: ElevatedButton(
            onPressed: isUnlocked
                ? () {
                    Navigator.pushNamed(
                      context,
                      '/testInterface',
                      arguments: {
                        'username': username,
                        'testType': testType,
                        'subjectId': subjectId,
                        'chapt': chapt,
                        'difficulty': difficulty,
                      },
                    );
                  }
                : () {
                    _showLockMessage(context, difficulty);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: isUnlocked ? color : Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: isUnlocked ? 5 : 2,
              padding: EdgeInsets.zero,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isUnlocked)
          Positioned(
            top: 8,
            right: 8,
            child: Icon(
              Icons.lock,
              color: Colors.white,
              size: 20,
            ),
          ),
      ],
    );
  }

  void _showLockMessage(BuildContext context, String difficulty) {
    final previousDifficulty = difficulty == 'medium'
        ? 'easy'
        : difficulty == 'hard'
            ? 'medium'
            : 'hard';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${difficulty.capitalize()} Difficulty Locked'),
        content: Text(
            'Complete at least 5 tests in $previousDifficulty difficulty with an average accuracy of 50% or higher to unlock ${difficulty.capitalize()} difficulty.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

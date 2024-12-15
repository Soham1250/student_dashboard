import 'package:shared_preferences/shared_preferences.dart';

class DifficultyProgressionService {
  static const String _keyPrefix = 'difficulty_progress_';
  static const int _requiredTestCount = 5;
  static const double _requiredAccuracy = 50.0;

  static const List<String> _difficultyLevels = [
    'easy',
    'medium',
    'hard',
    'mixed'
  ];

  // Get the next difficulty level
  String? getNextDifficulty(String currentDifficulty) {
    final currentIndex = _difficultyLevels.indexOf(currentDifficulty);
    if (currentIndex < _difficultyLevels.length - 1) {
      return _difficultyLevels[currentIndex + 1];
    }
    return null;
  }

  // Check if a difficulty is unlocked for a user
  Future<bool> isDifficultyUnlocked(
      String userId, String difficulty, String subject) async {
    if (difficulty == 'easy') return true; // Easy is always unlocked

    final previousDifficulty =
        _difficultyLevels[_difficultyLevels.indexOf(difficulty) - 1];
    final stats = await getTestStats(userId, previousDifficulty, subject);

    return stats.testCount >= _requiredTestCount &&
        stats.averageAccuracy >= _requiredAccuracy;
  }

  // Record a test result
  Future<void> recordTestResult(
      String userId, String difficulty, String subject, double accuracy) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getStatsKey(userId, difficulty, subject);

    // Get existing stats
    final TestStats currentStats =
        await getTestStats(userId, difficulty, subject);

    // Update stats with new test result
    final updatedAccuracies = List<double>.from(currentStats.recentAccuracies);
    updatedAccuracies.add(accuracy);
    if (updatedAccuracies.length > _requiredTestCount) {
      updatedAccuracies.removeAt(0); // Remove oldest result
    }

    // Save updated stats
    final Map<String, dynamic> statsData = {
      'testCount': currentStats.testCount + 1,
      'recentAccuracies': updatedAccuracies,
    };

    await prefs.setString(key, statsData.toString());
  }

  // Get test statistics for a user, difficulty, and subject
  Future<TestStats> getTestStats(
      String userId, String difficulty, String subject) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getStatsKey(userId, difficulty, subject);

    final String? statsString = prefs.getString(key);
    if (statsString == null) {
      return TestStats(0, []);
    }

    try {
      final Map<String, dynamic> statsData = Map<String, dynamic>.from(
          // Parse the stored string back to a Map
          statsString as Map);

      return TestStats(
        statsData['testCount'] as int,
        List<double>.from(statsData['recentAccuracies'] as List),
      );
    } catch (e) {
      return TestStats(0, []);
    }
  }

  // Get stats storage key
  String _getStatsKey(String userId, String difficulty, String subject) {
    return '$_keyPrefix${userId}_${difficulty}_$subject';
  }
}

class TestStats {
  final int testCount;
  final List<double> recentAccuracies;

  TestStats(this.testCount, this.recentAccuracies);

  double get averageAccuracy {
    if (recentAccuracies.isEmpty) return 0;
    return recentAccuracies.reduce((a, b) => a + b) / recentAccuracies.length;
  }
}

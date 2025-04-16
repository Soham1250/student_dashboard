import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../services/difficulty_progression_service.dart';

class SelectSubjectWiseDifficultyScreen extends StatefulWidget {
  @override
  _SelectSubjectWiseDifficultyScreenState createState() =>
      _SelectSubjectWiseDifficultyScreenState();
}

class _SelectSubjectWiseDifficultyScreenState
    extends State<SelectSubjectWiseDifficultyScreen>
    with TickerProviderStateMixin {
  final DifficultyProgressionService _progressionService =
      DifficultyProgressionService();
  final Map<String, bool> _unlockedDifficulties = {
    'easy': true,
    'medium': false,
    'hard': false,
    'mixed': false,
  };

  late final List<AnimationController> _controllers;
  late final List<Animation<Offset>> _slideAnimations;
  late final List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      4,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    _slideAnimations = List.generate(
      4,
      (i) => Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controllers[i],
        curve: Curves.easeOutBack,
      )),
    );
    _fadeAnimations = List.generate(
      4,
      (i) => Tween<double>(
        begin: 0,
        end: 1,
      ).animate(CurvedAnimation(
        parent: _controllers[i],
        curve: Curves.easeIn,
      )),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playEntryAnimation();
    });
    _loadUnlockedDifficulties();
  }

  void _playEntryAnimation() async {
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].reset();
    }
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].forward();
      await Future.delayed(const Duration(milliseconds: 120));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        title: const Text(
          'Select Difficulty',
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Select Difficulty',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              ...List.generate(4, (i) {
                final labels = ['Easy', 'Medium', 'Hard', 'Mixed'];
                final icons = [
                  Icons.check_circle_outline,
                  Icons.trending_up,
                  Icons.whatshot,
                  Icons.shuffle
                ];
                final difficulties = ['easy', 'medium', 'hard', 'mixed'];
                final isUnlocked = i == 0
                    ? true
                    : _unlockedDifficulties[difficulties[i]] ?? false;
                return AnimatedBuilder(
                  animation: _controllers[i],
                  builder: (context, child) => Opacity(
                    opacity: _fadeAnimations[i].value,
                    child: Transform.translate(
                      offset: _slideAnimations[i].value * 80,
                      child: child,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: _AnimatedDifficultyCard(
                      label: labels[i],
                      icon: icons[i],
                      isUnlocked: isUnlocked,
                      onTap: () {
                        if (isUnlocked) {
                          Navigator.pushNamed(
                            context,
                            '/testInterface',
                            arguments: {
                              'username': username,
                              'testType': testType,
                              'subjectId': subjectId,
                              'difficulty': difficulties[i],
                            },
                          );
                        } else {
                          _showLockMessage(context, difficulties[i]);
                        }
                      },
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
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

// Animated Difficulty Card Widget
class _AnimatedDifficultyCard extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isUnlocked;
  final VoidCallback onTap;
  const _AnimatedDifficultyCard({
    required this.label,
    required this.icon,
    required this.isUnlocked,
    required this.onTap,
  });
  @override
  State<_AnimatedDifficultyCard> createState() =>
      _AnimatedDifficultyCardState();
}

class _AnimatedDifficultyCardState extends State<_AnimatedDifficultyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _scaleAnim;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scaleAnim = Tween<double>(begin: 1, end: 1.08).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOutBack),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    if (widget.isUnlocked) {
      await _tapController.forward();
      await _tapController.reverse();
      widget.onTap();
    } else {
      await _tapController.forward();
      await _tapController.reverse();
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _tapController,
      builder: (context, child) {
        final double shake = widget.isUnlocked ? 0 : _shakeAnim.value;
        return Transform.translate(
          offset:
              Offset(shake * (shake.isNaN ? 0 : (shake % 2 == 0 ? 1 : -1)), 0),
          child: Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: _handleTap,
        child: Card(
          elevation: widget.isUnlocked ? 10 : 3,
          shadowColor: Colors.blueAccent.withOpacity(0.18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color:
                  widget.isUnlocked ? Colors.blueAccent : Colors.grey.shade400,
              width: 2,
            ),
          ),
          color: Colors.white,
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  color: widget.isUnlocked ? Colors.blueAccent : Colors.grey,
                  size: 30,
                ),
                const SizedBox(width: 20),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: widget.isUnlocked ? Colors.blueAccent : Colors.grey,
                  ),
                ),
                if (!widget.isUnlocked)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Icon(Icons.lock, color: Colors.grey, size: 22),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

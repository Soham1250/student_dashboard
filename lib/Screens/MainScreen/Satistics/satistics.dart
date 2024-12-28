import 'package:flutter/material.dart';
import '../../../api/api_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _performanceData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPerformanceData();
  }

  Future<void> _fetchPerformanceData() async {
    try {
      // TODO: Replace with actual API call when available
      // Simulating API call with dummy data
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _performanceData = {
          'strongest': {'id': '2', 'name': 'Physics', 'score': 85},
          'revision': {'id': '3', 'name': 'Chemistry', 'score': 70},
          'weakest': {'id': '1', 'name': 'Mathematics', 'score': 60},
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load performance data';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String username = args['username'] as String? ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchPerformanceData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Hello $username, here\'s your performance analysis:',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      // Strongest Subject
                      _buildStatisticsButton(
                        context,
                        'Strongest Subject: ${_performanceData!['strongest']['name']}',
                        'Score: ${_performanceData!['strongest']['score']}%\nClick to view chapters',
                        Colors.green,
                        Icons.check_circle,
                        username,
                        _performanceData!['strongest'],
                      ),
                      const SizedBox(height: 20),

                      // Needs Revision
                      _buildStatisticsButton(
                        context,
                        'Needs Revision: ${_performanceData!['revision']['name']}',
                        'Score: ${_performanceData!['revision']['score']}%\nClick to view chapters',
                        Colors.orange,
                        Icons.refresh,
                        username,
                        _performanceData!['revision'],
                      ),
                      const SizedBox(height: 20),

                      // Weakest Subject
                      _buildStatisticsButton(
                        context,
                        'Weakest Subject: ${_performanceData!['weakest']['name']}',
                        'Score: ${_performanceData!['weakest']['score']}%\nClick to view chapters',
                        Colors.red,
                        Icons.warning,
                        username,
                        _performanceData!['weakest'],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatisticsButton(
    BuildContext context,
    String title,
    String description,
    Color color,
    IconData icon,
    String username,
    Map<String, dynamic> subjectData,
  ) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          '/learnchapter',
          arguments: {
            'username': username,
            'subjectID': subjectData['id'],
            'subjectName': subjectData['name'],
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

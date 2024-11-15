import 'package:flutter/material.dart';

class ManageGrievanceScreen extends StatelessWidget {
  final List<Map<String, String>> grievances = [
    {'Grievance_ID': 'GR001', 'Status': 'Pending'},
    {'Grievance_ID': 'GR002', 'Status': 'Resolved'},
    {'Grievance_ID': 'GR003', 'Status': 'In Progress'},
    {'Grievance_ID': 'GR004', 'Status': 'Pending'},
    {'Grievance_ID': 'GR005', 'Status': 'Resolved'},
  ];

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
    final String username = args?['username'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hello $username,\nManage Grievances',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Grievances',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Grievance_ID',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Text(
                  'Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
            const Divider(thickness: 2),

            Expanded(
              child: ListView.builder(
                itemCount: grievances.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      _buildGrievanceRow(grievances[index]),
                      const Divider(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrievanceRow(Map<String, String> grievance) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            grievance['Grievance_ID'] ?? '',
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          Text(
            grievance['Status'] ?? '',
            style: TextStyle(
              fontSize: 16,
              color: grievance['Status'] == 'Resolved' ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}

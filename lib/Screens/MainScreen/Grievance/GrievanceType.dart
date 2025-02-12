import 'package:flutter/material.dart';

class GrievanceType extends StatefulWidget {
  @override
  _GrievanceTypeState createState() => _GrievanceTypeState();
}

class _GrievanceTypeState extends State<GrievanceType> {
  String? selectedGrievanceType;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
    final String username = args?["username"] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Grievance Type',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blueAccent,
              Colors.white,
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
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
                      const Icon(
                        Icons.support_agent,
                        size: 50,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'How can we help you today?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Select the type of grievance you want to submit',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Grievance Type Selection
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Grievance Type',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                          color: Colors.grey.shade50,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedGrievanceType,
                            hint: Text('Choose type',
                                style: TextStyle(color: Colors.grey[600])),
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: Colors.blueAccent),
                            items: const [
                              DropdownMenuItem(
                                value: 'general',
                                child: Text('General Grievance'),
                              ),
                              DropdownMenuItem(
                                value: 'test',
                                child: Text('Test Based Grievance'),
                              ),
                            ],
                            onChanged: (String? value) {
                              setState(() {
                                selectedGrievanceType = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Continue Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: selectedGrievanceType == null
                      ? null
                      : () {
                          if (selectedGrievanceType == 'general') {
                            Navigator.pushNamed(
                              context,
                              '/newGrievance',
                              arguments: {'username': username},
                            );
                          } else {
                            Navigator.pushNamed(
                              context,
                              '/testBasedGrievance',
                              arguments: {'username': username},
                            );
                          }
                        },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: selectedGrievanceType == null
                              ? Colors.grey
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        color: selectedGrievanceType == null
                            ? Colors.grey
                            : Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

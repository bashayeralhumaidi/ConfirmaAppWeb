// ===============================
// SAFETY PAGE (UPDATED + CORRECT COUNTER)
// ===============================
import 'package:flutter/material.dart';
import 'summary_local_storage.dart';

class SafetyPage extends StatefulWidget {
  final String plantName;
  final String doneBy;
  final String date;

  static const List<String> questions = [
    "Emergency exits unobstructed, illuminated, and clearly marked.",
    "Fire extinguishers / safety showers / eye wash stations present, accessible, and inspected.",
    "PPE availability and correct usage by all personnel.",
    "No tripping hazards, chemical spills, or sharp objects in working areas.",
    "Safety signage (hazard labels, warnings) visible and intact.",
    "Extinguishers are sufficient in number and near the operation easy to access and to be used, no pallet or any obstales to reach them.",
    "Spillage kit where applicable is in place and people trained on how to use it",
    "Any open points you saw and requires attention:"
  ];

  const SafetyPage({
    super.key,
    required this.plantName,
    required this.doneBy,
    required this.date,
  });

  @override
  State<SafetyPage> createState() => _SafetyPageState();
}

class _SafetyPageState extends State<SafetyPage> {
  @override
  void initState() {
    super.initState();
SummaryLocalStorage.currentCategoryQuestions = SafetyPage.questions;

    for (int i = 0; i < SafetyPage.questions.length; i++) {
      SummaryLocalStorage.safetyAnswers[i] ??= {
        "status": "",
        "remarks": "",
        "action": ""
      };
    }
  }

  int _countCompleted() {
    int count = 0;
    SummaryLocalStorage.safetyAnswers.forEach((key, value) {
      if (value["status"] != null && value["status"].toString().isNotEmpty) {
        count++;
      }
    });
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF1F3),

      appBar: AppBar(
        backgroundColor: const Color(0xFFEFF1F3),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF00B050)),
        title: Text(
          "🧯 Safety (${_countCompleted()}/${SafetyPage.questions.length})",
          style: const TextStyle(
            color: Color(0xFF00B050),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: SafetyPage.questions.length,
        itemBuilder: (context, index) {
          String q = SafetyPage.questions[index];
          String status = SummaryLocalStorage.safetyAnswers[index]?['status'] ?? "";

          TextEditingController remarksController = TextEditingController(
            text: SummaryLocalStorage.safetyAnswers[index]?['remarks'] ?? "",
          );

          TextEditingController actionController = TextEditingController(
            text: SummaryLocalStorage.safetyAnswers[index]?['action'] ?? "",
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 25),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade300, width: 1),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00B050),
                  ),
                ),

                const SizedBox(height: 12),

              // ===============================
              // STATUS DROPDOWN
              // ===============================
// STATUS DROPDOWN (HIDE FOR LAST QUESTION)
if (index != SafetyPage.questions.length - 1)
  Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: Colors.blue, width: 1),
      color: Colors.white,
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: status.isEmpty ? null : status,
        hint: const Text("Select Status"),
        items: const [
          DropdownMenuItem(value: "OK", child: Text("✓ OK")),
          DropdownMenuItem(value: "Needs Attention", child: Text("⚠ Needs Attention")),
          DropdownMenuItem(value: "Not Acceptable", child: Text("❌ Not Acceptable")),
          DropdownMenuItem(value: "N/A", child: Text("N/A")),
        ],
        onChanged: (val) {
          setState(() {
            SummaryLocalStorage.safetyAnswers[index]!["status"] = val!;
          });
        },
      ),
    ),
  ),


                const SizedBox(height: 14),

                TextField(
                  controller: remarksController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Remarks / Observations",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 2,
                  onChanged: (_) {
                    SummaryLocalStorage.safetyAnswers[index]!['remarks'] =
                        remarksController.text;
                  },
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: actionController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Immediate Action Taken",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 2,
                  onChanged: (_) {
                    SummaryLocalStorage.safetyAnswers[index]!['action'] =
                        actionController.text;
                  },
                ),

                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}

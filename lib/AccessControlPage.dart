import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'summary_local_storage.dart';

class AccessControlPage extends StatefulWidget {
  final String plantName;
  final String doneBy;
  final String date;

  static const List<String> questions = [
    "Entry doors are secured; unauthorized access is not permitted.",
    "Biometric / access card system functioning correctly.",
    "Visitors properly logged and accompanied.",
    "Restricted zones clearly marked and access granted only to trained personnel.",
    "No tailgating or bypassing of access points.",
    "Any open points you saw and requires attention:"
  ];

  const AccessControlPage({
    super.key,
    required this.plantName,
    required this.doneBy,
    required this.date,
  });

  @override
  State<AccessControlPage> createState() => _AccessControlPageState();
}

class _AccessControlPageState extends State<AccessControlPage> {
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    SummaryLocalStorage.currentCategoryQuestions = AccessControlPage.questions;

    for (int i = 0; i < AccessControlPage.questions.length; i++) {
      SummaryLocalStorage.accessAnswers[i] ??= {
        "status": "",
        "remarks": "",
        "action": "",
        "image": ""
      };
    }
  }

  int _countCompleted() {
    int count = 0;
    SummaryLocalStorage.accessAnswers.forEach((key, value) {
      if ((value["status"] ?? "").toString().isNotEmpty) count++;
    });
    return count;
  }

  Future<void> pickImage(int index) async {
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      Uint8List bytes = await file.readAsBytes();
      String base64img = base64Encode(bytes);

      SummaryLocalStorage.accessAnswers[index]!["image"] = base64img;

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF1F3),

      appBar: AppBar(
        backgroundColor: const Color(0xFFEFF1F3),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFE26B0A)), // 🔶 NEW COLOR
        title: Text(
          "🔐 Access Control (${_countCompleted()}/${AccessControlPage.questions.length})",
          style: const TextStyle(
            color: Color(0xFFE26B0A), // 🔶 NEW COLOR
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: AccessControlPage.questions.length,
        itemBuilder: (context, index) {
          String q = AccessControlPage.questions[index];
          String status = SummaryLocalStorage.accessAnswers[index]?["status"] ?? "";

          TextEditingController remarksController = TextEditingController(
            text: SummaryLocalStorage.accessAnswers[index]?["remarks"] ?? "",
          );

          TextEditingController actionController = TextEditingController(
            text: SummaryLocalStorage.accessAnswers[index]?["action"] ?? "",
          );

          String? base64Image =
              SummaryLocalStorage.accessAnswers[index]?["image"];

          return Container(
            margin: const EdgeInsets.only(bottom: 25),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE26B0A), width: 2), // 🔶 NEW COLOR
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE26B0A), // 🔶 NEW COLOR
                  ),
                ),

                const SizedBox(height: 12),

                // HIDE STATUS for last question
                if (index != AccessControlPage.questions.length - 1)
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
                            SummaryLocalStorage.accessAnswers[index]!["status"] = val!;
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
                    SummaryLocalStorage.accessAnswers[index]!["remarks"] =
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
                    SummaryLocalStorage.accessAnswers[index]!["action"] =
                        actionController.text;
                  },
                ),

                const SizedBox(height: 14),

                if (index != AccessControlPage.questions.length - 1) ...[
                  ElevatedButton(
                    onPressed: () => pickImage(index),
                    child: const Text("📸 Upload Image"),
                  ),

                  if (base64Image != null && base64Image.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Image.memory(
                        base64Decode(base64Image),
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

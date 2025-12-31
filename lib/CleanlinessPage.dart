import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'summary_local_storage.dart';

class CleanlinessPage extends StatefulWidget {
  final String plantName;
  final String doneBy;
  final String date;

  static const List<String> questions = [
    "Production and packaging areas free from visible dust, spills, or product residue.",
    "Equipment visibly clean and covered when not in use.",
    "Waste bins present, correctly labeled, and not overflowing.",
    "Cleaning and sanitization records completed and up to date.",
    "Pallets inside GMP areas are clean and in excellent shape.",
    "Any open points you saw and requires attention:"
  ];

  const CleanlinessPage({
    super.key,
    required this.plantName,
    required this.doneBy,
    required this.date,
  });

  @override
  State<CleanlinessPage> createState() => _CleanlinessPageState();
}

class _CleanlinessPageState extends State<CleanlinessPage> {
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    SummaryLocalStorage.currentCategoryQuestions = CleanlinessPage.questions;

    for (int i = 0; i < CleanlinessPage.questions.length; i++) {
      SummaryLocalStorage.cleanlinessAnswers[i] ??= {
        "status": "",
        "remarks": "",
        "action": "",
        "image": ""
      };
    }
  }

  int _countCompleted() {
    int count = 0;
    SummaryLocalStorage.cleanlinessAnswers.forEach((key, value) {
      if ((value["status"] ?? "").toString().isNotEmpty) count++;
    });
    return count;
  }

  /// KEEP ORIGINAL IMAGE (FULL QUALITY)
  Future<void> pickImage(int index) async {
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      Uint8List bytes = await file.readAsBytes();

      String base64img = base64Encode(bytes);

      SummaryLocalStorage.cleanlinessAnswers[index]!["image"] = base64img;

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
        iconTheme: const IconThemeData(color: Color(0xFF4f81bd)),
        title: Text(
          "🧹 Cleanliness (${_countCompleted()}/${CleanlinessPage.questions.length})",
          style: const TextStyle(
            color: Color(0xFF4f81bd),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: CleanlinessPage.questions.length,
        itemBuilder: (context, index) {
          String q = CleanlinessPage.questions[index];
          String status =
              SummaryLocalStorage.cleanlinessAnswers[index]?["status"] ?? "";

          TextEditingController remarksController = TextEditingController(
            text: SummaryLocalStorage.cleanlinessAnswers[index]?["remarks"] ?? "",
          );

          TextEditingController actionController = TextEditingController(
            text: SummaryLocalStorage.cleanlinessAnswers[index]?["action"] ?? "",
          );

          String? base64Image =
              SummaryLocalStorage.cleanlinessAnswers[index]?["image"];

          return Container(
            margin: const EdgeInsets.only(bottom: 25),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF4f81bd), width: 2),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4f81bd),
                  ),
                ),

                const SizedBox(height: 12),

                if (index != CleanlinessPage.questions.length - 1)
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
                          DropdownMenuItem(
                              value: "Needs Attention",
                              child: Text("⚠ Needs Attention")),
                          DropdownMenuItem(
                              value: "Not Acceptable",
                              child: Text("❌ Not Acceptable")),
                          DropdownMenuItem(value: "N/A", child: Text("N/A")),
                        ],
                        onChanged: (val) {
                          setState(() {
                            SummaryLocalStorage.cleanlinessAnswers[index]!["status"] =
                                val!;
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
                    SummaryLocalStorage.cleanlinessAnswers[index]!["remarks"] =
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
                    SummaryLocalStorage.cleanlinessAnswers[index]!["action"] =
                        actionController.text;
                  },
                ),

                const SizedBox(height: 14),

                if (index != CleanlinessPage.questions.length - 1) ...[
                  OutlinedButton(
                    onPressed: () => pickImage(index),
                    child: const Text("📸 Upload Image"),
                  ),

                  if (base64Image != null && base64Image.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Image.memory(
                        base64Decode(base64Image),
                        fit: BoxFit.contain, // FULL QUALITY
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

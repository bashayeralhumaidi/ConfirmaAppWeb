import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'summary_local_storage.dart';

class QualityPage extends StatefulWidget {
  final String plantName;
  final String doneBy;
  final String date;

  static const List<String> questions = [
    "No personal belongings, food, or drinks in GMP zones.",
    "Logbooks updated in there area accessible and filled properly reflecting the ALCOA DI principles.",
    "Equipment calibration and validation tags present, current, and legible.",
    "Raw materials, intermediates, and finished goods correctly labeled and stored.",
    "In-process control (IPC) records completed, signed, and available.",
    "Deviations or nonconformities immediately documented and escalated.",
    "Gowning procedure respected and 100% compliant ",
    "No make up, hair falling from gown (head cover, beared cover respected), and no false nails or missing gloves to be worn when necessary.",
    "Any open points you saw and requires attention:"
  ];

  const QualityPage({
    super.key,
    required this.plantName,
    required this.doneBy,
    required this.date,
  });

  @override
  State<QualityPage> createState() => _QualityPageState();
}

class _QualityPageState extends State<QualityPage> {
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    SummaryLocalStorage.currentCategoryQuestions = QualityPage.questions;

    for (int i = 0; i < QualityPage.questions.length; i++) {
      SummaryLocalStorage.qualityAnswers[i] ??= {
        "status": "",
        "remarks": "",
        "action": "",
        "image": ""
      };
    }
  }

  int _countCompleted() {
    int count = 0;
    SummaryLocalStorage.qualityAnswers.forEach((key, value) {
      if ((value["status"] ?? "").toString().isNotEmpty) count++;
    });
    return count;
  }

  /// STORE ORIGINAL IMAGE FULL QUALITY
  Future<void> pickImage(int index) async {
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      Uint8List bytes = await file.readAsBytes();
      String base64img = base64Encode(bytes);

      SummaryLocalStorage.qualityAnswers[index]!["image"] = base64img;

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
        iconTheme: const IconThemeData(color: Color(0xFF31869b)),
        title: Text(
          "🧪 Quality Compliance(${_countCompleted()}/${QualityPage.questions.length})",
          style: const TextStyle(
            color: Color(0xFF31869b),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: QualityPage.questions.length,
        itemBuilder: (context, index) {
          String q = QualityPage.questions[index];
          String status =
              SummaryLocalStorage.qualityAnswers[index]?["status"] ?? "";

          TextEditingController remarksController = TextEditingController(
            text: SummaryLocalStorage.qualityAnswers[index]?["remarks"] ?? "",
          );

          TextEditingController actionController = TextEditingController(
            text: SummaryLocalStorage.qualityAnswers[index]?["action"] ?? "",
          );

          String? base64Image =
              SummaryLocalStorage.qualityAnswers[index]?["image"];

          return Container(
            margin: const EdgeInsets.only(bottom: 25),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF31869b), width: 2),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF31869b),
                  ),
                ),

                const SizedBox(height: 12),

                if (index != QualityPage.questions.length - 1)
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
                            SummaryLocalStorage.qualityAnswers[index]!["status"] =
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
                    SummaryLocalStorage.qualityAnswers[index]!["remarks"] =
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
                    SummaryLocalStorage.qualityAnswers[index]!["action"] =
                        actionController.text;
                  },
                ),

                const SizedBox(height: 14),

                if (index != QualityPage.questions.length - 1) ...[
                  OutlinedButton(
                    onPressed: () => pickImage(index),
                    child: const Text("📸 Upload Image"),
                  ),

                  if (base64Image != null && base64Image.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Image.memory(
                        base64Decode(base64Image),
                        fit: BoxFit.contain, // KEEP FULL QUALITY
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

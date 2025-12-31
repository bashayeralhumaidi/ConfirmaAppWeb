import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'summary_local_storage.dart';

class EquipmentPage extends StatefulWidget {
  final String plantName;
  final String doneBy;
  final String date;

  static const List<String> questions = [
    "Equipment in validated state with logs completed and accessible.",
    "Preventive maintenance carried out per schedule, with records available.",
    "Equipment clean, rust free, dry, and free from product residue.",
    "No leaks, abnormal noises, or visible damage during operation.",
    "Change parts properly stored, clean, and labeled.",
    "Any open points you saw and requires attention:"
  ];

  const EquipmentPage({
    super.key,
    required this.plantName,
    required this.doneBy,
    required this.date,
  });

  @override
  State<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> {
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    SummaryLocalStorage.currentCategoryQuestions = EquipmentPage.questions;

    for (int i = 0; i < EquipmentPage.questions.length; i++) {
      SummaryLocalStorage.equipmentAnswers[i] ??= {
        "status": "",
        "remarks": "",
        "action": "",
        "image": ""
      };
    }
  }

  int _countCompleted() {
    int count = 0;
    SummaryLocalStorage.equipmentAnswers.forEach((key, value) {
      if ((value["status"] ?? "").toString().isNotEmpty) count++;
    });
    return count;
  }

  // KEEP ORIGINAL IMAGE (NO RESIZE)
  Future<void> pickImage(int index) async {
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      Uint8List bytes = await file.readAsBytes();

      // Save in full quality
      String base64img = base64Encode(bytes);

      SummaryLocalStorage.equipmentAnswers[index]!["image"] = base64img;

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
        iconTheme: const IconThemeData(color: Color(0xFFda9694)),
        title: Text(
          "🔧 Equipment (${_countCompleted()}/${EquipmentPage.questions.length})",
          style: const TextStyle(
            color: Color(0xFFda9694),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: EquipmentPage.questions.length,
        itemBuilder: (context, index) {
          String q = EquipmentPage.questions[index];
          String status =
              SummaryLocalStorage.equipmentAnswers[index]?["status"] ?? "";

          TextEditingController remarksController = TextEditingController(
            text: SummaryLocalStorage.equipmentAnswers[index]?["remarks"] ?? "",
          );

          TextEditingController actionController = TextEditingController(
            text: SummaryLocalStorage.equipmentAnswers[index]?["action"] ?? "",
          );

          String? base64Image =
              SummaryLocalStorage.equipmentAnswers[index]?["image"];

          return Container(
            margin: const EdgeInsets.only(bottom: 25),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFda9694), width: 2),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFda9694),
                  ),
                ),

                const SizedBox(height: 12),

                // STATUS DROPDOWN (HIDE LAST)
                if (index != EquipmentPage.questions.length - 1)
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
                            SummaryLocalStorage
                                .equipmentAnswers[index]!["status"] = val!;
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
                    SummaryLocalStorage.equipmentAnswers[index]!["remarks"] =
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
                    SummaryLocalStorage.equipmentAnswers[index]!["action"] =
                        actionController.text;
                  },
                ),

                const SizedBox(height: 14),

                // IMAGE
                if (index != EquipmentPage.questions.length - 1) ...[
                  OutlinedButton(
                    onPressed: () => pickImage(index),
                    child: const Text("📸 Upload Image"),
                  ),

                  if (base64Image != null && base64Image.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Image.memory(
                        base64Decode(base64Image),
                        fit: BoxFit.contain, // SHOW FULL QUALITY
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

import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'summary_local_storage.dart';

class FacilityPage extends StatefulWidget {
  final String plantName;
  final String doneBy;
  final String date;

  static const List<String> questions = [
    "HVAC system operational, with filters inspected and logs updated.",
    "Drains covered, odor-free, and in good condition.",
    "Ceilings, walls, and floors intact (no cracks, leaks, or contamination risk).",
    "Lighting sufficient and fixtures intact (no glass hazard).",
    "Access doors and airlocks functioning correctly with no cross-contamination risk.",
    "Any open points you saw and requires attention:"
  ];

  const FacilityPage({
    super.key,
    required this.plantName,
    required this.doneBy,
    required this.date,
  });

  @override
  State<FacilityPage> createState() => _FacilityPageState();
}

class _FacilityPageState extends State<FacilityPage> {
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    SummaryLocalStorage.currentCategoryQuestions = FacilityPage.questions;

    for (int i = 0; i < FacilityPage.questions.length; i++) {
      SummaryLocalStorage.facilityAnswers[i] ??= {
        "status": "",
        "remarks": "",
        "action": "",
        "image": ""
      };
    }
  }

  int _countCompleted() {
    int count = 0;
    SummaryLocalStorage.facilityAnswers.forEach((key, value) {
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

      SummaryLocalStorage.facilityAnswers[index]!["image"] = base64img;

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
        iconTheme: const IconThemeData(color: Color(0xFF948A54)),
        title: Text(
          "🏭 Facility (${_countCompleted()}/${FacilityPage.questions.length})",
          style: const TextStyle(
            color: Color(0xFF948A54),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: FacilityPage.questions.length,
        itemBuilder: (context, index) {
          String q = FacilityPage.questions[index];
          String status =
              SummaryLocalStorage.facilityAnswers[index]?["status"] ?? "";

          TextEditingController remarksController = TextEditingController(
            text: SummaryLocalStorage.facilityAnswers[index]?["remarks"] ?? "",
          );

          TextEditingController actionController = TextEditingController(
            text: SummaryLocalStorage.facilityAnswers[index]?["action"] ?? "",
          );

          String? base64Image =
              SummaryLocalStorage.facilityAnswers[index]?["image"];

          return Container(
            margin: const EdgeInsets.only(bottom: 25),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF948A54), width: 2),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF948A54),
                  ),
                ),

                const SizedBox(height: 12),

                if (index != FacilityPage.questions.length - 1)
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
                                .facilityAnswers[index]!["status"] = val!;
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
                    SummaryLocalStorage.facilityAnswers[index]!["remarks"] =
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
                    SummaryLocalStorage.facilityAnswers[index]!["action"] =
                        actionController.text;
                  },
                ),

                const SizedBox(height: 14),

                if (index != FacilityPage.questions.length - 1) ...[
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

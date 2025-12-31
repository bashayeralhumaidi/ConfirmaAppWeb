import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'summary_local_storage.dart';

class WastePage extends StatefulWidget {
  final String plantName;
  final String doneBy;
  final String date;

  static const Map<String, List<String>> topics = {
    "Transportation": [
      "Material flows are direct, with no unnecessary movement between departments.",
      "Tools, materials, and documents are stored close to point of use.",
      "No double-handling of materials observed.",
      "Layout supports smooth flow with minimal backtracking.",
      "No unnecessary internal transport (forklifts, trolleys) without value."
    ],
    "Inventory": [
      "Raw materials, WIP, and finished goods are within defined min-max levels.",
      "No expired or obsolete stock visible.",
      "FIFO/FEFO followed properly.",
      "No excessive safety stock or over-ordering.",
      "Visual management (Kanban, labeling) in place for clear status."
    ],
    "Motion": [
      "Unnecessary walking or searching?",
      "Tools and equipment within arm’s reach.",
      "Workstations arranged logically for task sequence.",
      "No unnecessary operator walking between steps.",
      "Visual aids available to reduce unnecessary search or motion."
    ],
    "Waiting": [
      "No idle equipment or operators due to lack of materials, documents, or approvals.",
      "Changeover/setup time minimized and tracked.",
      "No bottlenecks at inspection or batch record reviews.",
      "Production not delayed due to equipment downtime.",
      "Parallel tasks executed where possible to reduce idle time."
    ],
    "Overproduction": [
      "No production beyond demand or batch requirements.",
      "No excess printing of labels, documents, or batch records.",
      "No unnecessary duplication of reports.",
      "Lines run strictly per production schedule.",
      "No “just in case” production."
    ],
    "Overprocessing": [
      "No redundant checks beyond regulatory/GMP needs.",
      "Processes standardized (no extra steps added by individuals).",
      "Documentation not duplicated in multiple places without need.",
      "No use of oversized/overcapacity equipment for small runs.",
      "Packaging/labelling done exactly as per requirement, not over-specified."
    ],
    "Defects": [
      "No rework or rejected material observed on shop floor.",
      "In-process checks done correctly to prevent downstream defects.",
      "Batch records accurate and error-free.",
      "No expired or mislabelled items present.",
      "Clear separation between good and rejected product."
    ],
    "Skills": [
      "Operators cross-trained and engaged in multiple tasks.",
      "Suggestions from staff encouraged and tracked.",
      "No highly skilled staff doing low-value repetitive tasks.",
      "Roles and responsibilities clearly defined.",
      "Training records updated and aligned with process needs."
    ]
  };

  const WastePage({
    super.key,
    required this.plantName,
    required this.doneBy,
    required this.date,
  });

  @override
  State<WastePage> createState() => _WastePageState();
}

class _WastePageState extends State<WastePage> {
  final ImagePicker picker = ImagePicker();

  int _countCompleted() {
  int count = 0;

  SummaryLocalStorage.wasteAnswers.forEach((topic, topicMap) {
    topicMap.forEach((index, record) {
      if ((record["status"] ?? "").toString().isNotEmpty) {
        count++;
      }
    });
  });

  return count;
}

int _totalQuestions() {
  int total = 0;
  WastePage.topics.forEach((topic, list) {
    total += list.length;
  });
  return total;
}

  @override
  void initState() {
    super.initState();

    WastePage.topics.forEach((topic, questions) {
      SummaryLocalStorage.wasteAnswers[topic] ??= {};

      for (int i = 0; i < questions.length; i++) {
        SummaryLocalStorage.wasteAnswers[topic]![i] ??= {
          "status": "",
          "remarks": "",
          "action": "",
          "image": ""
        };
      }
    });
  }

  Future<void> pickImage(String topic, int index) async {
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      Uint8List bytes = await file.readAsBytes();

      img.Image? original = img.decodeImage(bytes);
      img.Image resized = img.copyResize(
        original!,
        width: 150,
        height: 150,
      );

      Uint8List resizedBytes =
          Uint8List.fromList(img.encodeJpg(resized, quality: 95));

      String base64img = base64Encode(resizedBytes);

      SummaryLocalStorage.wasteAnswers[topic]![index]!["image"] = base64img;

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F1F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F1F8),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFE35AB0)),
        title: Text(
          "♻ Waste (${_countCompleted()}/${_totalQuestions()})",
          style: const TextStyle(
            color: Color(0xFFE35AB0),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: WastePage.topics.entries.map((entry) {
          String topic = entry.key;
          List<String> questions = entry.value;

          return ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE35AB0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                topic,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            children: [
              ...List.generate(questions.length, (index) {
                return _questionCard(topic, questions[index], index);
              })
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _questionCard(String topic, String question, int index) {
    final data = SummaryLocalStorage.wasteAnswers[topic]![index]!;

    TextEditingController remarksController =
        TextEditingController(text: data["remarks"]);

    TextEditingController actionController =
        TextEditingController(text: data["action"]);

    String status = data["status"] ?? "";
    String? base64Img = data["image"];

    bool isLast = index == WastePage.topics[topic]!.length - 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE35AB0), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE35AB0),
            ),
          ),

          const SizedBox(height: 10),

          if (!isLast)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.pink, width: 1),
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
                      SummaryLocalStorage.wasteAnswers[topic]![index]!["status"] =
                          val ?? "";
                    });
                  },
                ),
              ),
            ),

          const SizedBox(height: 12),

          TextField(
            controller: remarksController,
            decoration: const InputDecoration(
              labelText: "Remarks / Observations",
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (val) {
              SummaryLocalStorage.wasteAnswers[topic]![index]!["remarks"] = val;
            },
          ),

          const SizedBox(height: 12),

          TextField(
            controller: actionController,
            decoration: const InputDecoration(
              labelText: "Immediate Action Taken",
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (val) {
              SummaryLocalStorage.wasteAnswers[topic]![index]!["action"] = val;
            },
          ),

          const SizedBox(height: 10),

          if (!isLast) ...[
            OutlinedButton(
              onPressed: () => pickImage(topic, index),
              child: const Text("📸 Upload Image"),
            ),

            if (base64Img != null && base64Img.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Image.memory(
                  base64Decode(base64Img),
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
          ]
        ],
      ),
    );
  }
}

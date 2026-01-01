import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'HomePage02.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'SafetyPage.dart';
import 'CleanlinessPage.dart';
import 'summary_local_storage.dart';
import 'AccessControlPage.dart';
import 'EquipmentPage.dart';
import 'FacilityPage.dart';
import 'QualityPage.dart';
import 'WastePage.dart';

class DetailsCategories extends StatefulWidget {
  const DetailsCategories({super.key});

  @override
  State<DetailsCategories> createState() => _DetailsCategoriesState();
}

class _DetailsCategoriesState extends State<DetailsCategories> {
  final TextEditingController plantController = TextEditingController();
  final TextEditingController doneByController = TextEditingController();
  final TextEditingController otherPlantController = TextEditingController();

  String selectedPlant = "";
  String dateNow = DateTime.now().toString().split('.')[0];
  Timer? timer;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _startTimer();
  }

  void _startTimer() {
    SummaryLocalStorage.startTime ??= DateTime.now();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final diff = DateTime.now().difference(SummaryLocalStorage.startTime!);
      SummaryLocalStorage.timerText =
          "${diff.inHours.toString().padLeft(2, '0')}:"
          "${(diff.inMinutes % 60).toString().padLeft(2, '0')}:"
          "${(diff.inSeconds % 60).toString().padLeft(2, '0')}";

      if (mounted) setState(() {});
    });
  }

  // Future<void> _loadUser() async {
  //   //SharedPreferences prefs = await SharedPreferences.getInstance();
  //   //doneByController.text = prefs.getString("username") ?? "";
  // doneByController.text = "Bashayer-Friday-Test";
  // }
Future<void> _loadUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  doneByController.text = prefs.getString("user_name") ?? "";
}

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  bool validateInputs() {
    if (plantController.text.isEmpty || doneByController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please Select the Plant Name")),
      );
      return false;
    }
    return true;
  }

  // Counting Functions
  int _countCompleted(Map<int, Map<String, dynamic>> answers) {
    return answers.values
        .where((r) => (r["status"] ?? "").toString().isNotEmpty)
        .length;
  }

  int getSafetyCompleted() => _countCompleted(SummaryLocalStorage.safetyAnswers);
  int getCleanlinessCompleted() =>
      _countCompleted(SummaryLocalStorage.cleanlinessAnswers);
  int getQualityCompleted() =>
      _countCompleted(SummaryLocalStorage.qualityAnswers);
  int getFacilityCompleted() =>
      _countCompleted(SummaryLocalStorage.facilityAnswers);
  int getEquipmentCompleted() =>
      _countCompleted(SummaryLocalStorage.equipmentAnswers);
  int getAccessCompleted() =>
      _countCompleted(SummaryLocalStorage.accessAnswers);

  int getWasteCompleted() {
    int count = 0;
    SummaryLocalStorage.wasteAnswers.forEach((topic, topicMap) {
      topicMap.forEach((i, record) {
        if (i != WastePage.topics[topic]!.length - 1 &&
            (record["status"] ?? "").toString().isNotEmpty) {
          count++;
        }
      });
    });
    return count;
  }

  int getTotalWasteQuestions() {
    int total = 0;
    WastePage.topics.forEach((key, list) => total += list.length);
    return total;
  }

  bool hasAnyCategoryFilled() {
    return getSafetyCompleted() > 0 ||
        getCleanlinessCompleted() > 0 ||
        getQualityCompleted() > 0 ||
        getFacilityCompleted() > 0 ||
        getEquipmentCompleted() > 0 ||
        getAccessCompleted() > 0 ||
        getWasteCompleted() > 0;
  }

  Future<bool> saveToAPI(
    String categoryName,
    Map<int, Map<String, dynamic>> answers,
    List<String> questions, {
    String subCategory = "",
  }) async {
    final url = Uri.parse("https://confirmaapplication-bxfba9gybnhyfvcy.westeurope-01.azurewebsites.net/add_Confirma");

    final filteredRecords = answers.entries
        .where((e) => (e.value["status"] ?? "").toString().isNotEmpty)
        .map((e) {
      return {
        "PlantName": plantController.text,
        "ProcessConfirmationDoneBy": doneByController.text,
        "DateOfConfirmation": dateNow,
        "Category": categoryName,
        "Subcategories": subCategory,
        "Describe": questions[e.key],
        "Status": e.value["status"] ?? "",
        "RemarksObservations": e.value["remarks"] ?? "",
        "ImmediateActionTaken": e.value["action"] ?? "",
        "Timer": SummaryLocalStorage.timerText,
        "ImageData": e.value["image"] ?? "",
      };
    }).toList();

    if (filteredRecords.isEmpty) return false;

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"records": filteredRecords}),
    );

    return response.statusCode == 200;
  }

  Future<bool> checkLastSubmission() async {
    final url = Uri.parse("https://confirmaapplication-bxfba9gybnhyfvcy.westeurope-01.azurewebsites.net/check_last_submission");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "PlantName": plantController.text,
        "DoneBy": doneByController.text,
      }),
    );

    if (response.statusCode != 200) return true;

    final data = jsonDecode(response.body);

    if (data["hasRecord"] == false) return true;

    final lastDate = DateTime.parse(data["lastDate"]);
    final diff = DateTime.now().difference(lastDate).inDays;

    if (diff < 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "You already submitted for this plant. You cannot enter a new record within 7 days. Try again after ${7 - diff} days.",
          ),
        ),
      );
      return false;
    }

    return true;
  }

  void clearAllData() {
    SummaryLocalStorage.safetyAnswers.clear();
    SummaryLocalStorage.cleanlinessAnswers.clear();
    SummaryLocalStorage.qualityAnswers.clear();
    SummaryLocalStorage.facilityAnswers.clear();
    SummaryLocalStorage.equipmentAnswers.clear();
    SummaryLocalStorage.accessAnswers.clear();
    SummaryLocalStorage.wasteAnswers.clear();

    plantController.clear();
    otherPlantController.clear();
    selectedPlant = "";

    SummaryLocalStorage.startTime = DateTime.now();
    SummaryLocalStorage.timerText = "00:00:00";
  }

  Future<void> submitAll() async {
    if (isSubmitting) return; // prevent double click

    if (!validateInputs()) return;
    if (!await checkLastSubmission()) return;

    setState(() => isSubmitting = true);

    // Save categories
    bool okSafety = await saveToAPI(
        "Safety", SummaryLocalStorage.safetyAnswers, SafetyPage.questions);

    bool okClean = await saveToAPI(
        "Cleanliness",
        SummaryLocalStorage.cleanlinessAnswers,
        CleanlinessPage.questions);

    bool okQuality = await saveToAPI(
        "Quality Compliance",
        SummaryLocalStorage.qualityAnswers,
        QualityPage.questions);

    bool okFacility = await saveToAPI(
        "Facility",
        SummaryLocalStorage.facilityAnswers,
        FacilityPage.questions);

    bool okEquipment = await saveToAPI(
        "Equipment",
        SummaryLocalStorage.equipmentAnswers,
        EquipmentPage.questions);

    bool okAccess = await saveToAPI(
        "Access Control",
        SummaryLocalStorage.accessAnswers,
        AccessControlPage.questions);

    bool okWaste = false;
    for (var entry in WastePage.topics.entries) {
      String sub = entry.key;
      List<String> questions = entry.value;
      bool result = await saveToAPI(
        "Waste",
        SummaryLocalStorage.wasteAnswers[sub]!,
        questions,
        subCategory: sub,
      );
      if (result) okWaste = true;
    }

    bool success = okSafety ||
        okClean ||
        okQuality ||
        okFacility ||
        okEquipment ||
        okAccess ||
        okWaste;

    if (success) {
      timer?.cancel(); // stop timer before UI changes
      clearAllData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✔ Data Saved Successfully")),
      );

      // wait for snackbar to appear
      await Future.delayed(const Duration(milliseconds: 700));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage02()),
      );
    } else {
      setState(() => isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to Save Data")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF1F3),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset("assets/images/JulpharLogo.png", height: 45),
              const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text(
                "← Back",
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFFB30000),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

              const SizedBox(height: 20),

              TextField(
                controller: doneByController,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: "Process Confirmation Done By",
                  filled: true,
                  fillColor: Color(0xFFE0E0E0),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Choose a Category",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF002D72),
                ),
              ),

              const SizedBox(height: 25),

              // 🌱 PLANT NAME DROPDOWN
              DropdownButtonFormField(
                decoration: const InputDecoration(
                  labelText: "Plant Name",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                initialValue: selectedPlant.isEmpty ? null : selectedPlant,
                items: [
                  "Main QC",
                  "J3 QC",
                  "J9 QC",
                  "J1",
                  "J2",
                  "J3",
                  "J4",
                  "J5",
                  "J6",
                  "J7",
                  "J8",
                  "J9",
                  "J10",
                  "Other"
                ].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPlant = value!;
                    plantController.text = (value == "Other") ? "" : value;
                  });
                },
              ),

              if (selectedPlant == "Other") ...[
                const SizedBox(height: 15),
                TextField(
                  controller: otherPlantController,
                  decoration: const InputDecoration(
                    labelText: "Enter Plant Name",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (val) => plantController.text = val,
                ),
              ],

              const SizedBox(height: 25),

              _categoryButton(
                "🧯 Safety (${getSafetyCompleted()}/${SafetyPage.questions.length})",
                () => _openCategory(
                  SafetyPage(
                    plantName: plantController.text,
                    doneBy: doneByController.text,
                    date: dateNow,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              _categoryButton(
                "🧹 Cleanliness (${getCleanlinessCompleted()}/${CleanlinessPage.questions.length})",
                () => _openCategory(
                  CleanlinessPage(
                    plantName: plantController.text,
                    doneBy: doneByController.text,
                    date: dateNow,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              _categoryButton(
                "🧪 Quality Compliance (${getQualityCompleted()}/${QualityPage.questions.length})",
                () => _openCategory(
                  QualityPage(
                    plantName: plantController.text,
                    doneBy: doneByController.text,
                    date: dateNow,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              _categoryButton(
                "🏭 Facility (${getFacilityCompleted()}/${FacilityPage.questions.length})",
                () => _openCategory(
                  FacilityPage(
                    plantName: plantController.text,
                    doneBy: doneByController.text,
                    date: dateNow,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              _categoryButton(
                "🔧 Equipment (${getEquipmentCompleted()}/${EquipmentPage.questions.length})",
                () => _openCategory(
                  EquipmentPage(
                    plantName: plantController.text,
                    doneBy: doneByController.text,
                    date: dateNow,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              _categoryButton(
                "🔐 Access Control (${getAccessCompleted()}/${AccessControlPage.questions.length})",
                () => _openCategory(
                  AccessControlPage(
                    plantName: plantController.text,
                    doneBy: doneByController.text,
                    date: dateNow,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              _categoryButton(
                "♻️ Waste (${getWasteCompleted()}/${getTotalWasteQuestions()})",
                () => _openCategory(
                  WastePage(
                    plantName: plantController.text,
                    doneBy: doneByController.text,
                    date: dateNow,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (!hasAnyCategoryFilled() || isSubmitting)
                        ? Colors.grey
                        : Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: (!hasAnyCategoryFilled() || isSubmitting)
                      ? null
                      : submitAll,
                  child: Text(
                    isSubmitting ? "Submitting.. ✓" : "Submit",
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryButton(String title, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF003B9A),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onTap,
        child: Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }

  void _openCategory(Widget page) {
    if (!validateInputs()) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    ).then((_) => setState(() {}));
  }
}

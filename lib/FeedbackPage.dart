import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'HomePage02.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController personController = TextEditingController();
  final TextEditingController feedbackController = TextEditingController();
  String? selectedType;

  @override
  void initState() {
    super.initState();
    loadUserName();
  }

  Future<void> loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    personController.text = prefs.getString("user_name") ?? "";
  }

  Future<void> submitFeedback() async {
    final url = Uri.parse("http://132.220.216.47:8000/add_feedback");

    final payload = {
      "PersonName": personController.text,
      "FeedbackType": selectedType ?? "",
      "FeedbackText": feedbackController.text,
    };

    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Feedback Submitted")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage02()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF1F3),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              "assets/images/JulpharLogo.png",
              height: 45,
            ),
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
            Center(
              child: Image.asset(
                "assets/images/Logo_Confirma.png",
                height: 110,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Person Name",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF002D72),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: personController,
              enabled: false,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFFE0E0E0),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Feedback Type",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF002D72),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue, width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedType,
                  hint: const Text("Select feedback type"),
                  items: ["Complaint", "Inquiry", "Praise", "Suggestion"]
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedType = val;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Feedback",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF002D72),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: feedbackController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: "Write feedback here...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003B9A),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: submitFeedback,
                child: const Text(
                  "Submit",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


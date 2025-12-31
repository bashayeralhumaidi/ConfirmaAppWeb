import 'package:flutter/material.dart';
import 'FeedbackPage.dart';
import 'detailsCategories.dart';

class HomePage02 extends StatelessWidget {
  const HomePage02({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF1F3),

      body: SingleChildScrollView( // ✅ FIX
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // LEFT SIDE
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset("assets/images/JulpharLogo.png", height: 45),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003B9A),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FeedbackPage()),
                      );
                    },
                    child: const Text("Feedback", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Center(
                child: Column(
                  children: [
                    Image.asset("assets/images/Logo_Confirma.png", height: 110),
                    const SizedBox(height: 10),
                    const Text(
                      "Confirma",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF002D72),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "📘 Welcome to Confirma",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF002D72),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "🔍 Purpose of the App",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF002D72),
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "Confirma is designed to help you conduct quick and effective "
                "process confirmations across key operational areas. It ensures "
                "standard adherence, issue detection, and continuous improvement "
                "by allowing team members to log observations and take actions "
                "based on real-time plant conditions.",
                style: TextStyle(fontSize: 16, height: 1.4),
              ),

              const SizedBox(height: 20),

              const Text(
                "📁 Available Categories",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF002D72),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "In the next screen, you will be asked to choose from the following categories:",
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 10),

              const Text(
                "1. 🧯 Safety\n"
                "2. 🧹 Cleanliness\n"
                "3. 🧪 Quality Compliance\n"
                "4. 🏭 Facility\n"
                "5. 🔧 Equipment\n"
                "6. 🔐 Access Control\n"
                "7. ♻️ Waste",
                style: TextStyle(fontSize: 16, height: 1.4),
              ),

              const SizedBox(height: 40), // instead of Spacer()

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003B9A),
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DetailsCategories()),
                    );
                  },
                  child: const Text("Categories",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}

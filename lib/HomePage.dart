import 'package:flutter/material.dart';
import 'HomePage02.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF1F3),

      body: Stack(
        children: [
          // 🔷 TOP LEFT JULPHAR LOGO
          Positioned(
            top: 40,
            left: 20,
            child: Image.asset(
              "assets/images/JulpharLogo.png",
              height: 50,
            ),
          ),

          // 🔷 CENTER CONTENT – same width & alignment as LoginPage
          Center(
            child: SingleChildScrollView(
              child: SizedBox(
                width: 360, // SAME SIZE AS LOGIN PAGE
                child: Column(
                  children: [
                    const SizedBox(height: 80),

                    // 🔷 CENTER LOGO (same as login page)
                    Image.asset(
                      "assets/images/Logo_Confirma.png",
                      height: 120,
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      "Confirma",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003B9A),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Welcome to Confirma \n\n"
                      "Your smart compliance and process confirmation system.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        color: Color(0xFF2C3E50),
                      ),
                    ),

                    const SizedBox(height: 35),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003B9A),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomePage02()),
                          );
                        },
                        child: const Text(
                          "Start",
                          style: TextStyle(
                          color: Colors.white,
                          fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

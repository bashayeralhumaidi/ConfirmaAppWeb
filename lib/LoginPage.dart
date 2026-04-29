import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'HomePage.dart';
import 'global.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// ===================== LOGIN PAGE =====================
class _LoginPageState extends State<LoginPage> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;
  bool showPassword = false;
  String error = "";

  bool get canLogin =>
      idController.text.trim().isNotEmpty &&
      passwordController.text.trim().isNotEmpty;

  // ── Splash overlay state ──
  bool _showGif = false;   // GIF appears after 3 sec delay
  bool _showGemba = false; // Gemba image layer
  Timer? _gifTimer;

  @override
  void initState() {
    super.initState();
    idController.addListener(() => setState(() {}));
    passwordController.addListener(() => setState(() {}));

    // Show GIF in bottom-right after 3 seconds
    _gifTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showGif = true);
    });
  }

  @override
  void dispose() {
    _gifTimer?.cancel();
    idController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _advanceToGemba() {
    setState(() {
      _showGemba = true;
      // GIF stays visible — do NOT set _showGif = false
    });
  }

  void _closeOverlay() {
    setState(() {
      _showGemba = false;
      // GIF stays visible after closing Gemba too
    });
  }

  // ── Login logic ──
  Future<void> loginUser() async {
    setState(() {
      loading = true;
      error = "";
    });

    final url = Uri.parse('$apiBase/loginUserAccess');

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id": idController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 401) {
        setState(() => error = "Invalid ID or Password");
      } else if (res.statusCode != 200 || data["success"] != true) {
        setState(() => error = "Invalid ID or Password");
      } else {
        if (data.containsKey('token')) {
          await secureStorage.write(key: 'auth_token', value: data['token']);
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("user_id", data["user"]["id"].toString());
        await prefs.setString("user_name", data["user"]["name"]);
        await prefs.setString("user_level", data["user"]["level"]);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (_) {
      setState(() => error = "Network error");
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF1F3),
      body: Stack(
        children: [
          // ── Login form (always underneath) ──
          Center(
            child: SingleChildScrollView(
              child: SizedBox(
                width: 360,
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    Image.asset("assets/images/Logo_Confirma.png", height: 120),
                    const SizedBox(height: 30),
                    const Text(
                      "Welcome",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003B9A),
                      ),
                    ),
                    const SizedBox(height: 35),
                    TextField(
                      controller: idController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "User ID",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      obscureText: !showPassword,
                      decoration: InputDecoration(
                        hintText: "Password",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => showPassword = !showPassword);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    if (error.isNotEmpty)
                      Text(error,
                          style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 25),
                    if (canLogin)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003B9A),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: loading ? null : loginUser,
                          child: loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 3)
                              : const Text(
                                  "Sign In",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ChangePasswordPage()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side:
                              const BorderSide(color: Color(0xFF003B9A)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Change Password",
                          style: TextStyle(
                              fontSize: 15, color: Color(0xFF003B9A)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── GIF in bottom-right corner (tap → show Gemba) ──
          if (_showGif)
            Positioned(
              bottom: 24,
              right: 24,
              child: GestureDetector(
                onTap: _advanceToGemba,
                child: Image.asset(
                  "assets/images/Untitled design-3.gif",
                  width: 110,
                  height: 110,
                  fit: BoxFit.contain,
                ),
              ),
            ),

          // ── Gemba image overlay (close → login) ──
          if (_showGemba)
            _SplashLayer(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Image
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        "assets/images/03- Gemba Ask4Learn.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // Close button
                  Positioned(
                    top: 48,
                    right: 20,
                    child: GestureDetector(
                      onTap: _closeOverlay,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFF003B9A),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Full-screen semi-transparent layer ──
class _SplashLayer extends StatelessWidget {
  final Widget child;
  const _SplashLayer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.75),
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: Center(child: child),
      ),
    );
  }
}

// ======= CHANGE PASSWORD PAGE WITH FORGOT BUTTON =======
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController id = TextEditingController();
  final TextEditingController oldPass = TextEditingController();
  final TextEditingController newPass = TextEditingController();

  bool showOld = false;
  bool showNew = false;
  bool loading = false;
  String error = "";

  Future<void> changePassword() async {
    setState(() {
      loading = true;
      error = "";
    });

    final url = Uri.parse('$apiBase/changePassword');

    try {
      final token = await secureStorage.read(key: 'auth_token');
      final headers = {"Content-Type": "application/json"};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final res = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          "id": id.text.trim(),
          "old_password": oldPass.text.trim(),
          "new_password": newPass.text.trim(),
        }),
      );

      if (res.statusCode == 401) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
        return;
      }

      final data = jsonDecode(res.body);
      if (res.statusCode != 200 || data["success"] != true) {
        setState(() => error = "Invalid details");
      } else {
        Navigator.pop(context);
      }
    } catch (_) {
      setState(() => error = "Network error");
    }

    setState(() => loading = false);
  }

  Future<void> forgotPasswordRequest() async {
    if (id.text.trim().isEmpty) {
      setState(() => error = "Enter User ID first");
      return;
    }

    final url = Uri.parse('$apiBase/requestReset');

    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id": id.text.trim()}),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              "Request submitted. Password will be reset within 24 hours")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF1F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF003B9A),
        title: const Text("Change Password"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 360,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.asset("assets/images/Logo_Confirma.png", height: 110),
                const SizedBox(height: 25),
                const Text(
                  "Update Password",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003B9A)),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: id,
                  decoration: InputDecoration(
                    hintText: "User ID",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: oldPass,
                  obscureText: !showOld,
                  decoration: InputDecoration(
                    hintText: "Old Password",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      icon: Icon(showOld
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => showOld = !showOld),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: newPass,
                  obscureText: !showNew,
                  decoration: InputDecoration(
                    hintText: "New Password",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      icon: Icon(showNew
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => showNew = !showNew),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                if (error.isNotEmpty)
                  Text(error,
                      style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003B9A),
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: loading ? null : changePassword,
                    child: loading
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 3)
                        : const Text(
                            "Submit",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

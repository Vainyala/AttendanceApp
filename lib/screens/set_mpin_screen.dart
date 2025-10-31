import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetMPINScreen extends StatefulWidget {
  final String email;
  const SetMPINScreen({super.key, required this.email, required Map<String, dynamic> employeeData});

  @override
  State<SetMPINScreen> createState() => _SetMPINScreenState();
}

class _SetMPINScreenState extends State<SetMPINScreen> {
  final mpinController = TextEditingController();

  Future<void> saveMPIN() async {
    if (mpinController.text.length == 6) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('emailVerified', true); // ✅ mark email verified
      await prefs.setString('mpin', mpinController.text);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter 6-digit MPIN")),
      );
    }
  }

  void skipSetup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('emailVerified', true); // still mark as verified

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set MPIN")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Set 6-digit MPIN for quick login"),
            const SizedBox(height: 20),
            TextField(
              controller: mpinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: "Enter MPIN",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: saveMPIN, child: const Text("Save MPIN")),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: skipSetup,
                child: const Text("Skip", style: TextStyle(color: Colors.blue)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

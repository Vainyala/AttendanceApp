import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../services/email_service.dart';
import 'set_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}


class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  bool _isVerifying = false;

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter 6-digit OTP")),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      // TODO: Replace with actual OTP verification
      final isValid = await EmailService.verifyOTP(widget.email, otp);

      if (isValid && mounted) {
        // ✅ Fetch employee data after OTP verification
        final empData = await EmailService.getEmployeeData(widget.email);

        if (empData != null) {
          // ✅ Store employee data in SQLite
          await DatabaseHelper.instance.storeEmployeeData(empData);

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SetPasswordScreen(
                  email: widget.email,
                  employeeData: empData,
                ),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid OTP")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification failed: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OTP Verification")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enter OTP sent to\n${widget.email}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: const InputDecoration(
                labelText: "OTP",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isVerifying ? null : verifyOtp,
                child: _isVerifying
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text("Verify"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

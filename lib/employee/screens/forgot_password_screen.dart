import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:provider/provider.dart';
import '../providers/splash_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<SplashProvider>();
      final error = await provider.sendResetLink(_emailController.text);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(error == null ? 'Reset Link Sent' : 'Error'),
            content: Text(error ?? 'Password reset link has been sent to ${_emailController.text}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (error == null) Navigator.pop(context); // go back to login
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SplashProvider>(
      builder: (context, provider, child) {
        final isLoading = provider.isSendingReset;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Reset Password'),
            backgroundColor: const Color(0xFF4A5AE8),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF4A5AE8), Color(0xFF6C7CE7)],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_reset, size: 80, color: AppColors.textLight),
                        const SizedBox(height: 20),
                        const Text(
                          'Reset Password',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textLight),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Enter your email to receive reset link',
                          style: TextStyle(fontSize: 16, color: AppColors.cardBackground),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 50),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.textLight,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 5))],
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email Address',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  filled: true,
                                  fillColor: AppColors.textHint[50],
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Please enter your email';
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Please enter a valid email';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 30),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _resetPassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4A5AE8),
                                    foregroundColor: AppColors.textLight,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: isLoading
                                      ? const CircularProgressIndicator(color: AppColors.textLight)
                                      : const Text('Send Reset Link', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

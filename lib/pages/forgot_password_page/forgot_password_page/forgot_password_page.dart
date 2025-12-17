import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  final Color primaryColor = const Color(0xFF1EAE98);

  String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Enter your email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 50,
                ),
              ),
              onPressed: sendResetEmail,
              child: const Text("Send Reset Link"),
            ),

            if (message != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  message!,
                  style: const TextStyle(color: Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> sendResetEmail() async {
    await AuthService().sendPasswordResetEmail(emailController.text.trim());
    setState(() => message = "Password reset link sent to your email.");
  }
}

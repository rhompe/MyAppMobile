// lib/screens/verify_email_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mychatme/l10n/app_localizations.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  void _checkVerification(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.emailVerifiedSuccessfully)),
      );

      // Aquí puedes redirigir a la pantalla principal o de login
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.emailNotVerifiedYet)),
      );
    }
  }

  void _resendVerificationEmail(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.verificationEmailResent)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${t.errorResending}: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.email_outlined, size: 60, color: Colors.green),
                const SizedBox(height: 16),
                Text(
                  t.verifyYourEmail,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  t.verificationEmailSentToYou,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _checkVerification(context),
                  child: Text(t.alreadyVerifiedDemo),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  ),
                ),
                TextButton(
                  onPressed: () => _resendVerificationEmail(context),
                  child: Text(t.resendEmail),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
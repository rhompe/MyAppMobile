import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mychatme/l10n/app_localizations.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final TextEditingController emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
       // title: const Text("Recuperar contraseña"),
       title: Text(t.recoverPassword),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*const Text(
              "Ingresa tu correo para recibir un enlace para restablecer tu contraseña:",
              style: TextStyle(fontSize: 16),
            ),*/
            Text(
              t.enterEmailToResetPassword,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration:  InputDecoration(
                //labelText: "Correo electrónico",
                labelText: t.email,
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final email = emailController.text.trim();
                  if (email.isNotEmpty) {
                    FirebaseAuth.instance
                        .sendPasswordResetEmail(email: email)
                        .then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        /*const SnackBar(
                          content: Text(
                            "Se ha enviado un enlace a tu correo para restablecer la contraseña.",
                          ),*/
                          SnackBar(
                            content: Text(
                              t.passwordResetEmailSent,
                            ),
                          backgroundColor: Colors.green,
                        ),
                      );
                      // Regresa al login después de 2 segundos
                      Future.delayed(const Duration(seconds: 2), () {
                        Navigator.pop(context);
                      });
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error: ${error.toString()}"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      /*const SnackBar(
                        content: Text("Por favor ingresa un correo válido."),
                        backgroundColor: Colors.orange,
                      ),
                    );*/
                      SnackBar(
                        content: Text(t.pleaseEnterValidEmail),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                //child: const Text("Enviar enlace"),
                child: Text(t.sendLink),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

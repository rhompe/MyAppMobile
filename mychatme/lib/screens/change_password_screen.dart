import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mychatme/l10n/app_localizations.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  void _changePassword() async {
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showMessage("Por favor completa ambos campos.");
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage("Las contraseñas no coinciden.");
      return;
    }

    if (newPassword.length < 6) {
      _showMessage("La contraseña debe tener al menos 6 caracteres.");
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        _showMessage("Contraseña actualizada con éxito.");
        Navigator.pop(context);
      } else {
        _showMessage("No hay usuario autenticado.");
      }
    } catch (e) {
      _showMessage("Error: ${e.toString()}");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.deepPurple),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        //title:  Text("Cambiar contraseña"),
        title: Text(t.changePassword),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            /*const Text(
              "Ingresa y confirma tu nueva contraseña:",
              style: TextStyle(fontSize: 16),
            ),*/
            Text(
              t.enterAndConfirmNewPassword,
              style: TextStyle(fontSize: 16),
            ),
                  const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: !showNewPassword,
              decoration: InputDecoration(
                //labelText: "Nueva contraseña",
                labelText: t.newPassword,
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(showNewPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => showNewPassword = !showNewPassword),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: !showConfirmPassword,
              decoration: InputDecoration(
                //labelText: "Confirmar nueva contraseña",
                labelText: t.confirmNewPassword,
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(showConfirmPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => showConfirmPassword = !showConfirmPassword),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 169, 117, 179),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              //child: const Text("Cambiar contraseña"),
              child: Text(t.changePassword),
            ),
          ],
        ),
      ),
    );
  }
}

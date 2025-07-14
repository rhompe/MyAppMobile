import 'package:flutter/material.dart';
import 'package:mychatme/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mychatme/screens/verify_email_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mychatme/l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool showPassword = false;
  bool showConfirmPassword = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String selectedRole = 'user';

 /* void handleRegister() {
    if (_formKey.currentState!.validate()) {
      // Aquí se puede agregar lógica para guardar usuario (BD/Firebase)

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            userName: _nameController.text.trim(),
            userRole: selectedRole,
          ),
        ),
      );
    }
  }*/
  //Autenticacion cuenta
   void handleRegister() async {
    final t = AppLocalizations.of(context)!;
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.passwordsDontMatch)),
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.sendEmailVerification();

      //Agregar usuario a Firestone
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
      'uid': userCredential.user!.uid,
      'name': _nameController.text.trim(),
      'email': email,
      'role': selectedRole,
      'createdAt': Timestamp.now(),
    });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.verificationEmailSent)),
      );

      // Navegar a pantalla para verificar email
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => VerifyEmailScreen()),
      );

    } on FirebaseAuthException catch (e) {
      String message = t.errorRegisteringUser;
      if (e.code == 'email-already-in-use') {
        message = t.emailAlreadyInUse;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }



  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        title: Text(t.createAccount),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                t.createYourNewAccount,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Nombre
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: t.name,
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? t.requiredField : null,
              ),

              const SizedBox(height: 16),

              // Correo
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: t.email,
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? t.requiredField : null,
              ),

              const SizedBox(height: 16),

              // Contraseña
              TextFormField(
                controller: _passwordController,
                obscureText: !showPassword,
                decoration: InputDecoration(
                  labelText: t.password,
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => showPassword = !showPassword),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => value!.length < 6 ? t.minimumSixCharacters : null,
              ),

              const SizedBox(height: 16),

              // Confirmar contraseña
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !showConfirmPassword,
                decoration: InputDecoration(
                  labelText: t.confirmPassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => showConfirmPassword = !showConfirmPassword),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => value != _passwordController.text
                    ? t.passwordsDontMatch
                    : null,
              ),

              const SizedBox(height: 16),

              // Rol
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: [
                  DropdownMenuItem(value: "user", child: Text(t.user)),
                  DropdownMenuItem(value: "admin", child: Text(t.administrator)),
                ],
                onChanged: (value) => setState(() => selectedRole = value!),
                decoration: InputDecoration(
                  labelText: t.role,
                  prefixIcon: Icon(Icons.person_add),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              // Botón de crear cuenta
              ElevatedButton(
                onPressed: handleRegister,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color.fromARGB(255, 169, 117, 179),
                ),
                child: Text(t.createAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
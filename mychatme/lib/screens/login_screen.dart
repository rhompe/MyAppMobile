import 'package:flutter/material.dart';
import 'package:mychatme/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mychatme/screens/register_screen.dart';
import 'package:mychatme/services/auth_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mychatme/screens/forgot_password_screen.dart';
import 'package:mychatme/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showPassword = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();


  void handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
     final t = AppLocalizations.of(context)!;

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print("Usuario autenticado: ${userCredential.user?.email}");
      // Navegar a HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            //userName: userCredential.user?.email ?? 'Usuario',
            userName: userCredential.user?.email ?? t.user,
            userRole: 'user', // O administra el rol 
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      /*String message = "Error en la autenticación";
      if (e.code == 'user-not-found') {
        message = "No existe usuario con ese correo.";
      } else if (e.code == 'wrong-password') {
        message = "Contraseña incorrecta.";
      }*/
      String message = t.authenticationError;
      if (e.code == 'user-not-found') {
        message = t.userNotFound;
      } else if (e.code == 'wrong-password') {
        message = t.wrongPassword;
      } else if (e.code == 'invalid-email') {
        message = t.invalidEmail;
      } else if (e.code == 'user-disabled') {
        message = t.userDisabled;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void handleGoogleSignIn() async {
     final t = AppLocalizations.of(context)!;
    final userCredential = await AuthService().signInWithGoogle();
  
    if (userCredential != null) {
      final user = userCredential.user!;
      //final name = user.displayName ?? "Usuario Google";
      final name = user.displayName ?? t.googleUser;
      final role = "user"; //roles

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            userName: name,
            userRole: role,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        //const SnackBar(content: Text("Inicio de sesión con Google fallido")),
        SnackBar(content: Text(t.googleSignInFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        //title: const Text("Iniciar Sesión"),
        title: Text(t.login),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.enterYourAccount, // o la clave que prefieras
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

             // Botón Google
            ElevatedButton.icon(
              onPressed: handleGoogleSignIn,
              icon: SvgPicture.asset(
                'assets/images/google_logo.svg',
                height: 24,
                width: 24,
              ),
              //label: const Text("Iniciar con Google"),
              label: Text(t.signInWithGoogle),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),

            const SizedBox(height: 24),

            // Email
            TextField(
              controller: _emailController,
              decoration:  InputDecoration(
                //labelText: "Correo electrónico",
                labelText: t.email,
                prefixIcon: Icon(Icons.mail),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            // Password
            TextField(
              controller: _passwordController,
              obscureText: !showPassword,
              decoration: InputDecoration(
                //labelText: "Contraseña",
                labelText: t.password,
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                      showPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () =>
                      setState(() => showPassword = !showPassword),
                ),
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: () {
                // lógica para recuperar contraseña
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                );
              },
              //child: const Text("¿Olvidaste tu contraseña?"),
              child: Text(t.forgotPassword),
            ),

            const SizedBox(height: 16),

            // Botón iniciar sesión con correo y contraseña
            ElevatedButton(
              onPressed: handleLogin,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color.fromARGB(255, 169, 117, 179),
              ),
              //child: const Text("Iniciar sesión"),
              child: Text(t.signIn),
            ),

            const SizedBox(height: 24),

            // Link a registro
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //const Text("¿No tienes una cuenta?"),
                Text(t.dontHaveAccount),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    );
                  },
                  //child: const Text("Regístrate"),
                  child: Text(t.signUp),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
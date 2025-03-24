import 'package:flutter/material.dart';
import 'package:rentify/auth_service.dart';
import 'package:rentify/presentation/pages/onboarding_page.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _signUp() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    var user = await _authService.signUp(email, password);

    if (user != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OnboardingPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signup Failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _signUp, child: Text("Sign Up")),
          ],
        ),
      ),
    );
  }
}

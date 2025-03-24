// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:rentify/auth_service.dart';
// import 'signup_screen.dart';
// import 'package:rentify/presentation/pages/onboarding_page.dart';
// // ...rest of your code remains the same...

// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final AuthService _authService = AuthService();

//   void _login() async {
//     String email = emailController.text.trim();
//     String password = passwordController.text.trim();
//     var user = await _authService.signIn(email, password);

//     if (user != null) {
//       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OnboardingPage()));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Failed")));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Login")),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
//             TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
//             SizedBox(height: 20),
//             ElevatedButton(onPressed: _login, child: Text("Login")),
//             TextButton(
//               onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen())),
//               child: Text("Don't have an account? Sign up"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

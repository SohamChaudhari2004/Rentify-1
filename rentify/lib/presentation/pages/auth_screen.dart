// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:rentify/presentation/pages/onboarding_page.dart';

// class AuthScreen extends StatefulWidget {
//   const AuthScreen({super.key});

//   @override
//   State<AuthScreen> createState() => _AuthScreenState();
// }

// class _AuthScreenState extends State<AuthScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//   bool _isLoading = false;

//   Future<void> _handleGoogleSignIn() async {
//     try {
//       setState(() => _isLoading = true);

//       // Start the Google sign-in process
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) return;

//       // Get authentication details
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

//       // Create credentials
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       // Sign in to Firebase
//       await _auth.signInWithCredential(credential);

//       // Navigate to onboarding page on success
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const OnboardingPage()),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Sign in failed: ${e.toString()}')),
//       );
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Onboarding page with reduced opacity
//           const Opacity(
//             opacity: 0.3,
//             child: OnboardingPage(),
//           ),
          
//           // Auth content
//           Center(
//             child: Card(
//               margin: const EdgeInsets.symmetric(horizontal: 32),
//               child: Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text(
//                       'Welcome to Rentify',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 32),
//                     ElevatedButton(
//                       onPressed: _isLoading ? null : _handleGoogleSignIn,
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 24,
//                           vertical: 12,
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Image.asset(
//                             'assets/google_logo.png',
//                             height: 24,
//                           ),
//                           const SizedBox(width: 12),
//                           _isLoading
//                               ? const CircularProgressIndicator()
//                               : const Text('Sign in with Google'),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
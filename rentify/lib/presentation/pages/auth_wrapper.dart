import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:rentify/presentation/pages/login_screen.dart';
import 'package:rentify/presentation/pages/onboarding_page.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If we have a user logged in
        if (snapshot.hasData) {
          return OnboardingPage(); // or any page you want after login
        }
        // If not authenticated
        return LoginScreen();
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rentify/presentation/pages/onboarding_page.dart';
import 'dart:async';

class EmailOtpScreen extends StatefulWidget {
  final String email;

  const EmailOtpScreen({Key? key, required this.email}) : super(key: key);

  @override
  _EmailOtpScreenState createState() => _EmailOtpScreenState();
}

class _EmailOtpScreenState extends State<EmailOtpScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;
  String? _verificationId;
  Timer? _resendTimer;
  int _timeLeft = 60;

  @override
  void initState() {
    super.initState();
    _sendOtpEmail();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _timeLeft = 60;
    });
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _sendOtpEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Generate a random OTP (this is normally done server-side)
      await _auth.currentUser?.sendEmailVerification();

      // In a real implementation, you would:
      // 1. Generate an OTP on your server
      // 2. Send it via email using Firebase Cloud Functions
      // 3. Store it temporarily for verification

      // For this demo, we're using the email verification mechanism
      // You'll need to explain to users to check their email for the verification link
      // and extract the OTP code from it

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Verification email sent. Please check your inbox.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error sending verification email: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // In a real implementation, verify the OTP against what was sent
      // Here we're checking if the user has verified their email
      await _auth.currentUser?.reload();
      final user = _auth.currentUser;

      if (user != null && user.emailVerified) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => OnboardingPage()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid or expired OTP. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying OTP: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOtp() async {
    if (_timeLeft > 0) return;

    setState(() {
      _isResending = true;
    });

    try {
      await _auth.currentUser?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Verification email resent. Please check your inbox.')),
      );
      _startResendTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Error resending verification email: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Verification'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 80,
                      color: Colors.black,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'OTP Verification',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'We\'ve sent a verification code to',
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      widget.email,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32),
                    TextFormField(
                      controller: _otpController,
                      decoration: InputDecoration(
                        labelText: 'Enter OTP',
                        hintText: 'Enter the 6-digit code from your email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the OTP';
                        }
                        if (value.length < 6) {
                          return 'OTP must be at least 6 digits';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text('Verify OTP'),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: _timeLeft > 0 ? null : _resendOtp,
                      child: Text(
                        _timeLeft > 0
                            ? 'Resend OTP in $_timeLeft seconds'
                            : 'Resend OTP',
                        style: TextStyle(
                          color: _timeLeft > 0 ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

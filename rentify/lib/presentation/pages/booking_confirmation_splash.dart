import 'package:flutter/material.dart';
import 'dart:async';
import 'package:rentify/data/models/car.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingConfirmationSplash extends StatefulWidget {
  final Car car;

  const BookingConfirmationSplash({Key? key, required this.car})
      : super(key: key);

  @override
  _BookingConfirmationSplashState createState() =>
      _BookingConfirmationSplashState();
}

class _BookingConfirmationSplashState extends State<BookingConfirmationSplash> {
  @override
  void initState() {
    super.initState();

    // Save booking to Firebase
    _saveBookingToFirebase();

    // Set timer for splash screen
    Timer(const Duration(seconds: 3), () {
      Navigator.pop(
          context, true); // Return true to indicate booking was completed
    });
  }

  Future<void> _saveBookingToFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Add the booking record to Firestore
        await FirebaseFirestore.instance.collection('bookings').add({
          'userId': user.uid,
          'carModel': widget.car.model,
          'carDistance': widget.car.distance,
          'carFuelCapacity': widget.car.fuelCapacity,
          'carPricePerHour': widget.car.pricePerHour,
          'bookingTime': FieldValue.serverTimestamp(),
        });

        // Update user document with booked car
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'bookedCars': FieldValue.arrayUnion([widget.car.model])
        });
      }
    } catch (e) {
      print('Error saving booking: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 30),
            Text(
              'Cab Booked!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Enjoy your ride',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.car.model,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

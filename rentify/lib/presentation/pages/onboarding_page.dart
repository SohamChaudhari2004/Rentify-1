import 'package:flutter/material.dart';
import 'package:rentify/presentation/pages/car_list_screen.dart';
import 'package:rentify/presentation/pages/profile_page.dart';
import 'package:rentify/presentation/pages/weather_page.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  bool _isProcessingTilt = false;
  String _tiltMessage = "Tilt left for Weather, right for Car Booking";
  
  @override
  void initState() {
    super.initState();
    _startListeningToAccelerometer();
  }
  
  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }
  
  void _startListeningToAccelerometer() {
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      _processAccelerometerData(event);
    });
  }
  
  void _processAccelerometerData(AccelerometerEvent event) {
    if (_isProcessingTilt) return;
    
    // Threshold values may need adjustment based on device sensitivity
    if (event.x < -3.0) {  // Left tilt threshold
      _isProcessingTilt = true;
      setState(() {
        _tiltMessage = "Left tilt detected - Opening Weather";
      });
      _navigateToWeather();
    } else if (event.x > 3.0) {  // Right tilt threshold
      _isProcessingTilt = true;
      setState(() {
        _tiltMessage = "Right tilt detected - Booking a Car";
      });
      _navigateToCarList();
    }
  }
  
  void _navigateToWeather() {
    Timer(Duration(milliseconds: 500), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WeatherPage()),
      );
      
      // Reset after navigation
      Timer(Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _tiltMessage = "Tilt left for Weather, right for Car Booking";
            _isProcessingTilt = false;
          });
        }
      });
    });
  }
  
  void _navigateToCarList() {
    Timer(Duration(milliseconds: 500), () {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => CarListScreen()),
        (route) => false,
      );
      
      // Reset after navigation
      Timer(Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _tiltMessage = "Tilt left for Weather, right for Car Booking";
            _isProcessingTilt = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2C2B34),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/onboarding.png'),
                          fit: BoxFit.cover)),
                ),
              ),
              Expanded(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Premium cars. \nEnjoy the luxury',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Premium and prestige car daily rental. \nExperience the thrill at a lower price',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      // SizedBox(
                      //   height: 10,
                      // ),
                      // Tilt instruction text
                      // Text(
                      //   _tiltMessage,
                      //   style: TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold),
                      // ),
                      // SizedBox(
                      //   height: 10,
                      // ),
                      SizedBox(
                        width: 320,
                        height: 54,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => CarListScreen()),
                                  (route) => false);
                            },
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Book A Car',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward),
                              ],
                            )),
                      ),
                      // Weather button
                      SizedBox(height: 12),
                      SizedBox(
                        width: 320,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WeatherPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.transparent,
                            side: BorderSide(color: Colors.white),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Check the Weather',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.wb_sunny),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          // Profile button in top-left
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 24,
                child: IconButton(
                  icon: Icon(Icons.person, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

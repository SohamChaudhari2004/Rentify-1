import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentify/data/models/car.dart';
// import 'package:rentify/presentation/bloc/car_bloc.dart';
// import 'package:rentify/presentation/bloc/car_state.dart';
import 'package:rentify/presentation/widgets/car_card.dart';
import 'package:rentify/presentation/pages/onboarding_page.dart'; // Add this import

class CarListScreen extends StatelessWidget {
final List<Car> cars = [
    Car(
        model: 'Toyota Fortuner GR',
        distance: 870,
        fuelCapacity: 80,
        pricePerHour: 45),
    Car(
        model: 'Tesla Model 3',
        distance: 1200,
        fuelCapacity: 75, // kWh battery capacity
        pricePerHour: 60),
    Car(
        model: 'BMW X5',
        distance: 950,
        fuelCapacity: 85,
        pricePerHour: 75),
    Car(
        model: 'Honda Civic',
        distance: 1100,
        fuelCapacity: 47,
        pricePerHour: 30),
    Car(
        model: 'Mercedes-Benz C-Class',
        distance: 980,
        fuelCapacity: 66,
        pricePerHour: 65),
    Car(
        model: 'Audi Q7',
        distance: 920,
        fuelCapacity: 85,
        pricePerHour: 70),
    Car(
        model: 'Lamborghini Urus',
        distance: 780,
        fuelCapacity: 85,
        pricePerHour: 150),
    Car(
        model: 'Ford Mustang GT',
        distance: 850,
        fuelCapacity: 61,
        pricePerHour: 55),
    Car(
        model: 'Porsche 911',
        distance: 820,
        fuelCapacity: 64,
        pricePerHour: 120),
    Car(
        model: 'Range Rover Sport',
        distance: 890,
        fuelCapacity: 86,
        pricePerHour: 90),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OnboardingPage()),
            ),
          ),
          title: Text('Choose Your Car'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: ListView.builder(
          itemCount: cars.length,
          itemBuilder: (context, index) {
            return CarCard(car: cars[index]);
          },
        ));
  }
}

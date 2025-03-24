import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentify/data/models/car.dart';
// import 'package:rentify/presentation/bloc/car_bloc.dart';
// import 'package:rentify/presentation/bloc/car_state.dart';
import 'package:rentify/presentation/widgets/car_card.dart';

class CarListScreen extends StatelessWidget {

  final List<Car> cars = [
    Car(model:'fortuner GR', distance: 870, fuelCapacity: 50, pricePerHour: 45),
    Car(model:'fortuner GR', distance: 870, fuelCapacity: 50, pricePerHour: 45),
    Car(model:'fortuner GR', distance: 870, fuelCapacity: 50, pricePerHour: 45),
  ];
  
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Your Car'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body:ListView.builder(
        itemCount: cars.length,
        itemBuilder: (context, index) {
          return CarCard(car: cars[index]);
        },
      )
    );
  }
}
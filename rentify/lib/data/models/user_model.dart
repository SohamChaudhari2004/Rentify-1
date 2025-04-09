import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String? dateOfBirth;
  final String? driverLicenseNumber;
  final String? driverLicenseUrl;
  final String? governmentIdUrl;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? alternateAddress;
  final List<String>? bookedCars;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.dateOfBirth,
    this.driverLicenseNumber,
    this.driverLicenseUrl,
    this.governmentIdUrl,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.alternateAddress,
    this.bookedCars,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'driverLicenseNumber': driverLicenseNumber,
      'driverLicenseUrl': driverLicenseUrl,
      'governmentIdUrl': governmentIdUrl,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'alternateAddress': alternateAddress,
      'bookedCars': bookedCars ?? [],
    };
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rentify/data/models/user_model.dart';
import 'package:rentify/presentation/pages/onboarding_page.dart';

class KYCDetailsScreen extends StatefulWidget {
  final UserModel basicUserInfo;

  const KYCDetailsScreen({Key? key, required this.basicUserInfo})
      : super(key: key);

  @override
  _KYCDetailsScreenState createState() => _KYCDetailsScreenState();
}

class _KYCDetailsScreenState extends State<KYCDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _imagePicker = ImagePicker();

  // Form controllers
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _alternateAddressController =
      TextEditingController();

  // Image files - we'll store base64 strings in Firestore since we don't have Firebase Storage
  XFile? _licenseImage;
  XFile? _governmentIdImage;

  bool _isLoading = false;
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Your Profile'),
        backgroundColor: Colors.black,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 1) {
                  setState(() {
                    _currentStep += 1;
                  });
                } else {
                  _submitKYCDetails();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() {
                    _currentStep -= 1;
                  });
                }
              },
              controlsBuilder: (context, details) {
                return Row(
                  children: [
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_currentStep < 1 ? 'Next' : 'Submit'),
                    ),
                    SizedBox(width: 12),
                    if (_currentStep > 0)
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: Text('Back'),
                      ),
                  ],
                );
              },
              steps: [
                Step(
                  title: Text('Identity Information'),
                  content: _buildIdentityForm(),
                  isActive: _currentStep >= 0,
                ),
                Step(
                  title: Text('Address Information'),
                  content: _buildAddressForm(),
                  isActive: _currentStep >= 1,
                ),
              ],
            ),
    );
  }

  Widget _buildIdentityForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date of Birth field with date picker
          TextFormField(
            controller: _dobController,
            decoration: InputDecoration(
              labelText: 'Date of Birth *',
              hintText: 'YYYY-MM-DD',
              suffixIcon: IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
            ),
            validator: _validateDateOfBirth,
            readOnly: true,
          ),
          SizedBox(height: 16),

          // Driver's License Number
          TextFormField(
            controller: _licenseController,
            decoration: InputDecoration(
              labelText: 'Driver\'s License Number *',
              hintText: 'Enter your driver\'s license number',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your driver\'s license number';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          // ADD THESE SECTIONS BACK - Driver's License Image Upload
          Text('Driver\'s License Image (Optional)'),
          SizedBox(height: 8),
          _buildImageUploadButton(
            label: 'Upload Driver\'s License',
            imageFile: _licenseImage,
            onPressed: () => _pickImage(isLicense: true),
          ),
          SizedBox(height: 16),

          // ADD THESE SECTIONS BACK - Government ID Upload
          Text('Government ID (Aadhaar/PAN/Passport) (Optional)'),
          SizedBox(height: 8),
          _buildImageUploadButton(
            label: 'Upload Government ID',
            imageFile: _governmentIdImage,
            onPressed: () => _pickImage(isLicense: false),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Residential Address
        TextFormField(
          controller: _addressController,
          decoration: InputDecoration(
            labelText: 'Residential Address *',
            hintText: 'Enter your full residential address',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your address';
            }
            return null;
          },
          maxLines: 2,
        ),
        SizedBox(height: 16),

        // City
        TextFormField(
          controller: _cityController,
          decoration: InputDecoration(
            labelText: 'City *',
            hintText: 'Enter your city',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your city';
            }
            return null;
          },
        ),
        SizedBox(height: 16),

        // Row for State and ZIP
        Row(
          children: [
            // State
            Expanded(
              child: TextFormField(
                controller: _stateController,
                decoration: InputDecoration(
                  labelText: 'State *',
                  hintText: 'State',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 16),

            // ZIP Code
            Expanded(
              child: TextFormField(
                controller: _zipCodeController,
                decoration: InputDecoration(
                  labelText: 'ZIP Code *',
                  hintText: 'ZIP Code',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        // Alternative Pickup/Drop Address (Optional)
        TextFormField(
          controller: _alternateAddressController,
          decoration: InputDecoration(
            labelText: 'Alternative Pickup/Drop Address (Optional)',
            hintText: 'Enter an alternative address if needed',
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildImageUploadButton({
    required String label,
    required XFile? imageFile,
    required VoidCallback onPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(Icons.upload_file),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        if (imageFile != null)
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.file(
              File(imageFile.path),
              fit: BoxFit.cover,
            ),
          ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime(DateTime.now().year - 18), // Default to 18 years ago
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickImage({required bool isLicense}) async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (isLicense) {
          _licenseImage = pickedFile;
        } else {
          _governmentIdImage = pickedFile;
        }
      });
    }
  }

  String? _validateDateOfBirth(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your date of birth';
    }

    try {
      final dob = DateFormat('yyyy-MM-dd').parse(value);
      final today = DateTime.now();
      final difference = today.difference(dob);
      final age = difference.inDays ~/ 365;

      if (age < 18) {
        return 'You must be at least 18 years old';
      }
      return null;
    } catch (e) {
      return 'Invalid date format';
    }
  }

  Future<void> _submitKYCDetails() async {
    // Basic validation for required fields
    if (_formKey.currentState?.validate() != true) {
      setState(() {
        _currentStep = 0; // Go back to first step if validation fails
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = widget.basicUserInfo.uid;

      // Update user document with all KYC details
      final updatedUserData = {
        'dateOfBirth': _dobController.text,
        'driverLicenseNumber': _licenseController.text,
        'driverLicenseUrl': _licenseImage?.path ?? '', // Optional now
        'governmentIdUrl': _governmentIdImage?.path ?? '', // Optional now
        'address': _addressController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'zipCode': _zipCodeController.text,
        'alternateAddress': _alternateAddressController.text,
        'kycCompleted': true,
      };

      // Update user document in Firestore
      await _firestore.collection('users').doc(userId).update(updatedUserData);

      // Navigate to onboarding page
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => OnboardingPage()));
    } catch (e) {
      print('Error submitting KYC details: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error submitting details. Please try again.')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _dobController.dispose();
    _licenseController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _alternateAddressController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:rentify/data/models/car.dart';
import 'package:rentify/presentation/pages/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import 'package:universal_html/html.dart' as html;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  // Controllers for editable fields
  late TextEditingController _fullNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _dobController;
  late TextEditingController _licenseController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipCodeController;
  late TextEditingController _alternateAddressController;

  String? _email;
  String? _profileImagePath;
  File? _imageFile;
  Uint8List? _webImage; // For web platform
  bool _isImageProcessing = false;
  List<Map<String, dynamic>> _bookedCars = [];
  bool _isLoading = true;
  bool _isEditing = false; // Track if user is in edit mode

  @override
  void initState() {
    super.initState();
    // Initialize controllers
    _fullNameController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _dobController = TextEditingController();
    _licenseController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _zipCodeController = TextEditingController();
    _alternateAddressController = TextEditingController();

    _loadUserData();
  }

  @override
  void dispose() {
    // Dispose controllers
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _dobController.dispose();
    _licenseController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _alternateAddressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = _auth.currentUser;

      if (user != null) {
        // Get user profile data
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;

          // Set controller values
          _fullNameController.text = userData['fullName'] ?? '';
          _phoneNumberController.text = userData['phoneNumber'] ?? '';
          _dobController.text = userData['dateOfBirth'] ?? '';
          _licenseController.text = userData['driverLicenseNumber'] ?? '';
          _addressController.text = userData['address'] ?? '';
          _cityController.text = userData['city'] ?? '';
          _stateController.text = userData['state'] ?? '';
          _zipCodeController.text = userData['zipCode'] ?? '';
          _alternateAddressController.text = userData['alternateAddress'] ?? '';

          setState(() {
            _email = userData['email'];
            _profileImagePath = userData['profileImagePath'];

            // If it's a web image stored as base64
            if (userData['isWebImage'] == true && _profileImagePath != null) {
              _webImage = base64Decode(_profileImagePath!);
            }
          });
        }

        // Get booked cars
        QuerySnapshot bookingsSnapshot = await _firestore
            .collection('bookings')
            .where('userId', isEqualTo: user.uid)
            .get();

        List<Map<String, dynamic>> bookedCars = [];
        for (var doc in bookingsSnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          bookedCars.add({
            'model': data['carModel'],
            'pricePerHour': data['carPricePerHour'],
            'distance': data['carDistance'],
            'fuelCapacity': data['carFuelCapacity'],
            'bookingTime': data['bookingTime'],
          });
        }

        setState(() {
          _bookedCars = bookedCars;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile data')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          // Handle web platform
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImage = bytes;
          });

          if (_isEditing) {
            await _saveImage();
          }
        } else {
          // Handle mobile platform
          setState(() {
            _imageFile = File(pickedFile.path);
          });

          if (_isEditing) {
            await _saveImage();
          }
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image')),
      );
    }
  }

  Future<void> _saveImage() async {
    setState(() {
      _isImageProcessing = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      if (kIsWeb) {
        // For web platform - store base64 encoded image in Firestore
        if (_webImage != null) {
          final base64Image = base64Encode(_webImage!);
          await _firestore.collection('users').doc(user.uid).update({
            'profileImagePath': base64Image,
            'isWebImage': true,
          });

          setState(() {
            _profileImagePath = base64Image;
          });
        }
      } else {
        // For mobile - save to local storage
        if (_imageFile != null) {
          // Get app document directory
          final directory = await getApplicationDocumentsDirectory();

          // Create a profile images directory if it doesn't exist
          final profileDir = Directory('${directory.path}/profile_images');
          if (!await profileDir.exists()) {
            await profileDir.create(recursive: true);
          }

          // Create unique filename
          final fileName =
              'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}${path.extension(_imageFile!.path)}';
          final localPath = '${profileDir.path}/$fileName';

          // Copy the file to our app directory
          final File localImage = await _imageFile!.copy(localPath);

          // Update Firestore with local path
          await _firestore.collection('users').doc(user.uid).update({
            'profileImagePath': localPath,
            'isWebImage': false,
          });

          setState(() {
            _profileImagePath = localPath;
            _imageFile = null; // Clear temporary file
          });
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile picture updated successfully')),
      );
    } catch (e) {
      print('Error saving image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile picture')),
      );
    } finally {
      setState(() {
        _isImageProcessing = false;
      });
    }
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = _auth.currentUser;

      if (user != null) {
        // Create updated user data map
        Map<String, dynamic> updatedData = {
          'fullName': _fullNameController.text,
          'phoneNumber': _phoneNumberController.text,
          'dateOfBirth': _dobController.text,
          'driverLicenseNumber': _licenseController.text,
          'address': _addressController.text,
          'city': _cityController.text,
          'state': _stateController.text,
          'zipCode': _zipCodeController.text,
          'alternateAddress': _alternateAddressController.text,
        };

        // Update Firestore
        await _firestore.collection('users').doc(user.uid).update(updatedData);

        // Save profile image if needed
        if ((kIsWeb && _webImage != null) || (!kIsWeb && _imageFile != null)) {
          await _saveImage();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );

        // Exit edit mode
        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      print('Error signing out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out. Please try again.')),
      );
    }
  }

  // Select date using date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dobController.text.isNotEmpty
          ? DateFormat('yyyy-MM-dd').parse(_dobController.text)
          : DateTime(DateTime.now().year - 18),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Widget _getProfileImage() {
    if (_isImageProcessing) {
      return CircularProgressIndicator();
    }

    if (kIsWeb) {
      // Web platform image handling
      if (_webImage != null) {
        // Show newly selected image
        return Image.memory(
          _webImage!,
          fit: BoxFit.cover,
        );
      } else if (_profileImagePath != null && _profileImagePath!.isNotEmpty) {
        // Try to show saved base64 image
        try {
          final imageBytes = base64Decode(_profileImagePath!);
          return Image.memory(
            imageBytes,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading profile image: $error');
              return _buildDefaultAvatar();
            },
          );
        } catch (e) {
          print('Error decoding base64 image: $e');
          return _buildDefaultAvatar();
        }
      }
    } else {
      // Mobile platform image handling
      if (_imageFile != null) {
        // Show newly selected image
        return Image.file(
          _imageFile!,
          fit: BoxFit.cover,
        );
      } else if (_profileImagePath != null && _profileImagePath!.isNotEmpty) {
        // Show saved profile image from local path
        return Image.file(
          File(_profileImagePath!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading profile image: $error');
            return _buildDefaultAvatar();
          },
        );
      }
    }

    // Default avatar
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Text(
      _fullNameController.text.isNotEmpty
          ? _fullNameController.text[0].toUpperCase()
          : '?',
      style: TextStyle(fontSize: 40, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          // Edit/Save button
          _isEditing
              ? IconButton(
                  icon: Icon(Icons.save),
                  onPressed: _saveUserData,
                  tooltip: 'Save Changes',
                )
              : IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => setState(() => _isEditing = true),
                  tooltip: 'Edit Profile',
                ),
          // Logout Button
          TextButton.icon(
            onPressed: _signOut,
            icon: Icon(Icons.logout, color: Colors.black),
            label: Text('Logout', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Header
                    Container(
                      padding: EdgeInsets.all(16),
                      color: Colors.grey[200],
                      child: Column(
                        children: [
                          // Profile Image with edit option
                          GestureDetector(
                            onTap: _isEditing ? _pickImage : null,
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: _getProfileImage(),
                                ),
                                if (_isEditing)
                                  Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          _isEditing
                              ? TextFormField(
                                  controller: _fullNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Full Name',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                )
                              : Text(
                                  _fullNameController.text,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          SizedBox(height: 8),
                          Text(_email ?? ''),
                          SizedBox(height: 4),
                          _isEditing
                              ? TextFormField(
                                  controller: _phoneNumberController,
                                  decoration: InputDecoration(
                                    labelText: 'Phone Number',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your phone number';
                                    }
                                    return null;
                                  },
                                )
                              : Text(_phoneNumberController.text),
                        ],
                      ),
                    ),

                    // Booked Cars Section
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Booked Cars',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          _bookedCars.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32),
                                    child: Text(
                                      'You haven\'t booked any cars yet.',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: _bookedCars.length,
                                  itemBuilder: (context, index) {
                                    var car = _bookedCars[index];
                                    return Card(
                                      margin: EdgeInsets.only(bottom: 16),
                                      elevation: 3,
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  car['model'] ??
                                                      'Unknown Model',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  '\$${car['pricePerHour']} / day',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(Icons.speed,
                                                    size: 16,
                                                    color: Colors.grey),
                                                SizedBox(width: 4),
                                                Text('${car['distance']} km'),
                                                SizedBox(width: 16),
                                                Icon(Icons.local_gas_station,
                                                    size: 16,
                                                    color: Colors.grey),
                                                SizedBox(width: 4),
                                                Text(
                                                    '${car['fuelCapacity']} L'),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Booked on: ${_formatDate(car['bookingTime'])}',
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),

                    // User KYC Details Section
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          Card(
                            elevation: 3,
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _isEditing
                                      ? _buildEditableField(
                                          'Date of Birth',
                                          _dobController,
                                          readOnly: true,
                                          onTap: () => _selectDate(context),
                                          suffixIcon:
                                              Icon(Icons.calendar_today),
                                        )
                                      : _buildInfoRow(
                                          'Date of Birth', _dobController.text),
                                  _isEditing
                                      ? _buildEditableField(
                                          'Driver\'s License',
                                          _licenseController,
                                        )
                                      : _buildInfoRow('Driver\'s License',
                                          _licenseController.text),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Address Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          Card(
                            elevation: 3,
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _isEditing
                                      ? _buildEditableField(
                                          'Address',
                                          _addressController,
                                          maxLines: 2,
                                        )
                                      : _buildInfoRow(
                                          'Address', _addressController.text),
                                  _isEditing
                                      ? _buildEditableField(
                                          'City',
                                          _cityController,
                                        )
                                      : _buildInfoRow(
                                          'City', _cityController.text),
                                  _isEditing
                                      ? _buildEditableField(
                                          'State',
                                          _stateController,
                                        )
                                      : _buildInfoRow(
                                          'State', _stateController.text),
                                  _isEditing
                                      ? _buildEditableField(
                                          'ZIP Code',
                                          _zipCodeController,
                                          keyboardType: TextInputType.number,
                                        )
                                      : _buildInfoRow(
                                          'ZIP Code', _zipCodeController.text),
                                  _isEditing
                                      ? _buildEditableField(
                                          'Alternate Address (Optional)',
                                          _alternateAddressController,
                                          maxLines: 2,
                                          required: false,
                                        )
                                      : _buildInfoRow('Alternate Address',
                                          _alternateAddressController.text),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 32),
                          if (_isEditing)
                            Center(
                              child: ElevatedButton(
                                onPressed: _saveUserData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 15),
                                ),
                                child: Text('Save Changes'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool required = true,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          suffixIcon: suffixIcon,
        ),
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        validator: required
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter $label';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value?.isNotEmpty == true ? value! : 'Not provided',
              style: TextStyle(
                color: value?.isNotEmpty == true ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown date';

    DateTime date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}

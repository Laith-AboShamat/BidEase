import 'dart:io';
import 'package:auctionapp/screens/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import '../const/colors.dart';
import '../const/shared_preferences.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _image;
  final _formKey = GlobalKey<FormState>();
  String? _selectedCity;
  String? _selectedPhoneIntro = "+972"; // Default phone intro
  List<String> _phoneIntros = ["+972", "+970"];

  List<String> _cities = [
    "Nablus",
    "Ramallah",
    "Hebron",
    "Bethlehem",
    "Jerusalem",
    "Gaza",
    "Jericho",
    "Jenin",
    "Tulkarm",
    "Qalqilya"
  ]; // Add actual city names here

  bool _isObscure = true; // Declare _isObscure here

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadProfileImage(String userId) async {
    try {
      if (_image != null) {
        String fileName = 'profile_$userId.jpg';
        Reference storageReference = FirebaseStorage.instance.ref().child('profile_images').child(fileName);
        UploadTask uploadTask = storageReference.putFile(_image!);
        await uploadTask.whenComplete(() => null);
        return await storageReference.getDownloadURL();
      }
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  signup() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Upload profile image and get download URL
        String? photoUrl = await uploadProfileImage(userCredential.user!.uid);

        // Save username to SharedPreferences
        await SharedPreferenceHelper().saveUserName(_usernameController.text);

        // Save user data in Firestore
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'username': _usernameController.text,
          'email': _emailController.text,
          'phone': '$_selectedPhoneIntro${_phoneController.text}',
          'city': _selectedCity,
          'photoUrl': photoUrl,
        }).catchError((e) {
          print('Error writing to Firestore: $e');
        });

        // Show snackbar to notify user that sign-up was successful
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Sign up successful! You can now sign in.'),
        ));

        // Navigate to login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } catch (e) {
        print('Error signing up: $e');
        // Show error message to the user
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to sign up. Please try again.'),
        ));
      }
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary,
      appBar: AppBar(
        backgroundColor: AppColor.green,
        title: Text(
          'SignUp',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  'Create an Account',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: _getImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColor.green,
                    child: _image != null
                        ? ClipOval(
                      child: Image.file(
                        _image!,
                        fit: BoxFit.cover, // Ensure the entire image is covered
                        width: 100, // Adjust the size if needed
                        height: 100, // Adjust the size if needed
                      ),
                    )
                        : Icon(Icons.add_a_photo, size: 50, color: Colors.white),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Tap to pick a profile picture',
                  style: TextStyle(color: AppColor.green),
                ),
                SizedBox(height: 20),
                _buildInputField("Username", Icons.person, TextInputType.text, _usernameController, validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                }),
                SizedBox(height: 10),
                _buildInputField("Email", Icons.email, TextInputType.emailAddress, _emailController, validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                }),
                SizedBox(height: 10),
                _buildInputField("Password", Icons.lock, TextInputType.visiblePassword, _passwordController,
                    isPassword: true, validator: _validatePassword),
                SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 100,
                      child: _buildPhoneIntroDropdown(),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _buildInputField("Phone", Icons.phone, TextInputType.phone, _phoneController, validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (!RegExp(r'^[0-9]{7,15}$').hasMatch(value)) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      }),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                _buildCityDropdown(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => signup(),
                  child: Text(
                    'SignUp',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.green),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, IconData icon, TextInputType keyboardType, TextEditingController controller,
      {bool isPassword = false, String? Function(String?)? validator}) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          errorStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword && _isObscure, // Use _isObscure here
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: label,
            hintStyle: TextStyle(color: AppColor.green),
            prefixIcon: Icon(icon, color: AppColor.green),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                _isObscure ? Icons.visibility : Icons.visibility_off,
                color: AppColor.green,
              ),
              onPressed: () {
                setState(() {
                  _isObscure = !_isObscure;
                });
              },
            )
                : null,
          ),
          validator: validator,
        ),
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: DropdownButtonFormField<String>(
        value: _selectedCity,
        hint: Text('Select City', style: TextStyle(color: AppColor.green)),
        onChanged: (String? newValue) {
          setState(() {
            _selectedCity = newValue;
          });
        },
        items: _cities.map((String city) {
          return DropdownMenuItem<String>(
            value: city,
            child: Text(city),
          );
        }).toList(),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(Icons.location_city, color: AppColor.green),
        ),
        validator: (value) => value == null ? 'Please select a city' : null,
      ),
    );
  }

  Widget _buildPhoneIntroDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButtonFormField<String>(
        value: _selectedPhoneIntro,
        decoration: InputDecoration(
          border: InputBorder.none,
        ),
        onChanged: (String? newValue) {
          setState(() {
            _selectedPhoneIntro = newValue;
          });
        },
        items: _phoneIntros.map((String intro) {
          return DropdownMenuItem<String>(
            value: intro,
            child: Text(intro),
          );
        }).toList(),
        validator: (value) => value == null ? 'Please select a phone intro' : null,
      ),
    );
  }
}
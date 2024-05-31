import 'dart:io';

import 'package:auctionapp/screens/signup_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../const/colors.dart';
import '../const/shared_preferences.dart';
import '../widgets/page_container.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  File? _image;

  bool _isObscure = true; // Add this line to initialize _isObscure

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> signInWithEmailPassword() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      _saveUserDetails(userCredential.user);
    } catch (e) {
      // Handle sign-in errors
      print('Failed to sign in with email and password: $e');
      // Show error message to the user
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to sign in with email and password'),
      ));
    }
  }

  Future<void> _saveUserDetails(User? user) async {
    if (user != null) {
      await SharedPreferenceHelper().saveUserName(_usernameController.text);
      await SharedPreferenceHelper().saveEmail(user.email);
      await SharedPreferenceHelper().saveBalance("1000000");
      // Navigate to the home screen after successful sign-in
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => PageContainer()),
            (Route route) => false,
      );
    }
  }

  /* Google Authentication and login function */
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser
            .authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCredential(credential);

        // Retrieve username and profile picture URL from Google account
        final displayName = googleUser.displayName;
        final photoUrl = googleUser.photoUrl;

        // Save user details to Firestore
        await saveUserData(
            userCredential.user?.uid, displayName, userCredential.user?.email,
            photoUrl);

        // Navigate to the home screen after successful sign-in
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => PageContainer()),
              (Route route) => false,
        );
      }
    } catch (e) {
      // Handle sign-in errors
      print('Failed to sign in with Google: $e');
      // Show error message to the user
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to sign in with Google'),
      ));
    }
  }

  Future<void> saveUserData(String? userId, String? username, String? email,
      String? photoUrl) async {
    if (userId != null && username != null && email != null) {
      // Save user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'username': username,
        'email': email,
        'balance': "100000",
        'photoUrl': photoUrl, // Save the profile picture URL
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              Container(
                height: 300,
                width: 300,
                child: Image.asset(
                    "assets/images/signup.png", fit: BoxFit.cover),
              ),
              SizedBox(height: 20),
              Text(
                "Welcome Back.",
                style: TextStyle(fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              _buildInputField("Email", Icons.email, TextInputType.emailAddress,
                  _emailController),
              SizedBox(height: 10),
              _buildInputField(
                  "Password", Icons.lock, TextInputType.visiblePassword,
                  _passwordController, isPassword: true),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: signInWithEmailPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.green,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Sign in', style: TextStyle(fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 10),
              Text(
                'Or', style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: (() => Get.to(SignUp())),
                    child: Text('Sign Up now', style: TextStyle(
                        fontWeight: FontWeight.bold, color: AppColor.green)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, IconData icon,
      TextInputType keyboardType, TextEditingController controller,
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
          obscureText: isPassword && _isObscure,
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
                  _isObscure = !_isObscure; // Update _isObscure here
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
}

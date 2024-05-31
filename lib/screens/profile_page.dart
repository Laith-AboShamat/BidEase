import 'package:auctionapp/const/colors.dart';
import 'package:auctionapp/const/shared_preferences.dart';
import 'package:auctionapp/utils/server/Firebase_store_fetch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/Profile_item_containers.dart'; // Import FirebaseAuth

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isPostedSelected = true;

  // Function to handle sign-out
  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // Sign out the user
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary,
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 30,
              ),
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () {
                    _signOut(context); // Call the sign-out function
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: AppColor.green,
                    ),
                    child: Text(
                      "Sign Out",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // Show loading indicator while fetching data
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return Text('No Data'); // Show message if no data is available
                  }
                  // Retrieve user data from Firestore snapshot
                  final userData = snapshot.data!;
                  final userName = userData['username'];
                  final userEmail = userData['email'];
                  final photoUrl = userData['photoUrl'];

                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColor.green,
                        child: ClipOval(
                          child: photoUrl != null
                              ? Image.network(photoUrl, fit: BoxFit.cover)
                              : Image.asset("assets/images/avatar2.png", fit: BoxFit.cover),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "$userName ",
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Icon(
                            Icons.verified,
                            color: AppColor.green,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.email, color: AppColor.green, size: 15,),
                          SizedBox(width: 8,),
                          Text("$userEmail", style: TextStyle(color: Colors.white),)
                        ],
                      ),
                    ],
                  );
                },
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                height: 30,
                width: 150,
                child: ToggleButtons(
                  borderRadius: BorderRadius.circular(30),
                  selectedColor: Colors.black,
                  borderColor: AppColor.green,
                  color: Colors.white,
                  fillColor: AppColor.green,
                  isSelected: [_isPostedSelected, !_isPostedSelected],
                  onPressed: (index) {
                    setState(() {
                      _isPostedSelected = index == 0;
                    });
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 0),
                      child: Text('Posted',),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 0),
                      child: Text('Owned'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _isPostedSelected ? PostedContainer() : OwnedContainer(),
            ],
          ),
        ),
      ),
    );
  }
}
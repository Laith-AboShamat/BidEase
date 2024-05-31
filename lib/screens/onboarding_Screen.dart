import 'dart:async';

import 'package:auctionapp/const/colors.dart';
import 'package:auctionapp/screens/login_page.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final List<String> _imagePaths = [
    "assets/images/img3.png",
    "assets/images/img2.jpg",
    "assets/images/img1.png",
  ];
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _startAutoScroll() {
    Timer.periodic(Duration(seconds: 2), (timer) {
      if (_currentPage < _imagePaths.length + 1) {
        setState(() {
          _currentPage++;
        });
      } else {
        setState(() {
          _currentPage = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary,
      body: Column(
        children: <Widget>[
          SizedBox(height: 100),
          Text(
            "Place bids",
            style: TextStyle(color: Colors.white, fontSize: 46, fontWeight: FontWeight.bold),
          ),
          Text(
            "& Win",
            style: TextStyle(color: AppColor.green, fontSize: 46, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Expanded(
            child: PageView.builder(
              itemCount: _imagePaths.length,
              controller: PageController(viewportFraction: 0.8, initialPage: 0),
              onPageChanged: (int index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: AppColor.green, // Set the background color of the card
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        _imagePaths[index],
                        fit: BoxFit.fill, // Ensure the image fills the entire space of the card
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Discover Thrilling Auctions\nYour Gateway to Exclusive Deals",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 20),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColor.green),
              child: Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}

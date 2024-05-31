import 'dart:async';
import 'package:auctionapp/const/colors.dart';
import 'package:flutter/material.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  startTime() async {
    var duration = Duration(seconds: 7);
    return Timer(duration, navigationPage);
  }

  void navigationPage() {
    Navigator.of(context).pushReplacementNamed('/onboarding');
  }

  @override
  void initState() {
    super.initState();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: AppColor.primary,
      body: Center(
        child: Container(
          width: double.infinity,
          height: 400,
          child: Image.asset('assets/images/bidart.png',fit: BoxFit.cover,),
        ),
      ),
    );
  }
}
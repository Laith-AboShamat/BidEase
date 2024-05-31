
import 'package:auctionapp/const/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CommonMethods {

  void showSimpleToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: AppColor.secondary,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }


  int calculateTimeDifference(Timestamp firestoreTimestamp) {
    DateTime currentDateTime = DateTime.now();
    DateTime firestoreDateTime = firestoreTimestamp.toDate();

    int days = currentDateTime.difference(firestoreDateTime).inDays;
    days=days*(-1);
    return days;
  }




  String getRemainingStatus(int daysRemaining) {
    if (daysRemaining > 1) {
      return '$daysRemaining days remain';
    } else if (daysRemaining >= 0) {
      return 'Ending Today';
    } else {
      return 'Ended';
    }
  }

  Duration calculateRemainingTime(DateTime futureTime) {
    DateTime currentTime = DateTime.now();
    if (futureTime.isBefore(currentTime)) {
      return Duration.zero;
    } else {
      return futureTime.difference(currentTime);
    }
  }







}

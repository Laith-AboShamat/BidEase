import 'package:auctionapp/const/colors.dart';
import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final label;
  final hinttext;
  final type;
  final size;
  final TextEditingController controller;
  const CustomTextfield({
    required this.label,
    required this.hinttext,
    required this.type,
    required this.size,
    required this.controller,

    Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColor.green),),
        TextField(
          controller: controller,
          keyboardType: type,
          maxLines: null,

          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(top:5.0, left:10.0,bottom: size),
            hintText: hinttext,
            hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColor.green)
            )
          ),
        )
      ],
    );
  }
}

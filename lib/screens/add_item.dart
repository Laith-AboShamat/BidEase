import 'dart:io';

import 'package:auctionapp/const/colors.dart';
import 'package:auctionapp/utils/common_widgets/textfield_widget.dart';
import 'package:auctionapp/utils/server/Firebase_store_fetch.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddItem extends StatefulWidget {
  const AddItem({Key? key}) : super(key: key);

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  File? _image;
  final picker = ImagePicker();
  DateTime dateTime = DateTime.now();
  TextEditingController datecontroller = TextEditingController();
  String dropdownValue = 'Electronic Devices';
  String? userName;
  String? userEmail;
  final FirestoreService _firestoreService = FirestoreService();

  TextEditingController Controller1 = TextEditingController();
  TextEditingController Controller2 = TextEditingController();
  TextEditingController Controller3 = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    userName = await _firestoreService.getUsername();
    userEmail = await _firestoreService.getEmail();
    setState(() {});
  }

  @override
  void dispose() {
    Controller1.dispose();
    Controller2.dispose();
    Controller3.dispose();
    super.dispose();
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future pickDateTime() async {
    DateTime? date = await pickDate();
    if (date == null) return;
    TimeOfDay? time = await pickTime();
    if (time == null) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      this.dateTime = dateTime;
    });
  }

  Future<DateTime?> pickDate() async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
  }

  Future<TimeOfDay?> pickTime() async {
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: dateTime.hour, minute: dateTime.minute),
    );
  }

  String _formatNumber(int number) {
    return number.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    final hours = dateTime.hour.toString().padLeft(2, '0');
    final min = dateTime.minute.toString().padLeft(2, '0');
    return Scaffold(
      backgroundColor: AppColor.primary,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: AppColor.green,
            ),
          ),
        ),
        title: Text(
          "Add item for Auction",
          style: TextStyle(color: AppColor.green),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add details of your item",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Please correctly fill up all the information about the product",
                style: TextStyle(color: Colors.white54),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      getImage();
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.white54)),
                      child: _image != null
                          ? Image.file(
                        _image!,
                        fit: BoxFit.cover,
                      )
                          : Center(
                        child: Icon(
                          Icons.add_circle_outline_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Add item photo",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        "Max 5 MB",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              CustomTextfield(
                label: 'Product Name',
                hinttext: "Enter Your Product Name",
                type: TextInputType.text,
                size: 5.0,
                controller: Controller1,
              ),
              SizedBox(
                height: 20,
              ),
              CustomTextfield(
                label: 'Product Description',
                hinttext: "Describe your product",
                type: TextInputType.multiline,
                size: 100.0,
                controller: Controller2,
              ),
              SizedBox(
                height: 20,
              ),
              CustomTextfield(
                label: 'Price',
                hinttext: "Minimum Bid Price",
                type: TextInputType.number,
                size: 5.0,
                controller: Controller3,
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Auction End Date",
                    style: TextStyle(color: AppColor.green),
                  ),
                  TextField(
                    controller: TextEditingController(
                      text: dateTime != null
                          ? '${_formatNumber(dateTime.day)}/${_formatNumber(dateTime.month)}/${dateTime.year} at ${_formatNumber(dateTime.hour)} Hour ${_formatNumber(dateTime.minute)} Minute'
                          : '',
                    ),
                    style: TextStyle(color: Colors.white),
                    onTap: () {
                      pickDateTime();
                    },
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(5),
                        hintText: 'Choose a suitable date',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColor.green)),
                        suffixIcon: Icon(
                          Icons.calendar_month,
                          color: AppColor.green,
                        )),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Category',
                style: TextStyle(color: AppColor.green),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.transparent,
                  border: Border.all(color: AppColor.green),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    dropdownColor: AppColor.primary,
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    underline: Container(
                      height: 0,
                      color: Colors.transparent,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                      });
                    },
                    items: <String>[
                      "Electronic Devices",
                      "Art",
                      "Gaming",
                      "Cars",
                      "Clothes",
                      "Furniture",
                      "Misc"
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  _firestoreService.uploadAuctionData(
                    context,
                    Controller1.text,
                    dropdownValue,
                    Controller3.text,
                    dateTime,
                    Controller2.text,
                    userName!,
                    userEmail!,
                    _image!,
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColor.green,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      "Add your product",
                      style: TextStyle(
                          color: AppColor.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


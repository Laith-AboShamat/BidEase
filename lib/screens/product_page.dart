import 'package:auctionapp/const/colors.dart';
import 'package:auctionapp/const/shared_preferences.dart';
import 'package:auctionapp/utils/common_methods/methods.dart';
import 'package:auctionapp/utils/server/Firebase_store_fetch.dart';
import 'package:auctionapp/widgets/bidding_list_view.dart';
import 'package:flutter/material.dart';
import 'package:slide_countdown/slide_countdown.dart';
import '../widgets/product_page_widgets.dart';

class ProductPage extends StatefulWidget {
  final String image;
  final String name;
  final String price;
  final String author;
  final String desc;
  final String email;
  final DateTime time;

  const ProductPage({
    required this.image,
    required this.name,
    required this.price,
    required this.author,
    required this.desc,
    required this.email,
    required this.time,
    Key? key,
  }) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _numberInput;
  bool _isAuctionCompleted = false;
  CommonMethods methods = CommonMethods();
  FirestoreService firestoreService = FirestoreService();
  final String? userEmail = SharedPreferenceHelper().getEmail();
  final String? userName = SharedPreferenceHelper().getUserName();
  final String? balance = SharedPreferenceHelper().getBalance();
  late String? productId = "${widget.name}-${widget.email}";
  late Duration dateTime;
  late String minBidPrice;
  String? winner;

  @override
  void initState() {
    super.initState();
    dateTime = methods.calculateRemainingTime(widget.time);
    _checkAuctionStatus();
    minBidPrice = widget.price;
  }

  void _checkAuctionStatus() {
    DateTime currentTime = DateTime.now();
    if (currentTime.isAfter(widget.time)) {
      firestoreService.updateStatusToCompleted(
          "${widget.name}-${widget.email}");
      setState(() {
        _isAuctionCompleted = true;
      });
      updateWinner();
    }
  }

  Future<void> updateWinner() async {
    String? winner =
    await firestoreService.updateStatusToCompleted(
        "${widget.name}-${widget.email}");
    setState(() {
      this.winner = winner;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColor.green,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Product Details",
          style: TextStyle(color: AppColor.green),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Add functionality for Chat button here
            },
            icon: Icon(
              Icons.chat,
              color: AppColor.green,
            ),
          ),
          SizedBox(width: 10),
          IconButton(
            onPressed: () {
              _showReportModal(context);
            },
            icon: Icon(
              Icons.report,
              color: AppColor.green,
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductImageWidget(image: widget.image),
              SizedBox(height: 20),
              ProductDetailsWidget(
                name: widget.name,
                description: widget.desc,
                author: widget.author,
              ),
              SizedBox(height: 10),
              BidPriceWidget(minBidPrice: minBidPrice),
              SizedBox(height: 20),
              winner == null
                  ? PlaceBidButtonWidget(
                onTap: () {
                  buildShowModalBottomSheet(
                      context, widget.time, widget.author);
                },
              )
                  : Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  border: Border.all(width: 1, color: AppColor.secondary),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    "Auction Ended",
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              if (_isAuctionCompleted) WinnerWidget(winner: winner),
              Text(
                "Other Biddings",
                style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              SizedBox(height: 15),
              BidderListView(productID: productId!),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> buildShowModalBottomSheet(BuildContext context,
      DateTime time,
      String bidderName,) async {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30)),
              color: AppColor.secondary),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Time Remaining",
                ),
                SlideCountdown(
                  textStyle: TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                  separatorType: SeparatorType.symbol,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  duration: Duration(
                      days: dateTime.inDays,
                      hours: dateTime.inHours,
                      minutes: dateTime.inMinutes,
                      seconds: dateTime.inSeconds),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    color: AppColor.primary,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Enter Amount",
                  style: TextStyle(fontSize: 16),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Enter a Number',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a number.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _numberInput = value;
                        },
                      ),
                      SizedBox(height: 16),
                      InkWell(
                          onTap: () {
                            if (widget.email == userEmail) {
                              methods.showSimpleToast(
                                  "You can't Place Bid On your Own Listed Item");
                            } else {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                double biddingPrice = double.parse(
                                    _numberInput!);
                                double currentPrice = double.parse(
                                    widget.price);
                                if (biddingPrice < currentPrice) {
                                  methods.showSimpleToast(
                                      "You can't Place Bid less than current Value");
                                } else {
                                  firestoreService.placeBid(
                                    productId!,
                                    _numberInput!,
                                    balance!,
                                  );
                                  Navigator.pop(context);
                                  setState(() {
                                    minBidPrice = biddingPrice.toString();
                                  });
                                }
                              }
                            }
                          },
                          child: Container(
                            width: 120,
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColor.primary,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(
                                "Confirm Bid",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Future<void> _showReportModal(BuildContext context) async {
    final reasons = [
      'Inappropriate Content',
      'Harassment',
      'Spam or Scams',
      'Violence or Harmful',
      'Privacy Violation',
      'False Information',
      'Unauthorized Sales',
    ];
    String? selectedReason;

    // Get the username
    String? userName = await firestoreService.getUsername();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColor.primary,
          title: Text(
            'Select Reason for Reporting',
            style: TextStyle(color: AppColor.green),
          ),
          content: SingleChildScrollView(
            child: DropdownButtonFormField<String>(
              value: selectedReason,
              onChanged: (newValue) {
                setState(() {
                  selectedReason = newValue;
                });
              },
              items: reasons.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(color: AppColor.green),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                if (selectedReason != null && userName != null) {
                  // Save report in Firestore using the obtained userName
                  await firestoreService.saveReport(
                    widget.author,
                    widget.email,
                    widget.name,
                    userName, // Use the obtained userName here
                    selectedReason!,
                  );
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Report submitted successfully!'),
                    ),
                  );
                }
              },
              child: Text(
                'Submit',
                style: TextStyle(color: AppColor.green),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}



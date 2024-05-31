import 'dart:math';
import 'package:auctionapp/utils/common_methods/methods.dart';
import 'package:auctionapp/utils/server/Firebase_store_fetch.dart';
import 'package:flutter/material.dart';
import '../const/colors.dart';
import '../screens/product_page.dart';

class MyPageView extends StatefulWidget {
  final List<Map<String, dynamic>> productList;
  const MyPageView({required this.productList, Key? key}) : super(key: key);
  @override
  _MyPageViewState createState() => _MyPageViewState();
}

class _MyPageViewState extends State<MyPageView> {
  CommonMethods methods = CommonMethods();
  late PageController _pageController;
  double _currentPage = 0;
  double viewport = 0.8;
  double pageOffset = 0;

  FirestoreService firestoreFetch = FirestoreService();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: viewport,
    )..addListener(() {
        setState(() {
          pageOffset = _pageController.page!;
        });
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.horizontal,
      controller: _pageController,
      itemCount: widget.productList.length,
      itemBuilder: (BuildContext context, int index) {
        double scale = max(viewport, (1 - (pageOffset - index).abs()) + viewport);
        Map<String, dynamic> productData = widget.productList[index];
        int day = methods.calculateTimeDifference(productData['BiddingEnd']);
        String msg = methods.getRemainingStatus(day);
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductPage(
                  image: productData['productPhotoUrl'],
                  name: productData['product_name'],
                  price: productData['currentBid'],
                  author: productData['posted-by'],
                  desc: productData['description'],
                  email: productData['Poster_email'],
                  time: productData['BiddingEnd'].toDate(),
                ),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.only(
              right: 30,
              top: 100 - scale * 35,
              bottom: 50,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: AppColor.secondary,
                boxShadow: [
                  BoxShadow(
                    color: AppColor.secondary.withOpacity(0.20),
                    spreadRadius: 8,
                    offset: Offset(2, 3),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Stack(
                      children: [
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            child: SizedBox(
                              height: 220,
                              width: double.infinity,
                              child: Image.network(
                                productData['productPhotoUrl'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                            top: 10,
                            left: 5,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                          decoration: BoxDecoration(
                            color: AppColor.primary,
                            borderRadius: BorderRadius.circular(30),
                          ),
                              child: Text(
                                productData['status']=="completed"?
                                "Ended":msg, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),),
                        ))
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  productData['product_name'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              Text(
                                "min. \$${productData['minimumBidPrice']}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColor.primary.withOpacity(0.85),
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: AppColor.primary.withOpacity(0.85),
                                fontSize: 13,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Posted by ',
                                ),
                                TextSpan(
                                  text: '${productData['posted-by'].toString().split(' ').first}',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.primary
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 40,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: AppColor.primary,
                        border: Border.all(width: 2),
                      ),
                      child: Center(
                        child: Text(
                          "Place Bid",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:auctionapp/const/colors.dart';
import 'package:auctionapp/utils/server/Firebase_store_fetch.dart';
import 'package:auctionapp/widgets/pageview_widget.dart';
import 'package:flutter/material.dart';

class ProductLoading extends StatefulWidget {
  final int item_no;
  const ProductLoading({required this.item_no, Key? key}) : super(key: key);

  @override
  State<ProductLoading> createState() => _ProductLoadingState();
}

class _ProductLoadingState extends State<ProductLoading> {

  List<String> items = [
    "All",
    "Completed",
    "Electronic Devices",
    "Art",
    "Gaming",
    "Cars",
    "Clothes",
    "Furniture",
    "Misc",
  ];

  FirestoreService firestoreFetch = FirestoreService();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: widget.item_no==0?firestoreFetch.fetchProductsAll():
        (widget.item_no==1? firestoreFetch.fetchCompletedProducts():firestoreFetch.fetchProductsByType(items[widget.item_no])),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColor.primary,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("A Server Error has been Occured!"),
            );
          } else {
            List<Map<String, dynamic>> productLists = snapshot.data ?? [];
            return Container(
              child: MyPageView(productList: productLists ),
            );
          }
        });
  }
}


import 'package:auctionapp/const/colors.dart';
import 'package:auctionapp/utils/server/Firebase_store_fetch.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BidderListView extends StatelessWidget {
  final String productID;
  FirestoreService firestoreService = FirestoreService();

  BidderListView({Key? key, required this.productID}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: firestoreService.fetchBidsForProduct(productID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(
            color: AppColor.green,
          ));
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          List<Map<String, dynamic>> bids = snapshot.data!;
          return ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: bids.length,
            separatorBuilder: (context, index) => Divider(
              color: Colors.white,
            ),
            itemBuilder: (context, index) {
              Map<String, dynamic> bid = bids[index];
              DateTime biddingDate = bid['Bidding_date'].toDate();
              String formattedDate =
              DateFormat('dd:MM:yyyy').format(biddingDate);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColor.green,
                  child: Icon(
                    Icons.person,
                    color: AppColor.primary,
                  ),
                ),
                title: Text(
                  bid['Bidder_name'] ?? 'Unknown Bidder',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  formattedDate,
                  style: TextStyle(color: AppColor.secondary, fontSize: 10),
                ),
                trailing: Text(
                  '\$${bid['Bidding_price'] ?? 0}',
                  style: TextStyle(
                      color: AppColor.secondary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              );
            },
          );
        } else {
          // Empty state when there are no bids
          return Text('No bids available.');
        }
      },
    );
  }
}
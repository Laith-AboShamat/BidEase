import 'package:auctionapp/const/colors.dart';
import 'package:auctionapp/const/shared_preferences.dart';
import 'package:auctionapp/utils/server/Firebase_store_fetch.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PostedContainer extends StatefulWidget {
  const PostedContainer({Key? key}) : super(key: key);

  @override
  State<PostedContainer> createState() => _PostedContainerState();
}

class _PostedContainerState extends State<PostedContainer> {
  final FirestoreService _firestoreFetch = FirestoreService();
  final String? userEmail = SharedPreferenceHelper().getEmail();
  bool isDeleting = false; // Track deletion progress

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: AppColor.green),
          borderRadius: BorderRadius.circular(20),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _firestoreFetch.fetchProductsByUserEmail(userEmail!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: AppColor.primary),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Error fetching products: ${snapshot.error}"),
              );
            } else {
              List<Map<String, dynamic>> productList = snapshot.data ?? [];
              return ListView.separated(
                shrinkWrap: true,
                itemCount: productList.length,
                separatorBuilder: (context, index) => Divider(color: Colors.white),
                itemBuilder: (context, index) {
                  Map<String, dynamic> productData = productList[index];
                  String? documentID = productData['documentID']; // Get documentID
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: SizedBox(
                        height: 60,
                        width: 60,
                        child: Image.network(productData['productPhotoUrl'], fit: BoxFit.cover),
                      ),
                    ),
                    title: Text(
                      "Title: ${productData['product_name']}",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ending on ${DateFormat('MM-dd-yyyy').format(productData['BiddingEnd'].toDate())}",
                          style: TextStyle(color: AppColor.secondary, fontSize: 10),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Minimum Bid Price: \$${productData['minimumBidPrice']}",
                          style: TextStyle(color: AppColor.secondary, fontSize: 10),
                        ),
                      ],
                    ),
                    trailing: isDeleting // Check if deletion is in progress
                        ? CircularProgressIndicator() // Show loading indicator if deleting
                        : IconButton(
                      icon: Icon(Icons.delete),
                      color: AppColor.secondary,
                      onPressed: () async {
                        print("Delete button pressed");
                        if (documentID != null && !isDeleting) {
                          // Show confirmation dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Confirm Delete"),
                              content: Text("Are you sure you want to delete this auction?"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close dialog
                                  },
                                  child: Text("Cancel", style: TextStyle(color: Colors.black)),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    // Close dialog and delete auction
                                    Navigator.of(context).pop();
                                    setState(() {
                                      isDeleting = true; // Set deleting to true to disable button
                                    });
                                    await _firestoreFetch.deleteAuction(documentID);
                                    setState(() {
                                      isDeleting = false; // Reset deleting to false after deletion
                                    });
                                  },
                                  child: Text("Delete", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class OwnedContainer extends StatefulWidget {
  const OwnedContainer({Key? key}) : super(key: key);

  @override
  State<OwnedContainer> createState() => _OwnedContainerState();
}

class _OwnedContainerState extends State<OwnedContainer> {
  final FirestoreService _firestoreFetch = FirestoreService();
  List<Map<String, dynamic>> ownedProducts = [];

  @override
  void initState() {
    super.initState();
    loadOwnedProducts();
  }

  Future<void> loadOwnedProducts() async {
    List<Map<String, dynamic>> products = await _firestoreFetch.loadOwnedProducts();
    setState(() {
      ownedProducts = products;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 2, color: AppColor.green),
        ),
        child: ownedProducts.isEmpty
            ? Center(child: CircularProgressIndicator(color: AppColor.primary))
            : ListView.separated(
          shrinkWrap: true,
          itemCount: ownedProducts.length,
          separatorBuilder: (context, index) => Divider(color: Colors.white),
          itemBuilder: (context, index) {
            Map<String, dynamic> productData = ownedProducts[index];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: SizedBox(
                  height: 60,
                  width: 60,
                  child: Image.network(productData['productPhotoUrl'], fit: BoxFit.cover),
                ),
              ),
              title: Text(
                "Title: ${productData['product_name']}",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              subtitle: Text(
                "Ending on ${DateFormat('MM-dd-yyyy').format(productData['BiddingEnd'].toDate())}",
                style: TextStyle(color: AppColor.secondary, fontSize: 10),
              ),
              trailing: Text(
                '\$${productData['minimumBidPrice']}',
                style: TextStyle(color: AppColor.secondary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ),
    );
  }
}

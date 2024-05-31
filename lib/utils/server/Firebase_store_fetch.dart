import 'dart:io';
import 'package:auctionapp/const/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../widgets/page_container.dart';
import '../common_methods/methods.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CommonMethods methods = CommonMethods();

  Future<String?> getUsername() async {
    String? username;
    try {
      String? userEmail = await SharedPreferenceHelper().getEmail();
      QuerySnapshot<Map<String, dynamic>> user = await _firestore
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .get();

      if (user.docs.isNotEmpty) {
        username = user.docs[0].data()['username'];
      }
    } catch (e) {
      print("Error getting username: $e");
    }
    return username;
  }

  Future<String?> getEmail() async {
    String? email;
    try {
      String? userEmail = await SharedPreferenceHelper().getEmail();
      QuerySnapshot<Map<String, dynamic>> user = await _firestore
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .get();

      if (user.docs.isNotEmpty) {
        email = user.docs[0].data()['email'];
      }
    } catch (e) {
      print("Error getting email: $e");
    }
    return email;
  }

  Future<void> uploadAuctionData(
      BuildContext context,
      String product_name,
      String type,
      String min_price,
      DateTime endDate,
      String desc,
      String author,
      String author_email,
      File photo,
      ) async {
    try {
      final storage = FirebaseStorage.instance;
      final storageRef = storage.ref();

      final photo1Ref = storageRef.child('AuctionProduct/$product_name - $author/Product.jpg');
      final uploadTask1 = await photo1Ref.putFile(photo);

      final productPicUrl = await uploadTask1.ref.getDownloadURL();

      final firestore = FirebaseFirestore.instance;
      final userCollection = firestore.collection('Auctions');

      final userDocument = userCollection.doc('$product_name-$author_email');

      await userDocument.set({
        'product_name': product_name,
        'type': type,
        'description': desc,
        'minimumBidPrice': min_price, // Include minimum bid price here
        'BiddingEnd': endDate,
        'posted-by': author,
        'Poster_email': author_email,
        'status': 'running',
        'productPhotoUrl': productPicUrl,
        'winner': 'none',
        'currentBid': min_price,
      });

      methods.showSimpleToast("Your Product has been Uploaded");

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => PageContainer()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error uploading auction data: $e');
    }
  }

  Future<void> deleteAuction(String documentID) async {
    try {
      final CollectionReference auctionsCollection =
      FirebaseFirestore.instance.collection('Auctions');

      await auctionsCollection.doc(documentID).delete();

      print('Auction with ID $documentID deleted successfully');
    } catch (e) {
      print('Error deleting auction: $e');
    }
  }

  Future<void> placeBid(String productID, String biddingPrice, String balance,) async {
    try {
      double bidAmount = double.parse(biddingPrice);
      double currentBalance = double.parse(balance);

      if (bidAmount <= currentBalance) {
        double remainingBalance = currentBalance - bidAmount;
        if (remainingBalance < 0) {
          methods.showSimpleToast("Insufficient Balance!");
          return;
        }

        final CollectionReference bidsCollection =
        FirebaseFirestore.instance.collection('Bids');
        final CollectionReference auctionCollection =
        FirebaseFirestore.instance.collection('Auctions');

        // Fetch username
        String? bidderName = await getUsername();

        if (bidderName != null) {
          DocumentReference newBidDocRef = bidsCollection.doc();
          String bidID = newBidDocRef.id;

          Map<String, dynamic> bidData = {
            'product-id': productID,
            'Bidder_name': bidderName,
            'Bidding_price': bidAmount,
            'Bidding_date': DateTime.now(),
          };

          await newBidDocRef.set(bidData);

          methods.showSimpleToast("Bid placed Successfully!");

          SharedPreferenceHelper().saveBalance2(remainingBalance.toString());

          await FirebaseFirestore.instance.runTransaction((transaction) async {
            DocumentReference auctionDocRef = auctionCollection.doc(productID);
            DocumentSnapshot auctionSnapshot = await transaction.get(auctionDocRef);
            double currentBid = double.parse(auctionSnapshot.get('currentBid') ?? '0');
            if (bidAmount > currentBid) {
              transaction.update(auctionDocRef, {
                'currentBid': bidAmount.toString(),
                'minimumBidPrice': bidAmount.toString(), // Update minimum bid price
              });
            }
          });
        } else {
          methods.showSimpleToast("Error fetching username.");
        }
      } else {
        methods.showSimpleToast(
            'Bidding price is greater than the available balance.');
      }
    } catch (e) {
      print('Error placing bid: $e');
    }
  }

  Future<String?> updateStatusToCompleted(String documentID) async {
    try {
      final CollectionReference auctionsCollection =
      FirebaseFirestore.instance.collection('Auctions');
      final CollectionReference bidsCollection =
      FirebaseFirestore.instance.collection('Bids');

      QuerySnapshot bidsSnapshot =
      await bidsCollection.where('product-id', isEqualTo: documentID).get();

      double highestBidPrice = 0;
      String winner = '';

      for (var bidDoc in bidsSnapshot.docs) {
        double bidPrice = bidDoc['Bidding_price'];
        if (bidPrice > highestBidPrice) {
          highestBidPrice = bidPrice;
          winner = bidDoc['Bidder_name'];
        }
      }

      if (highestBidPrice > 0) {
        await auctionsCollection.doc(documentID).update({
          'status': 'completed',
          'winner': winner,
        });

        print('Status updated to Completed successfully');
        return winner;
      } else {
        print('No bids found for the documentID');
      }
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchProductsAll() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Auctions')
          .get();

      List<Map<String, dynamic>> productList = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      return productList;
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchProductsByUserEmail(String userEmail) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Auctions')
          .where('Poster_email', isEqualTo: userEmail)
          .get();

      List<Map<String, dynamic>> productList = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['documentID'] = doc.id; // Add document ID to the data
        return data;
      }).toList();
      return productList;
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchProductsByWinner(
      String username) async {
    try {
      String lowercaseUsername = username.toLowerCase();
      print('Lowercase username: $lowercaseUsername');
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Auctions')
          .where('winner', isEqualTo: lowercaseUsername)
          .get();

      List<Map<String, dynamic>> productList = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      print('Query Result Documents:');
      productList.forEach((product) {
        print(product['winner']);
      });
      return productList;
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> loadOwnedProducts() async {
    try {
      String? username = await getUsername();
      if (username != null) {
        List<Map<String, dynamic>> products =
        await fetchProductsByWinner(username);
        return products;
      } else {
        print('Username is null');
        return [];
      }
    } catch (e) {
      print("Error loading owned products: $e");
      return [];
    }
  }



  Future<List<Map<String, dynamic>>> fetchProductsByType(
      String productType) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Auctions')
          .where('type', isEqualTo: productType)
          .where('status', isEqualTo: 'running')
          .get();

      List<Map<String, dynamic>> productList = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      return productList;
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchCompletedProducts() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Auctions')
          .where('status', isEqualTo: "completed")
          .get();

      List<Map<String, dynamic>> productList = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      return productList;
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchBidsForProduct(
      String productID) async {
    try {
      final CollectionReference bidsCollection =
      FirebaseFirestore.instance.collection('Bids');

      QuerySnapshot snapshot = await bidsCollection
          .where('product-id', isEqualTo: productID)
          .get();

      List<Map<String, dynamic>> bids = [];
      snapshot.docs.forEach((doc) {
        bids.add(doc.data() as Map<String, dynamic>);
      });

      return bids;
    } catch (e) {
      print('Error fetching bids: $e');
      return [];
    }
  }

  Future<void> saveReport(String author, String email, String productName,
      String userName, String reason) async {
    try {
      final CollectionReference reportsCollection =
      FirebaseFirestore.instance.collection('Reports');

      await reportsCollection.add({
        'author': author,
        'email': email,
        'productName': productName,
        'userName': userName,
        'reason': reason,
        'timestamp': Timestamp.now(),
      });

      print('Report saved successfully');
    } catch (e) {
      print('Error saving report: $e');
      throw e;
    }
  }

  Future<List<double>> getAuctionStats() async {
    try {
      final CollectionReference auctionsCollection =
      FirebaseFirestore.instance.collection('Auctions');
      final CollectionReference bidsCollection =
      FirebaseFirestore.instance.collection('Bids');

      QuerySnapshot runningBidsSnapshot = await auctionsCollection
          .where('status', isEqualTo: 'running')
          .get();
      int runningCount = runningBidsSnapshot.size;

      QuerySnapshot completedSnap = await auctionsCollection
          .where('status', isEqualTo: 'completed')
          .get();
      int completeCount = completedSnap.size;

      double totalValue = 0;
      completedSnap.docs.forEach((auctionDoc) {
        double currentBid = double.parse(auctionDoc['currentBid']);
        totalValue += currentBid;
      });

      QuerySnapshot totalBidsSnapshot = await bidsCollection.get();
      int totalBids = totalBidsSnapshot.size;

      return [
        totalBids.toDouble(),
        runningCount.toDouble(),
        completeCount.toDouble(),
        totalValue,
      ];
    } catch (e) {
      print('Error fetching auction stats: $e');
      return [];
    }
  }
}

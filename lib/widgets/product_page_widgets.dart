import 'package:flutter/material.dart';
import '../const/colors.dart';

class ProductImageWidget extends StatelessWidget {
  final String image;

  const ProductImageWidget({required this.image});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(30)),
      child: SizedBox(
        width: 350,
        height: 280,
        child: Image.network(
          image,
          height: 200,
          width: 300,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class ProductDetailsWidget extends StatelessWidget {
  final String name;
  final String description;
  final String author;

  const ProductDetailsWidget({
    required this.name,
    required this.description,
    required this.author,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          "Product Description: ",
          style: TextStyle(color: AppColor.secondary),
        ),
        Text(
          description,
          style: TextStyle(color: Colors.white),
          overflow: TextOverflow.ellipsis,
          maxLines: 3,
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Text(
              "@$author",
              style: TextStyle(color: AppColor.secondary),
            ),
            Icon(
              Icons.verified,
              color: AppColor.green,
              size: 14,
            ),
          ],
        ),
      ],
    );
  }
}

class BidPriceWidget extends StatelessWidget {
  final String minBidPrice;

  const BidPriceWidget({required this.minBidPrice});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Current Min. Bid Price: ",
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(width: 5),
        Container(
          height: 30,
          width: 100,
          decoration: BoxDecoration(
            color: AppColor.secondary,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              "\$$minBidPrice",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

class PlaceBidButtonWidget extends StatelessWidget {
  final VoidCallback onTap;

  const PlaceBidButtonWidget({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColor.green,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            "Place a Bid",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class WinnerWidget extends StatelessWidget {
  final String? winner;

  const WinnerWidget({required this.winner});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColor.secondary,
            border: Border.all(width: 1, color: AppColor.secondary),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.celebration_outlined),
              Text(
                "Winner: $winner",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.celebration_outlined),
            ],
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
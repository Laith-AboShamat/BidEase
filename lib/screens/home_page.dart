import 'package:auctionapp/const/colors.dart';
import 'package:auctionapp/screens/add_item.dart';
import 'package:auctionapp/widgets/product_loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  List<Map<String, dynamic>> items = [
    {"title": "All", "icon": Icons.category},
    {"title": "Completed", "icon": Icons.done},
    {"title": "Electronic Devices", "icon": Icons.phone_android},
    {"title": "Art", "icon": Icons.palette},
    {"title": "Gaming", "icon": Icons.games},
    {"title": "Cars", "icon": Icons.directions_car},
    {"title": "Clothes", "icon": Icons.shopping_bag},
    {"title": "Furniture", "icon": Icons.chair},
    {"title": "Misc", "icon": Icons.widgets},
  ];

  int current = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary,
      body: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Explore\nYour new style",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddItem(),
                      ),
                    );
                  },
                  child: Container(
                    height: 30,
                    width: 120,
                    decoration: BoxDecoration(
                      color: AppColor.green,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.add_circle_rounded,
                            color: AppColor.primary,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Add item",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 15),
              height: 1,
              width: double.infinity,
              color: Colors.white10,
            ),
            SizedBox(height: 30),
            Row(
              children: const [
                Text(
                  "Popular Categories",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                )
              ],
            ),
            SizedBox(height: 20),
            SingleChildScrollView( // Wrap with SingleChildScrollView
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(
                  items.length,
                      (index) =>
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            current = index;
                            print(items[current]["title"]);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: current == index
                                ? AppColor.green
                                : Colors.white70.withOpacity(0.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                items[index]["icon"],
                                color: current == index
                                    ? AppColor.primary
                                    : Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                items[index]["title"],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: current == index
                                      ? AppColor.primary
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ProductLoading(item_no: current),
            ),
          ],
        ),
      ),
    );
  }
}

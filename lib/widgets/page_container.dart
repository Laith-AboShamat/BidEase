import 'package:auctionapp/const/colors.dart';
import 'package:auctionapp/screens/login_page.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/dashboard_page.dart';
import '../screens/home_page.dart';
import '../screens/profile_page.dart';

class PageContainer extends StatefulWidget {
  const PageContainer({Key? key}) : super(key: key);

  @override
  State<PageContainer> createState() => _PageContainerState();
}

class _PageContainerState extends State<PageContainer> {
  int _currentIndex = 1;

  final List<Widget> _pages = [
    DashboardPage(),
    HomePage(),
    ProfilePage(),
  ];


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(snapshot.hasError){
          return Text(snapshot.error.toString());
        }
        if(snapshot.connectionState==ConnectionState.active){
          if(snapshot.data==null){
            return LoginPage();
          }
          else{
            return Scaffold(
              backgroundColor: AppColor.primary,
              bottomNavigationBar: CurvedNavigationBar(
                backgroundColor: Colors.transparent,
                color: AppColor.green,
                height: 60,
                index: _currentIndex,
                animationDuration: Duration(milliseconds: 600),
                onTap: (index){
                  setState(() {
                    _currentIndex = index;
                  });
                },
                items: const [
                  Icon(Icons.store, color: AppColor.primary,),
                  Icon(Icons.home_filled, color: AppColor.primary),
                  Icon(Icons.person, color: AppColor.primary,),
                ],
              ),
              body: _pages[_currentIndex],
            );
          }
        }
        return Center(child: CircularProgressIndicator(
          color: AppColor.green,
        ),
        );
      }
    );
  }
}





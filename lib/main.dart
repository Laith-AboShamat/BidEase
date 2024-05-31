import 'package:auctionapp/screens/login_page.dart';
import 'package:auctionapp/screens/onboarding_Screen.dart';
import 'package:auctionapp/screens/splash_screen.dart';
import 'package:auctionapp/const/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferenceHelper().initialize();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDPhoyHDJhtZZw4MLlgCyUkR2HPFzbamVI",
        appId: "1:628660569866:android:ecfcaaf0df5db2ea409cf3",
        projectId: "auction-75bde",
        storageBucket: "auction-75bde.appspot.com",
        messagingSenderId: '628660569866',
      )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ));
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      home:  SplashScreen(),
      routes: <String, WidgetBuilder>{
        '/onboarding': (BuildContext context) => const OnboardingScreen(),
        '/login': (BuildContext context) => const LoginPage()
      },
    );
  }
}



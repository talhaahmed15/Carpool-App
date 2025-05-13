import 'package:carpool_app/app_signup/view/login.dart';
import 'package:carpool_app/config/appcolors.dart';
import 'package:carpool_app/controller/session_controller.dart';
import 'package:carpool_app/controller/sharedpref_controller.dart';
import 'package:carpool_app/main.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkUser();
  }

  checkUser() async {
    print("checking user");
    await Future.delayed(Duration(seconds: 3));
    await SharedPrefController().getSession();

    // Replace this logic with your controller logic
    if (SessionController().isLoggedIn!) {
      print("user is logged in");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MyApp()));
    } else {
      print("user is not logged in");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(),
            Image.asset("assets/oxigo.png"),
            LinearProgressIndicator(
              minHeight: 5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.appTheme[2]),
            ),
          ],
        ),
      ),
    );
  }
}

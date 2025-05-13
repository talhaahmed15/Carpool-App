
import 'dart:convert';

import 'package:carpool_app/app_account/Screens/user_account.dart';
import 'package:carpool_app/app_offer_ride/Screens/offer_ride.dart';
import 'package:carpool_app/app_search_ride/Screens/search_ride.dart';
import 'package:carpool_app/app_splash/splash_screen.dart';
import 'package:carpool_app/config/appcolors.dart';
import 'package:carpool_app/config/applabels.dart';
import 'package:carpool_app/config/icons.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';


Future<void> initializeFirebase() async {
  final configString = await rootBundle.loadString('firebase_config.json');
  final config = json.decode(configString);

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: config['apiKey'],
      appId: config['appId'],
      messagingSenderId: config['messagingSenderId'],
      projectId: config['projectId'],
    ),
  );
}

Future<void> main() async {
  // debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  // if (Platform.isAndroid) {
  //   AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  // }

  await initializeFirebase();

  // await SharedPrefController().getSession();

  runApp(
    // DevicePreview(
    //   enabled: !kReleaseMode,
    //   builder: (context) => const MyApp(),
    // ),

    AppRunner(),
  );
}

class AppRunner extends StatelessWidget {
  const AppRunner({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.appTheme[2]),
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.whiteColor),
        home: SafeArea(child: SplashScreen()),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: [
          const SearchRide(),
          const OfferRide(),
          const UserAccount()
        ][currentIndex],
        bottomNavigationBar: NavigationBar(
          backgroundColor: Colors.white,
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          destinations: [
            NavigationDestination(
                icon: Image.asset(
                  AppIcons.searchRideIcon,
                  height: 25,
                ),
                label: Applabels.searchRide),
            NavigationDestination(
                icon: Image.asset(
                  AppIcons.offerRideIcon,
                  height: 25,
                ),
                label: Applabels.offerRide),
            NavigationDestination(
                icon: Image.asset(
                  AppIcons.accountIcon,
                  height: 25,
                ),
                label: Applabels.account),
          ],
        ),
      ),
    );
  }
}

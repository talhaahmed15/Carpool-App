import 'package:carpool_app/config/app_fonts.dart';
import 'package:carpool_app/config/app_widgets.dart';
import 'package:carpool_app/config/appcolors.dart';
import 'package:carpool_app/main.dart';
import 'package:flutter/material.dart';

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({required this.rideId, super.key});

  final String rideId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          CustomAppBar2(
              fun: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const MyApp(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = 0.0;
                      const end = 1.0;
                      const curve = Curves.easeInOut;

                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
                      var fadeAnimation = animation.drive(tween);

                      return FadeTransition(
                        opacity: fadeAnimation,
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(
                        milliseconds: 800), // Control transition speed
                  ),
                  (Route<dynamic> route) => false, // Remove all previous routes
                );
              },
              text: "Booking Confirmation",
              subtext: "July 21, 2024 | 12:34 PM"),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Thank you. You have booked the ride.",
                  style: AppTextStyle.helveticaStyle
                      .copyWith(fontSize: 16, color: Colors.grey[600]),
                ),
                Text(
                  "Your Ride Number is",
                  style: AppTextStyle.helveticaStyle
                      .copyWith(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      rideId,
                      style: AppTextStyle.helveticaBoldStyle
                          .copyWith(color: AppColors.appTheme[2], fontSize: 25),
                    )),
                const SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Guidelines:',
                    style: AppTextStyle.helveticaBoldStyle
                        .copyWith(fontSize: 18, color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                    '1. Please contact the driver if you are late or not traveling.',
                    style: AppTextStyle.helveticaStyle
                        .copyWith(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 8.0),
                Text(
                    '2. We are not responsible for anyone who is not traveling. We only provide the platform to connect riders and drivers.',
                    style: AppTextStyle.helveticaStyle
                        .copyWith(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(
                  height: 30,
                ),
                PrimaryButton(
                  text: "Go to Dashboard",
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const MyApp(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = 0.0;
                          const end = 1.0;
                          const curve = Curves.easeInOut;

                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          var fadeAnimation = animation.drive(tween);

                          return FadeTransition(
                            opacity: fadeAnimation,
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(
                            milliseconds: 800), // Control transition speed
                      ),
                      (Route<dynamic> route) =>
                          false, // Remove all previous routes
                    );
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

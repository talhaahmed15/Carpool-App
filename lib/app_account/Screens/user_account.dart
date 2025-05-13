import 'package:carpool_app/app_account/Screens/booked_rides.dart';
import 'package:carpool_app/app_account/Screens/bookings.dart';
import 'package:carpool_app/app_signup/controller/signupController.dart';
import 'package:flutter/material.dart';
import 'package:carpool_app/config/app_const.dart';
import 'package:carpool_app/config/app_fonts.dart';
import 'package:carpool_app/config/app_widgets.dart';
import 'package:carpool_app/config/appcolors.dart';
import 'package:carpool_app/config/applabels.dart';
import 'package:carpool_app/controller/session_controller.dart';

class UserAccount extends StatefulWidget {
  const UserAccount({super.key});

  @override
  State<UserAccount> createState() => _UserAccountState();
}

class _UserAccountState extends State<UserAccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomAppBar(
              text: Applabels.myAccount,
            ),
            Padding(
              padding: EdgeInsets.all(AppConst.padding * 3),
              child: Column(
                children: [
                  SizedBox(
                    height: AppConst.spacing / 2,
                  ),
                  Container(
                    width: double.infinity,
                    color: AppColors.whiteColor,
                    child: Padding(
                      padding: EdgeInsets.all(AppConst.padding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            child: Icon(
                              Icons.person_rounded,
                              size: 80,
                            ),
                          ),
                          SizedBox(
                            width: AppConst.spacing,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 180,
                                child: Text(
                                  SessionController().userName ?? "Anonymous",
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyle.primaryBoldStyle
                                      .copyWith(fontSize: 25),
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 24, 8),
                                decoration: BoxDecoration(
                                  color: AppColors.grey,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  SessionController().mobileNumber ??
                                      "03***********",
                                  style: AppTextStyle.primaryStyle
                                      .copyWith(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: AppConst.spacing,
                  ),
                  Divider(
                    color: Colors.grey[200],
                    height: 10,
                    thickness: 10,
                  ),
                  SizedBox(height: AppConst.spacing),
                  ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                    title: Text(
                      Applabels.personalDetails,
                      style: AppTextStyle.helveticaStyle
                          .copyWith(fontSize: 18, color: Colors.grey[800]),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                    ),
                    leading: const IconInsideContainer(icon: Icons.person),
                  ),
                  SizedBox(
                    height: AppConst.spacing / 2,
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const BookingScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 600),
                        ),
                      );
                    },
                    contentPadding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                    title: Text(
                      Applabels.offeredRides,
                      style: AppTextStyle.helveticaStyle
                          .copyWith(fontSize: 18, color: Colors.grey[800]),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                    ),
                    leading: const IconInsideContainer(icon: Icons.book),
                  ),
                  SizedBox(
                    height: AppConst.spacing / 2,
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const BookedRides(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 600),
                        ),
                      );
                    },
                    contentPadding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                    title: Text(
                      "Booked Rides",
                      style: AppTextStyle.helveticaStyle.copyWith(
                        fontSize: 18,
                        color: Colors.grey[800],
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                    ),
                    leading:
                        const IconInsideContainer(icon: Icons.book_outlined),
                  ),
                  SizedBox(
                    height: AppConst.spacing / 2,
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                    title: Text(
                      Applabels.settings,
                      style: AppTextStyle.helveticaStyle.copyWith(
                        fontSize: 18,
                        color: Colors.grey[800],
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                    ),
                    leading: const IconInsideContainer(icon: Icons.settings),
                  ),
                  SizedBox(
                    height: AppConst.spacing * 2,
                  ),
                  PrimaryButton(
                    text: "Logout",
                    onPressed: () {
                      SignupController().logOut(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

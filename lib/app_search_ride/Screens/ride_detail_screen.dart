import 'dart:io';

import 'package:carpool_app/app_search_ride/Controller/rideController.dart';
import 'package:carpool_app/app_search_ride/Model/ride_model.dart';
import 'package:carpool_app/app_search_ride/Screens/confirmation_screen.dart';
import 'package:carpool_app/app_signup/view/signup.dart';
import 'package:carpool_app/config/app_fonts.dart';
import 'package:carpool_app/config/app_widgets.dart';
import 'package:carpool_app/config/appcolors.dart';
import 'package:carpool_app/controller/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class RideDetailScreen extends StatelessWidget {
  RideDetailScreen({required this.rideDetails, super.key});

  RideController rideController = Get.put(RideController());

  Ride rideDetails;
  int requiredSeats = 1;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Obx(
          () => rideController.isLoading.value
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SpinKitThreeBounce(
                        size: 50,
                        color: AppColors.appTheme[2],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Booking Ride",
                        style: AppTextStyle.poppinsStyle.copyWith(fontSize: 23),
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomAppBar2(
                      text: "Ride Details",
                      subtext:
                          "${DateFormat("d MMMM, yyyy").format(rideDetails.date)}  | ${DateFormat("hh:mm a").format(DateFormat("HH:mm").parse(rideDetails.time))}",
                    ),
                    Container(
                      height: 110,
                      padding: const EdgeInsets.only(left: 16.0, right: 16),
                      // color: Colors.amber,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${rideDetails.selectedVehicle.maker} ${rideDetails.selectedVehicle.name}",
                                style: AppTextStyle.helveticaStyle
                                    .copyWith(fontSize: 22),
                              ),
                              Text(
                                "Model: ${rideDetails.selectedVehicle.model}",
                                style: AppTextStyle.helveticaStyle.copyWith(
                                    fontSize: 14, color: Colors.grey[700]),
                              ),
                              SizedBox(
                                width: 200,
                                child: Text(
                                  "Leaving at: ${DateFormat("hh:mm a").format(DateFormat("HH:mm").parse(rideDetails.time))}",
                                  style: AppTextStyle.helveticaStyle.copyWith(
                                      fontSize: 14,
                                      color: AppColors.appTheme[2]),
                                ),
                              ),
                              // SizedBox(
                              //   width: 200,
                              //   child: Text(
                              //     "Arriving (approx~): ${DateFormat("hh:mm a").format(DateFormat("HH:mm").parse(rideDetails.time!))}",
                              //     style: AppTextStyle.helveticaStyle
                              //         .copyWith(fontSize: 14, color: Colors.red[700]),
                              //   ),
                              // ),
                            ],
                          ),
                          Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: AppColors.grey,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Image.asset(
                                "assets/images/car.png",
                                height: 100,
                              ))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Divider(
                      indent: 10,
                      endIndent: 10,
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    SizedBox(
                                      width: 300,
                                      child: Text(
                                        rideDetails.pickupAddress,
                                        // maxLines: 2,
                                        style: AppTextStyle.helveticaStyle
                                            .copyWith(
                                                fontSize: 14,
                                                color: Colors.grey[700]),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    SizedBox(
                                      width: 300,
                                      child: Text(
                                        rideDetails.dropoffAddress,
                                        // maxLines: 2,
                                        style: AppTextStyle.helveticaStyle
                                            .copyWith(
                                                fontSize: 14,
                                                color: Colors.grey[700]),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text("Route Details",
                                    style: AppTextStyle.helveticaBoldStyle
                                        .copyWith(
                                            fontSize: 14,
                                            color: Colors.grey[700])),
                                Container(
                                  width: 330,
                                  decoration: BoxDecoration(
                                    color: AppColors.grey,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12.0),
                                    child: Text(
                                      rideDetails.details == ""
                                          ? "No Details Provided"
                                          : rideDetails.details!,
                                      style: AppTextStyle.helveticaStyle
                                          .copyWith(
                                              fontSize: 14,
                                              color: Colors.grey[700]),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                SizedBox(
                                  width: 230,
                                  // color: Colors.amber,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Seats Available: ",
                                          style: AppTextStyle.helveticaStyle
                                              .copyWith(fontSize: 14)),
                                      Row(
                                        children: [
                                          Image.asset(
                                            "assets/images/car-seat.png",
                                            height: 18,
                                          ),
                                          Text(
                                              '${rideDetails.totalSeats - rideDetails.bookedSeats}',
                                              style: AppTextStyle.helveticaStyle
                                                  .copyWith(fontSize: 14)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                if (rideDetails.totalSeats -
                                        rideDetails.bookedSeats !=
                                    0)
                                  StatefulBuilder(
                                    builder: (BuildContext context,
                                        StateSetter setState) {
                                      return SizedBox(
                                        width: 250,
                                        // color: Colors.amber,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Select Required: ",
                                              style: AppTextStyle.helveticaStyle
                                                  .copyWith(fontSize: 14),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                IconButton(
                                                    onPressed: () {
                                                      if (requiredSeats > 1) {
                                                        setState(() {
                                                          requiredSeats--;
                                                        });
                                                      }
                                                    },
                                                    icon: const Icon(
                                                      Icons
                                                          .remove_circle_outline,
                                                      size: 20,
                                                    )),
                                                Text(
                                                  '$requiredSeats',
                                                  style: AppTextStyle
                                                      .helveticaStyle
                                                      .copyWith(fontSize: 14),
                                                ),
                                                IconButton(
                                                    onPressed: () {
                                                      if (requiredSeats <
                                                          rideDetails
                                                                  .totalSeats -
                                                              rideDetails
                                                                  .bookedSeats) {
                                                        setState(() {
                                                          requiredSeats++;
                                                        });
                                                      }
                                                    },
                                                    icon: const Icon(
                                                      Icons.add_circle_outline,
                                                      size: 20,
                                                    )),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                const SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: 230,
                                  // color: Colors.amber,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Fare Per Seat: ",
                                          style: AppTextStyle.helveticaStyle
                                              .copyWith(fontSize: 14)),
                                      Text("Rs.${rideDetails.pricePerSeat}",
                                          style: AppTextStyle.helveticaBoldStyle
                                              .copyWith(
                                                  fontSize: 25,
                                                  color: Colors.grey[700])),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                if (rideDetails.totalSeats -
                                        rideDetails.bookedSeats !=
                                    0)
                                  PrimaryButton(
                                      text: "Book Now",
                                      onPressed: () async {
                                        if (!SessionController().isLoggedIn!) {
                                          await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SignupPage()));
                                        }
                                        if (SessionController().isLoggedIn !=
                                            false) {
                                          bool response =
                                              await rideController.bookNow(
                                                  rideDetails, requiredSeats);

                                          if (response) {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (context,
                                                        animation,
                                                        secondaryAnimation) =>
                                                    ConfirmationScreen(
                                                  rideId: rideDetails.rideId,
                                                ),
                                                transitionsBuilder: (context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child) {
                                                  const begin = Offset(1.0,
                                                      0.0); // Slide in from right
                                                  const end = Offset.zero;
                                                  const curve = Curves.ease;

                                                  var tween = Tween(
                                                          begin: begin,
                                                          end: end)
                                                      .chain(CurveTween(
                                                          curve: curve));
                                                  var offsetAnimation =
                                                      animation.drive(tween);

                                                  return SlideTransition(
                                                    position: offsetAnimation,
                                                    child: child,
                                                  );
                                                },
                                                transitionDuration: const Duration(
                                                    milliseconds:
                                                        800), // Slower transition
                                              ),
                                            );
                                          } else {
                                            rideController.showAlertDialog(
                                                context,
                                                "Oops! Error while booking",
                                                "assets/images/warning.png");
                                          }
                                        } else {
                                          if (context.mounted) {
                                            // Navigator.pop(context);
                                            await showDialog(
                                              context: context,
                                              builder: (context) {
                                                return CustomPopup(
                                                  imageUrl:
                                                      "assets/images/warning.png",
                                                  message: "Please Login First",
                                                );
                                              },
                                            );
                                          }
                                        }
                                      }),
                                const SizedBox(
                                  height: 30,
                                ),
                                Align(
                                    alignment: Alignment.center,
                                    child: Text("Contact Driver",
                                        style: AppTextStyle.helveticaStyle
                                            .copyWith(
                                                fontSize: 12,
                                                color: Colors.grey[600]))),
                                const SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          String contact =
                                              rideDetails.contactNumber;

                                          String androidUrl =
                                              "whatsapp://send?phone=$contact";
                                          String iosUrl =
                                              "https://wa.me/$contact";

                                          String webUrl =
                                              'https://api.whatsapp.com/send/?phone=$contact';

                                          try {
                                            if (Platform.isIOS) {
                                              await launchUrl(
                                                  Uri.parse(iosUrl));
                                            } else {
                                              await launchUrl(
                                                  Uri.parse(androidUrl));
                                            }
                                          } catch (e) {
                                            await launchUrl(Uri.parse(webUrl),
                                                mode: LaunchMode
                                                    .externalApplication);
                                          }
                                        },
                                        child: Image.asset(
                                          "assets/images/whatsapp.png",
                                          height: 50,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          String contact =
                                              rideDetails.contactNumber;

                                          String androidUrl = "tel:$contact";
                                          String iosUrl = "tel:$contact";

                                          try {
                                            if (Platform.isIOS) {
                                              await launchUrl(
                                                  Uri.parse(iosUrl));
                                            } else {
                                              await launchUrl(
                                                  Uri.parse(androidUrl));
                                            }
                                          } catch (e) {
                                            print("cant launch");
                                          }
                                        },
                                        child: Image.asset(
                                          "assets/images/telephone-call.png",
                                          height: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

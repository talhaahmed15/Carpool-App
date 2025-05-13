import 'package:carpool_app/config/app_const.dart';
import 'package:carpool_app/config/app_fonts.dart';
import 'package:carpool_app/config/app_widgets.dart';
import 'package:carpool_app/config/appcolors.dart';
import 'package:carpool_app/controller/session_controller.dart';
import 'package:carpool_app/controller/sharedpref_controller.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../app_search_ride/Model/ride_model.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Function to update ride status
  Future<void> _updateRideStatus(String rideId, String status) async {
    try {
      await firestore.collection('rides').doc(rideId).update({
        'rideStatus': status,
      });

      SessionController().rideStatus = false;
      SharedPrefController().setBool("rideStatus", false);

      _showAlertDialog(
          context, "Ride Status Updated", "assets/images/checked.png");
    } catch (e) {
      _showAlertDialog(
          context, "Oops! There's been an error.", "assets/images/warning.png");
    }
  }

  Stream<Map<String, List<Ride>>> fetchRidesWithDelay() {
    return firestore
        .collection('rides')
        .where('contactNumber', isEqualTo: SessionController().mobileNumber)
        .snapshots()
        .map((snapshot) {
      List<Ride> rides = snapshot.docs.map((doc) {
        return Ride.fromFirestore(doc.data());
      }).toList();

      // Categorize rides into Active, Completed, and Cancelled
      List<Ride> activeRides =
          rides.where((ride) => ride.rideStatus == 'active').toList();
      List<Ride> completedRides =
          rides.where((ride) => ride.rideStatus == 'completed').toList();
      List<Ride> cancelledRides =
          rides.where((ride) => ride.rideStatus == 'cancelled').toList();

      return {
        'active': activeRides,
        'completed': completedRides,
        'cancelled': cancelledRides,
      };
    });
  }

  Future _showAlertDialog(
      BuildContext context, String message, String image) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Image.asset(
                image,
                height: 100,
              ),
              SizedBox(height: AppConst.spacing * 2),
              Text(
                message,
                style: AppTextStyle.poppinsStyle.copyWith(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                "OK",
                style: AppTextStyle.helveticaStyle.copyWith(fontSize: 14),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const CustomAppBar2(
            text: "Rides Offered",
            subtext: "All the rides you have offered",
          ),
          Expanded(
            child: StreamBuilder<Map<String, List<Ride>>>(
              stream: fetchRidesWithDelay(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error fetching rides: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmer();
                }

                // Get the categorized rides
                final rides = snapshot.data ??
                    {
                      'active': [],
                      'completed': [],
                      'cancelled': [],
                    };

                return ListView(
                  children: [
                    // Active Ride Section
                    if (rides['active']!.isNotEmpty) ...[
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.appTheme[2], // Background color
                            borderRadius:
                                BorderRadius.circular(4), // Rounded corners
                          ),
                          padding: const EdgeInsets.all(12.0),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20.0), // Side margin for spacing
                          child: Text(
                            'Active Ride',
                            style: AppTextStyle.primaryBoldStyle.copyWith(
                              fontSize: 20,
                              color: Colors.white, // Text color for contrast
                            ),
                          ),
                        ),
                      ),
                      ridesOffered(rides['active']![0]), // Only one active ride
                    ],

                    // Completed Rides Section
                    if (rides['completed']!.isNotEmpty) ...[
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green, // Background color
                            borderRadius:
                                BorderRadius.circular(4), // Rounded corners
                          ),
                          padding: const EdgeInsets.all(12.0),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20.0), // Side margin for spacing
                          child: Text(
                            'Completed Rides',
                            style: AppTextStyle.primaryBoldStyle.copyWith(
                              fontSize: 20,
                              color: Colors.white, // Text color for contrast
                            ),
                          ),
                        ),
                      ),
                      ...rides['completed']!.map(ridesOffered).toList(),
                    ],

                    // Cancelled Rides Section
                    if (rides['cancelled']!.isNotEmpty) ...[
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.blackColor, // Background color
                            borderRadius:
                                BorderRadius.circular(4), // Rounded corners
                          ),
                          padding: const EdgeInsets.all(12.0),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20.0), // Side margin for spacing
                          child: Text(
                            'Cancelled Rides',
                            style: AppTextStyle.primaryBoldStyle.copyWith(
                              fontSize: 20,
                              color: Colors.white, // Text color for contrast
                            ),
                          ),
                        ),
                      ),
                      ...rides['cancelled']!.map(ridesOffered).toList(),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Shimmer placeholder widget
  Widget _buildShimmer() {
    return ListView.builder(
      itemCount: 5, // Number of shimmer placeholders you want to show
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Placeholder for ride details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150,
                      height: 20,
                      color: Colors.grey[200],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 20,
                      color: Colors.grey[200],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          color: Colors.grey[200],
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 150,
                          height: 20,
                          color: Colors.grey[200],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          color: Colors.grey[200],
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 150,
                          height: 20,
                          color: Colors.grey[200],
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Column ridesOffered(Ride ride) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ride Number",
                      style: AppTextStyle.helveticaStyle.copyWith(
                        fontSize: 12,
                      )),
                  Text(
                    ride.rideId,
                    style: AppTextStyle.helveticaStyle.copyWith(fontSize: 25),
                  ),
                  Text(
                    "Time to Leave: ${DateFormat("hh:mm a").format(DateFormat("HH:mm").parse(ride.time))}",
                    style: AppTextStyle.helveticaStyle
                        .copyWith(fontSize: 15, color: Colors.grey),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: ride.rideStatus == 'active'
                            ? Colors.red
                            : ride.rideStatus == "completed"
                                ? Colors.green
                                : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      SizedBox(
                        width: 175,
                        child: Text(
                          ride.pickupAddress,
                          style: AppTextStyle.helveticaStyle
                              .copyWith(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: ride.rideStatus == 'active'
                            ? Colors.blue
                            : ride.rideStatus == "completed"
                                ? Colors.green
                                : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      SizedBox(
                        width: 175,
                        child: Text(
                          ride.dropoffAddress,
                          style: AppTextStyle.helveticaStyle
                              .copyWith(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Booking Date",
                    style: AppTextStyle.helveticaStyle
                        .copyWith(fontSize: 12, color: Colors.grey[700]),
                  ),
                  Text(
                    DateFormat("d MMMM, yyyy").format(ride.date),
                    style: AppTextStyle.helveticaStyle
                        .copyWith(fontSize: 17, color: Colors.grey[700]),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: AppColors.grey,
                          borderRadius: BorderRadius.circular(8)),
                      child: Image.asset(
                        ride.rideStatus == 'cancelled'
                            ? "assets/images/car-greyed.png"
                            : ride.rideStatus == 'completed'
                                ? "assets/images/car-green.png"
                                : "assets/images/car.png",
                        height: 100,
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "PKR ${ride.pricePerSeat}",
                    style: AppTextStyle.helveticaStyle
                        .copyWith(fontSize: 20, color: Colors.grey),
                  )
                ],
              )
            ],
          ),
        ),
        if (ride.rideStatus == 'active') ...[
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16),
            child: PrimaryButton(
              text: "Complete Ride",
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      title: Text(
                        "Confirm Completion",
                        style: AppTextStyle.helveticaBoldStyle,
                      ),
                      content: Text(
                        "Are you sure you want to complete the ride?",
                        style: AppTextStyle.helveticaStyle,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Cancel",
                              style: AppTextStyle.helveticaStyle),
                        ),
                        TextButton(
                          onPressed: () {
                            _updateRideStatus(ride.rideId, 'completed');
                            Navigator.of(context).pop();
                          },
                          child:
                              Text("Yes", style: AppTextStyle.helveticaStyle),
                        ),
                      ],
                    );
                  },
                );
              },
              color: Colors.green,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16),
            child: PrimaryButton(
              text: "Cancel Ride",
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      title: Text(
                        "Confirm Completion",
                        style: AppTextStyle.helveticaBoldStyle,
                      ),
                      content: Text(
                        "Are you sure you want to cancel the ride?",
                        style: AppTextStyle.helveticaStyle,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Cancel",
                              style: AppTextStyle.helveticaStyle),
                        ),
                        TextButton(
                          onPressed: () {
                            _updateRideStatus(ride.rideId, 'cancelled');
                            Navigator.of(context).pop();
                          },
                          child:
                              Text("Yes", style: AppTextStyle.helveticaStyle),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
        const SizedBox(
          width: 225,
          child: Divider(),
        )
      ],
    );
  }
}

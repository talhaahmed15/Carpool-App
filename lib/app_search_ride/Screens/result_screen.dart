import 'package:carpool_app/app_search_ride/Model/ride_model.dart';
import 'package:carpool_app/app_search_ride/Screens/ride_detail_screen.dart';
import 'package:carpool_app/config/app_fonts.dart';
import 'package:carpool_app/config/app_widgets.dart';
import 'package:carpool_app/config/appcolors.dart';
import 'package:carpool_app/controller/session_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class RidesScreen extends StatelessWidget {
  const RidesScreen({
    required this.pickupCoordinate,
    required this.dropoffCoordinate,
    super.key,
  });

  final LatLng pickupCoordinate;
  final LatLng dropoffCoordinate;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            const CustomAppBar2(
              text: "Results",
              subtext: "Searching for the best rides near you.",
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('rides')
                    .where("rideStatus", isEqualTo: 'active')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List<Ride> rides = snapshot.data!.docs.map((doc) {
                    return Ride.fromFirestore(
                        doc.data() as Map<String, dynamic>);
                  }).toList();

                  // Filter rides based on distance
                  List<Ride> filteredRides = rides.where((ride) {
                    const Distance distance = Distance();

                    LatLng pickupLatLng = LatLng(
                        ride.pickupCoordinates.latitude,
                        ride.pickupCoordinates.longitude);
                    LatLng dropOffLatLng = LatLng(
                        ride.dropoffCoordinates.latitude,
                        ride.dropoffCoordinates.longitude);

                    // return true;
                    double pickupDistance =
                        distance(pickupCoordinate, pickupLatLng);
                    double dropoffDistance =
                        distance(dropoffCoordinate, dropOffLatLng);

                    return pickupDistance <= 5000 && dropoffDistance <= 5000;
                  }).toList();

                  if (filteredRides.isEmpty) {
                    return const Center(
                        child: Text('No rides found within 10 km.'));
                  }

                  return ListView.builder(
                    itemCount: filteredRides.length,
                    itemBuilder: (context, index) {
                      var ride = filteredRides[index];

                      print(SessionController().user.userId);

                      return InkWell(
                        onTap: () {
                          if (SessionController().user.userId != '' &&
                              ride.bookedBy!
                                  .contains(SessionController().user.userId)) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return CustomPopup(
                                  imageUrl: "assets/images/warning.png",
                                  message: "You have already booked this ride.",
                                );
                              },
                            );
                          } else {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      RideDetailScreen(
                                        rideDetails: ride,
                                      ),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.ease;

                                    var tween = Tween(begin: begin, end: end)
                                        .chain(CurveTween(curve: curve));
                                    var offsetAnimation =
                                        animation.drive(tween);

                                    return SlideTransition(
                                      position: offsetAnimation,
                                      child: child,
                                    );
                                  },
                                  transitionDuration:
                                      const Duration(milliseconds: 800)),
                            );
                          }
                        },
                        child: RideTile(
                          index: index,
                          ride: filteredRides[index],
                          // distance: 3.0, // Placeholder for distance calculation
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RideTile extends StatelessWidget {
  const RideTile({
    required this.ride,
    // required this.distance,
    required this.index,
    super.key,
  });

  final int index;
  // final double distance;
  final Ride ride;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.white : Colors.grey[200],
      ),
      child: ListTile(
        leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: SessionController().user.userId != '' &&
                        ride.bookedBy!.contains(SessionController().user.userId)
                    ? Colors.amber
                    : index % 2 == 0
                        ? Colors.grey[200]
                        : Colors.white,
                borderRadius: BorderRadius.circular(8)),
            child: Image.asset(
              'assets/images/car.png',
            )),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${ride.selectedVehicle.maker} ${ride.selectedVehicle.name}',
              style: AppTextStyle.helveticaBoldStyle.copyWith(fontSize: 18),
            ),
            Text(
              'Rs.${ride.pricePerSeat}',
              style: AppTextStyle.helveticaBoldStyle
                  .copyWith(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat("hh:mm a")
                      .format(DateFormat("HH:mm").parse(ride.time)),
                  style: AppTextStyle.helveticaStyle
                      .copyWith(fontSize: 12, color: AppColors.appTheme[2]),
                ),
                Row(
                  children: [
                    Image.asset(
                      "assets/images/car-seat.png",
                      height: 15,
                    ),
                    Text('${ride.bookedSeats}/${ride.totalSeats}',
                        style:
                            AppTextStyle.helveticaStyle.copyWith(fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.blue,
                  size: 18,
                ),
                const SizedBox(
                  width: 4,
                ),
                SizedBox(
                  width: 200,
                  child: Text(
                    ride.pickupAddress,
                    maxLines: 1,
                    style: AppTextStyle.helveticaStyle.copyWith(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 18,
                ),
                const SizedBox(
                  width: 4,
                ),
                SizedBox(
                  width: 200,
                  child: Text(
                    ride.dropoffAddress,
                    maxLines: 1,
                    style: AppTextStyle.helveticaStyle.copyWith(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

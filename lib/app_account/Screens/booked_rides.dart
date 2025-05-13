import 'package:carpool_app/config/app_fonts.dart';
import 'package:carpool_app/config/app_widgets.dart';
import 'package:carpool_app/controller/session_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BookedRides extends StatelessWidget {
  const BookedRides({super.key});

  // Function to fetch booked rides data
  Future<List<Map<String, dynamic>>> fetchBookedRides() async {
    String userId = SessionController().user.userId!;

    // Reference to the 'booked' collection
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('booked')
        .get();

    // Extract the data from each document
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar2(
            text: "Booked Rides",
            subtext: 'All your previous rides',
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchBookedRides(),
              builder: (context, snapshot) {
                // If the future is still loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                // If there was an error
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // If data is successfully retrieved
                if (snapshot.hasData) {
                  final rides = snapshot.data!;

                  // If the 'booked' collection is empty
                  if (rides.isEmpty) {
                    return Center(child: Text('No booked rides available.'));
                  }

                  // Display the list of booked rides
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: rides.length,
                    itemBuilder: (context, index) {
                      final ride = rides[index];
                      return Container(
                        padding: EdgeInsets.all(8),
                        color: index % 2 == 0 ? Colors.white : Colors.grey[200],
                        child: ListTile(
                          tileColor:
                              index % 2 == 0 ? Colors.white : Colors.grey[200],
                          leading: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  color: index % 2 == 0
                                      ? Colors.grey[200]
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(6)),
                              child: Image.asset("assets/images/car.png")),
                          trailing: IconButton(
                            icon: Icon(Icons.call),
                            onPressed: () async {
                              final Uri launchUri = Uri(
                                scheme: 'tel',
                                path: "$ride['contactNumberOfDriver']",
                              );

                              try {
                                await launchUrl(Uri.parse(
                                    "tel: ${ride['contactNumberOfDriver']}"));
                              } catch (e) {
                                print("Oops! There has been an error");
                              }
                            },
                          ),
                          title: Text(
                            "Driver: ${ride['addedBy']}",
                            style: AppTextStyle.primaryBoldStyle
                                .copyWith(fontSize: 16),
                          ),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${ride['contactNumberOfDriver']}',
                                style: AppTextStyle.primaryStyle,
                              ),
                              Row(
                                children: [
                                  Text('Booked: ',
                                      style: AppTextStyle.primaryStyle
                                          .copyWith(fontSize: 14)),
                                  Image.asset(
                                    "assets/images/car-seat.png",
                                    height: 18,
                                  ),
                                  Text('${ride['bookedSeats']}',
                                      style: AppTextStyle.primaryStyle
                                          .copyWith(fontSize: 14)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                // If no data was found (should not happen due to empty check above)
                return Center(child: Text('No booked rides.'));
              },
            ),
          ),
        ],
      ),
    );
  }
}

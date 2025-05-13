import 'package:carpool_app/app_search_ride/Model/ride_model.dart';
import 'package:carpool_app/config/app_const.dart';
import 'package:carpool_app/config/app_fonts.dart';
import 'package:carpool_app/controller/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RideController extends GetxController {
  RxBool isLoading = false.obs;

  bookNow(Ride rideDetails, int requiredSeats) async {
    isLoading.value = true;

    try {
      // print("${SessionController().user.userId}");
      await FirebaseFirestore.instance
          .collection('rides')
          .doc(rideDetails.rideId)
          .update({
        "bookedSeats": rideDetails.bookedSeats + requiredSeats,
        "bookedBy": FieldValue.arrayUnion([SessionController().user.userId])
      });

      await FirebaseFirestore.instance
          .collection("booked")
          .doc(rideDetails.rideId)
          .set({
        SessionController().user.userId!: {
          "userName": SessionController().userName,
          "userId": SessionController().user.userId,
          "mobileNumber": SessionController().mobileNumber,
          "bookedSeats": requiredSeats,
        }
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection("users")
          .doc(SessionController().user.userId)
          .collection("booked")
          .doc(rideDetails.rideId)
          .set({
        "userName": SessionController().userName,
        "bookedSeats": requiredSeats,
        "price": rideDetails.pricePerSeat,
        "addedBy": rideDetails.addedBy,
        "contactNumberOfDriver": rideDetails.contactNumber,
        "rideStatus": rideDetails.rideStatus
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print("Error while booking: $e");

      // Show error dialog
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future showAlertDialog(
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
}

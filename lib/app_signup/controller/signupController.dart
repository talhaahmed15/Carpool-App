import 'package:carpool_app/Models/user_model.dart';
import 'package:carpool_app/app_signup/view/login.dart';
import 'package:carpool_app/config/app_const.dart';
import 'package:carpool_app/config/app_fonts.dart';
import 'package:carpool_app/controller/session_controller.dart';
import 'package:carpool_app/controller/sharedpref_controller.dart';
import 'package:carpool_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  RxBool isUploading = false.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  signUpFireBase(BuildContext context, firstName, lastName, email, String phone,
      String password) async {
    isUploading.value = true;

    // Adding user data to Firestore
    try {
      var querySnapshot = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phone.removeAllWhitespace)
          .get();

      if (querySnapshot.docs.isEmpty) {
        await _firestore.collection('users').add({
          'firstName': firstName,
          'lastName': lastName,
          'email': email.isNotEmpty ? email : null,
          'phone': phone.removeAllWhitespace,
          'password': password,
        }).then((DocumentReference docRef) async {
          String docId = docRef.id;

          await _firestore.collection('users').doc(docId).update({
            'userId': docId,
          });

          // Retrieve the newly added user data
          DocumentSnapshot newUserDoc = await docRef.get();

          // Convert Firestore document to UserModel
          UserModel user = UserModel.fromDocument(newUserDoc);

          SessionController().user = user;
        });

        SessionController().mobileNumber = phone;
        SessionController().userName = '$firstName $lastName';
        SessionController().isLoggedIn = true;

        SharedPrefController().saveSession();

        if (context.mounted) {
          // Show success dialog
          await _showDialog(
            context,
            "assets/images/checked.png",
            "Account created successfully!",
          );

          // Navigate back to the login screen
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        if (context.mounted) {
          await _showDialog(context, "assets/images/warning.png",
              "Phone number already exists. \n Login instead.");
        }
        if (context.mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print("Error adding user: $e");

      if (context.mounted) {
        _showDialog(context, "assets/images/warning.png",
            "Oops! There was an error.\n Please Try Later.");
      }
    } finally {
      isUploading.value = false;
    }
  }

  // Function to handle user login
  Future<dynamic> loginFireBase(
      BuildContext context, String phone, String password) async {
    isUploading.value = true;

    try {
      var querySnapshot = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phone.removeAllWhitespace)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userDoc = querySnapshot.docs.first;

        UserModel user = UserModel.fromDocument(userDoc);

        // Check if the password matches
        if (user.password == password) {
          SessionController().mobileNumber = user.phoneNumber;
          SessionController().userName = '${user.firstName} ${user.lastName}';
          SessionController().isLoggedIn = true;
          SessionController().user = user;

          SharedPrefController().saveSession();

          CollectionReference rides =
              FirebaseFirestore.instance.collection('rides');
          await Future.delayed(const Duration(seconds: 1));

          var querySnapshot = await rides
              .where('contactNumber',
                  isEqualTo: SessionController().mobileNumber)
              .where('rideStatus', isEqualTo: 'active')
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            print("User already has an active ride.");
            SessionController().rideStatus = true;
            SharedPrefController().setBool("rideStatus", true);
          }
          if (context.mounted) {
            // await _showDialog(
            //     context, "assets/images/checked.png", "Logged in successfully");

            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => MyApp()));
          }
          return true;
          // if (context.mounted) {
          //   Navigator.pop(context);
          // }
        } else {
          return null;
          // Incorrect password
          // if (context.mounted) {
          //   await _showDialog(context, "assets/images/warning.png",
          //       "Incorrect password.\n Please try again.");
          // }
        }
      } else {
        // Phone number not found
        if (context.mounted) {
          await _showDialog(context, "assets/images/warning.png",
              "Phone number not found.\n Please sign up.");
        }
      }
    } catch (e) {
      print("Error logging in: $e");
      if (context.mounted) {
        _showDialog(context, "assets/images/warning.png",
            "Oops! There was an error.\n Please Try Later.");
      }
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> logOut(BuildContext context) async {
    isUploading.value = true;

    SessionController().clearSession();

    isUploading.value = false;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  Future _showDialog(
      BuildContext context, String image, String errorText) async {
    return showDialog(
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
                errorText,
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

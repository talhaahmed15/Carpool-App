import 'dart:convert';
import 'dart:math';

import 'package:carpool_app/controller/session_controller.dart';
import 'package:carpool_app/controller/sharedpref_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carpool_app/Models/vehicle.dart';
import 'package:carpool_app/config/app_fonts.dart';
import 'package:carpool_app/config/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfferFormController extends GetxController {
  RxBool isUploading = false.obs;

  RxBool isVehicleSelected = true.obs;
  RxBool isDateSelected = true.obs;
  RxBool isTimeSelected = true.obs;

  var selectedDate = Rx<DateTime?>(DateTime.now());
  var selectedTime = Rx<TimeOfDay?>(TimeOfDay.now());

  Rx<Vehicle?> selectedVehicle = Rx<Vehicle?>(null);
  Rx<int> selectedSeats = 4.obs;
  List<int> seatList = [1, 2, 3, 4, 5];
  RxList<Vehicle> vehicleList = <Vehicle>[].obs;

  TextEditingController pickupController = TextEditingController();
  TextEditingController pickupSearchController = TextEditingController();

  LatLng? pickupCoordinates;
  LatLng? pickupSearchCoordinates;

  LatLng? dropoffCoordinates;
  LatLng? dropoffSearchCoordinates;

  TextEditingController dropoffController = TextEditingController();
  TextEditingController dropoffSearchController = TextEditingController();

  TextEditingController priceController = TextEditingController();
  TextEditingController routeDetailsController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    DateTime currentTime = DateTime.now();
    DateTime newTime = currentTime.add(Duration(minutes: 5));

// Assign the new time to selectedTime
    selectedTime.value = TimeOfDay.fromDateTime(newTime);

    getVehicleList();
    print('Controller initialized');
  }

  String generateRandomSequence(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  Future<bool> uploadRideToFirebase() async {
    isUploading.value = true;
    print("------------ Uploading Data to Firebase --------------------");

    try {
      CollectionReference rides =
          FirebaseFirestore.instance.collection('rides');
      await Future.delayed(const Duration(seconds: 1));

      var querySnapshot = await rides
          .where('contactNumber', isEqualTo: SessionController().mobileNumber)
          .where('rideStatus', isEqualTo: 'active')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print("User already has an active ride.");
        SessionController().rideStatus = true;
        SharedPrefController().setBool("rideStatus", true);

        return false;
      }

      String rideId = generateRandomSequence(7);

      // Create the document data to be added
      Map<String, dynamic> rideData = {
        "rideId": rideId,
        'pickupAddress': pickupController.text,
        'pickupCoordinates':
            GeoPoint(pickupCoordinates!.latitude, pickupCoordinates!.longitude),
        'dropoffAddress': dropoffController.text,
        'dropoffCoordinates': GeoPoint(
            dropoffCoordinates!.latitude, dropoffCoordinates!.longitude),
        'date': selectedDate.value!,
        'time': '${selectedTime.value!.hour}:${selectedTime.value!.minute}',
        'selectedVehicle': selectedVehicle.value!.toJson(),
        'totalSeats': selectedSeats.value,
        "bookedSeats": 0,
        'pricePerSeat': priceController.text,
        'routeDetails': routeDetailsController.text,
        "addedBy": SessionController().userName,
        "contactNumber": SessionController().mobileNumber,
        "rideStatus": "active",
        "bookedBy": []
      };

      await rides.doc(rideId).set(rideData);
      print(rideData);

      SessionController().rideStatus = true;
      SharedPrefController().setBool("rideStatus", true);

      // Reset form values
      pickupController.clear();
      dropoffController.clear();
      selectedDate.value = null;
      selectedTime.value = null;
      selectedVehicle.value = null;
      selectedSeats.value = 4;
      priceController.clear();
      routeDetailsController.clear();
      pickupCoordinates = null;
      dropoffCoordinates = null;

      print("------------ Data Uploaded to Firebase --------------------");
      return true;
    } catch (e) {
      print('Error sending data to Firestore: $e');
      print("------------ Failed Uploading to Firebase --------------------");
      return false;
    } finally {
      isUploading.value = false;
    }
  }

  Future<String> addVehicle(String name, String make, String model) async {
    try {
      // Check if the vehicle with the same details already exists
      bool vehicleExists = vehicleList.any((vehicle) =>
          vehicle.name == name &&
          vehicle.maker == make &&
          vehicle.model == model);

      if (vehicleExists) {
        return "This Vehicle already exists.";
      }

      // Add the new Vehicle to the RxList
      vehicleList.add(Vehicle(name: name, maker: make, model: model));

      List<String> vehicleJsonList =
          vehicleList.map((vehicle) => jsonEncode(vehicle.toJson())).toList();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList("VehicleList", vehicleJsonList);

      return "Vehicle added Successfully.";
    } catch (e) {
      print('Error occurred: ${e.toString()}');
      return "Error: $e";
    }
  }

  Future<void> getVehicleList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    List<String> tempList = pref.getStringList("VehicleList") ?? [];

    vehicleList.value =
        tempList.map((e) => Vehicle.fromJson(jsonDecode(e))).toList();

    // Define hardcoded vehicles
    List<Vehicle> hardcodedVehicles = [
      Vehicle(name: "Cultus", model: "2000", maker: "Suzuki"),
      Vehicle(name: "Civic", model: "2010", maker: "Honda"),
      Vehicle(name: "Supra", model: "2024", maker: "Toyota")
    ];

    // Add hardcoded vehicles only if they don't already exist
    for (var newVehicle in hardcodedVehicles) {
      bool vehicleExists = vehicleList.any((vehicle) =>
          vehicle.name == newVehicle.name &&
          vehicle.maker == newVehicle.maker &&
          vehicle.model == newVehicle.model);

      if (!vehicleExists) {
        vehicleList.add(newVehicle);
      }
    }

    print(
        'Vehicle list fetched and updated. Current vehicle list length: ${vehicleList.length}');
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime today = DateTime.now(); // Get today's date
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? today,
      firstDate: today, // Set firstDate to today
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.appTheme[2],
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
      print("Date Selected: $selectedDate");
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final TimeOfDay now = TimeOfDay.now();

    final DateTime nowDateTime = DateTime(2020, 1, 1, now.hour, now.minute);
    final DateTime minTimeDateTime = nowDateTime.add(Duration(minutes: 5));
    final TimeOfDay minTime = TimeOfDay.fromDateTime(minTimeDateTime);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime.value ?? minTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.appTheme[2],
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            timePickerTheme: TimePickerThemeData(
              dayPeriodColor: AppColors.appTheme[2],
              backgroundColor: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedTime.value) {
      selectedTime.value = picked;
      print("Time Selected: $selectedTime");
    }
  }

  void showVehicleSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.appTheme[2],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.appThemeLow[2],
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Center(
                  child: Text(
                    'Select Vehicle',
                    style: AppTextStyle.poppinsStyle.copyWith(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: vehicleList.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicleList[index];
                  return Container(
                    color: index % 2 == 0 ? Colors.white : AppColors.grey,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.appThemeLow[2],
                        child: const Icon(
                          Icons.directions_car,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        "${vehicle.maker} ${vehicle.name} ${vehicle.model}",
                        style:
                            AppTextStyle.helveticaStyle.copyWith(fontSize: 16),
                      ),
                      onTap: () {
                        selectedVehicle.value = vehicle;
                        // Close the modal
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showSeatSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.appTheme[2],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.appThemeLow[2],
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Center(
                  child: Text(
                    'Select Seats Available',
                    style: AppTextStyle.poppinsStyle.copyWith(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: seatList.length,
                itemBuilder: (context, index) {
                  final seat = seatList[index];
                  return Container(
                    color: index % 2 == 0 ? Colors.white : AppColors.grey,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.appThemeLow[2],
                        child: const Icon(
                          Icons.event_available,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        seat.toString(),
                        style:
                            AppTextStyle.helveticaStyle.copyWith(fontSize: 18),
                      ),
                      onTap: () {
                        selectedSeats.value = seat;
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

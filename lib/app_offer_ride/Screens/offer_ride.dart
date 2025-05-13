import 'package:carpool_app/app_account/Screens/bookings.dart';
import 'package:carpool_app/app_map/map_popup.dart';
import 'package:carpool_app/app_offer_ride/Controller/form_controller.dart';
import 'package:carpool_app/app_offer_ride/Screens/manage_vehicle.dart';
import 'package:carpool_app/config/app_const.dart';
import 'package:carpool_app/config/app_fonts.dart';
import 'package:carpool_app/config/app_widgets.dart';
import 'package:carpool_app/config/appcolors.dart';
import 'package:carpool_app/config/applabels.dart';
import 'package:carpool_app/controller/map_controller.dart';
import 'package:carpool_app/controller/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_place/google_place.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class OfferRide extends StatefulWidget {
  const OfferRide({super.key});

  @override
  State<OfferRide> createState() => _OfferRideState();
}

class _OfferRideState extends State<OfferRide> {
  OfferFormController formController = Get.put(OfferFormController());
  final _formKey = GlobalKey<FormState>();
  var mapController = Get.put(CustomMapController());

  final pickupTextNotifier = ValueNotifier<String>("");
  final dropoffTextNotifier = ValueNotifier<String>("");
  final ValueNotifier<bool> _showRedBorderNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _showRedBorderNotifier2 =
      ValueNotifier<bool>(false);
  List<AutocompletePrediction> predictions = [];
  @override
  void dispose() {
    pickupTextNotifier.dispose();
    dropoffTextNotifier.dispose();
    _showRedBorderNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: Obx(() {
          return formController.isUploading.value
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
                        "Checking Ride Status",
                        style: AppTextStyle.poppinsStyle.copyWith(fontSize: 23),
                      ),
                    ],
                  ),
                )
              : SessionController().rideStatus!
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/images/done.png",
                                  height: 150,
                                ),
                                Text(
                                    "You already have a ride offered. Complete it first",
                                    textAlign: TextAlign.center,
                                    style: AppTextStyle.helveticaStyle
                                        .copyWith(fontSize: 20)),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: PrimaryButton(
                                text: "Check Ride History",
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          const BookingScreen(),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        const begin = Offset(1.0, 0.0);
                                        const end = Offset.zero;
                                        const curve = Curves.easeInOut;

                                        var tween = Tween(
                                                begin: begin, end: end)
                                            .chain(CurveTween(curve: curve));
                                        var offsetAnimation =
                                            animation.drive(tween);

                                        return SlideTransition(
                                          position: offsetAnimation,
                                          child: child,
                                        );
                                      },
                                      transitionDuration:
                                          const Duration(milliseconds: 600),
                                    ),
                                  );

                                  setState(() {});
                                }),
                          )
                        ],
                      ),
                    )
                  : Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          CustomAppBar(text: Applabels.offerRide),
                          Padding(
                            padding: EdgeInsets.all(AppConst.padding * 2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 50,
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          await showMapBottomSheet(
                                              context, mapController, "pickup");

                                          formController.pickupController.text =
                                              mapController.pickupAddress ?? "";

                                          formController.pickupCoordinates =
                                              mapController.pickupCoordinates;
                                        },
                                        child: IconInsideContainer(
                                          size: 50,
                                          icon: Icons.location_on,
                                          color: AppColors.appTheme[2],
                                        ),
                                      ),
                                      SizedBox(
                                        width: AppConst.spacing / 2,
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            print("From where?");

                                            showSearchBottomSheet(
                                                context,
                                                mapController,
                                                "pickup",
                                                formController.pickupController,
                                                predictions);

                                            formController.pickupCoordinates =
                                                mapController.pickupCoordinates;
                                          },
                                          child: IgnorePointer(
                                            ignoring: true,
                                            child: FilledTextfield2(
                                              showRedBorderNotifier:
                                                  _showRedBorderNotifier,
                                              hintText: "From where?",
                                              controller: formController
                                                  .pickupController,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(left: 12),
                                  height: 25,
                                  child: const VerticalDivider(
                                    width: 20,
                                    thickness: 1,
                                    indent: 3,
                                    endIndent: 3,
                                    color: Colors.grey,
                                  ),
                                ),

                                // To Location Field
                                SizedBox(
                                  height: 50,
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          await showMapBottomSheet(context,
                                              mapController, "dropoff");

                                          formController
                                                  .dropoffController.text =
                                              mapController.dropoffAddress ??
                                                  "";

                                          formController.dropoffCoordinates =
                                              mapController.dropoffCoordinates;
                                        },
                                        child: IconInsideContainer(
                                          size: 50,
                                          icon: Icons.location_on,
                                          color: AppColors.appTheme[2],
                                        ),
                                      ),
                                      SizedBox(
                                        width: AppConst.spacing / 2,
                                      ),
                                      Expanded(
                                          child: InkWell(
                                        onTap: () async {
                                          print("To where?");

                                          showSearchBottomSheet(
                                              context,
                                              mapController,
                                              "dropoff",
                                              formController.dropoffController,
                                              predictions);

                                          formController.dropoffCoordinates =
                                              mapController.dropoffCoordinates;
                                        },
                                        child: IgnorePointer(
                                          ignoring: true,
                                          child: FilledTextfield2(
                                            showRedBorderNotifier:
                                                _showRedBorderNotifier2,
                                            controller: formController
                                                .dropoffController,
                                            hintText: "To where?",
                                          ),
                                        ),
                                      ))
                                    ],
                                  ),
                                ),
                                SizedBox(height: AppConst.spacing * 2),
                                Obx(
                                  () => Row(
                                    children: [
                                      // Date Picker
                                      Expanded(
                                        flex: 1,
                                        child: GestureDetector(
                                          onTap: () {
                                            formController.pickDate(context);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 8),
                                            decoration: BoxDecoration(
                                              color: AppColors.grey,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: !formController
                                                      .isDateSelected.value
                                                  ? Border.all(
                                                      color: Colors.red)
                                                  : null,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Text(
                                                  formController.selectedDate
                                                              .value !=
                                                          null
                                                      ? DateFormat('dd/MM/yyyy')
                                                          .format(formController
                                                              .selectedDate
                                                              .value!)
                                                      : 'Select Date',
                                                  style: AppTextStyle
                                                      .helveticaStyle
                                                      .copyWith(fontSize: 16),
                                                ),
                                                const Icon(
                                                    Icons.calendar_today),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),

                                      // Time Picker
                                      Expanded(
                                        flex: 1,
                                        child: GestureDetector(
                                          onTap: () {
                                            formController.pickTime(context);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 8),
                                            decoration: BoxDecoration(
                                              color: AppColors.grey,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: !formController
                                                      .isTimeSelected.value
                                                  ? Border.all(
                                                      color: Colors.red)
                                                  : null,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Text(
                                                  formController.selectedTime
                                                              .value !=
                                                          null
                                                      ? formController
                                                          .selectedTime.value!
                                                          .format(context)
                                                      : 'Select Time',
                                                  style: AppTextStyle
                                                      .helveticaStyle
                                                      .copyWith(fontSize: 16),
                                                ),
                                                const Icon(Icons.access_time),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: AppConst.spacing * 2),
                                Text(
                                  Applabels.routeDetails,
                                  style: AppTextStyle.helveticaBoldStyle
                                      .copyWith(fontSize: 16),
                                ),
                                SizedBox(height: AppConst.spacing / 2),
                                FilledTextfield(
                                  hintText: "(Optional)",
                                  isOptional: true,
                                  controller:
                                      formController.routeDetailsController,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(Applabels.vehicleDetails,
                                        style: AppTextStyle.helveticaBoldStyle
                                            .copyWith(fontSize: 16)),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation,
                                                    secondaryAnimation) =>
                                                ManageVehicle(
                                                    offerController:
                                                        formController),
                                            transitionsBuilder: (context,
                                                animation,
                                                secondaryAnimation,
                                                child) {
                                              const begin = Offset(1.0,
                                                  0.0); // Slide in from right
                                              const end = Offset.zero;
                                              const curve = Curves.ease;

                                              var tween = Tween(
                                                      begin: begin, end: end)
                                                  .chain(
                                                      CurveTween(curve: curve));
                                              var offsetAnimation =
                                                  animation.drive(tween);

                                              return SlideTransition(
                                                position: offsetAnimation,
                                                child: child,
                                              );
                                            },
                                            transitionDuration: const Duration(
                                                milliseconds:
                                                    800), // Increase duration to slow down
                                          ),
                                        );
                                      },
                                      child: const Text('Manage Vehicle',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          Applabels.vehicle,
                                          style: AppTextStyle.helveticaStyle
                                              .copyWith(fontSize: 16),
                                        ),
                                      ),
                                      SizedBox(
                                        width: AppConst.spacing,
                                      ),
                                      Obx(
                                        () => Expanded(
                                          flex: 2,
                                          child: GestureDetector(
                                            onTap: () {
                                              formController
                                                  .showVehicleSelectionSheet(
                                                      context);
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 8),
                                              decoration: BoxDecoration(
                                                  color: AppColors.grey,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: !formController
                                                          .isVehicleSelected
                                                          .value
                                                      ? Border.all(
                                                          color: Colors.red)
                                                      : null),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Text(
                                                    formController
                                                                .selectedVehicle
                                                                .value ==
                                                            null
                                                        ? 'Select Vehicle'
                                                        : "${formController.selectedVehicle.value!.maker} ${formController.selectedVehicle.value!.name} ${formController.selectedVehicle.value!.model}",
                                                    style: AppTextStyle
                                                        .helveticaStyle
                                                        .copyWith(fontSize: 16),
                                                  ),
                                                  const Icon(
                                                      Icons.arrow_drop_down),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16),
                                  child: Row(
                                    children: [
                                      Text(
                                        Applabels.seatsAvalailable,
                                        style: AppTextStyle.helveticaStyle
                                            .copyWith(fontSize: 16),
                                      ),
                                      SizedBox(
                                        width: AppConst.spacing,
                                      ),
                                      Obx(
                                        () => Expanded(
                                          flex: 2,
                                          child: GestureDetector(
                                            onTap: () {
                                              formController
                                                  .showSeatSelectionSheet(
                                                      context);
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 8),
                                              decoration: BoxDecoration(
                                                color: AppColors.grey,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      textAlign:
                                                          TextAlign.center,
                                                      formController
                                                          .selectedSeats
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                  const Expanded(
                                                      flex: 1,
                                                      child: Icon(Icons
                                                          .arrow_drop_down)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16),
                                  child: SizedBox(
                                    // height: 40,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            Applabels.pricePerSeat,
                                            style: AppTextStyle.helveticaStyle
                                                .copyWith(fontSize: 16),
                                          ),
                                        ),
                                        SizedBox(
                                          width: AppConst.spacing,
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: FilledTextfield(
                                            keyboardType: const TextInputType
                                                .numberWithOptions(),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Please fill out this field';
                                              } else if ((int.parse(value) <
                                                  50)) {
                                                return 'Minimum fare 50 PKR';
                                              }
                                              return null;
                                            },
                                            hintText: "In Ruppees.",
                                            controller:
                                                formController.priceController,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // const Spacer(),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: AppConst.padding * 2,
                                  right: AppConst.padding * 2),
                              child: PrimaryButton(
                                text: Applabels.offerRide,
                                onPressed: () async {
                                  final fromWhereEmpty =
                                      formController.pickupController.text ==
                                              '' ||
                                          formController
                                              .pickupController.text.isEmpty;
                                  final toWhereEmpty =
                                      formController.dropoffController.text ==
                                              '' ||
                                          formController
                                              .dropoffController.text.isEmpty;

                                  final isDateSelected =
                                      formController.selectedDate.value == null;

                                  final isTimeSelected =
                                      formController.selectedTime.value == null;

                                  final isVehicleSelected =
                                      formController.selectedVehicle.value ==
                                          null;

                                  final isFormValid = !fromWhereEmpty &&
                                      !toWhereEmpty &&
                                      !isDateSelected &&
                                      !isVehicleSelected &&
                                      !isTimeSelected;

                                  if (_formKey.currentState!.validate() &&
                                      isFormValid) {
                                    formController.isVehicleSelected.value =
                                        true;
                                    formController.isDateSelected.value = true;
                                    formController.isTimeSelected.value = true;
                                    _showRedBorderNotifier.value = false;
                                    _showRedBorderNotifier2.value = false;

                                    if (SessionController().isLoggedIn !=
                                        false) {
                                      bool isDone = await formController
                                          .uploadRideToFirebase();

                                      if (context.mounted) {
                                        String message = isDone
                                            ? "Ride Offered Successfully!"
                                            : "Ride is already in progress.";
                                        String image = isDone
                                            ? "assets/images/checked.png"
                                            : "assets/images/warning.png";

                                        await _showAlertDialog(
                                            context, message, image);
                                      }
                                    } else {
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        await _showAlertDialog(
                                            context,
                                            "Please Login First",
                                            "assets/images/warning.png");
                                      }
                                    }

                                    print("form validated");
                                  } else {
                                    formController.isVehicleSelected.value =
                                        !isVehicleSelected;
                                    formController.isDateSelected.value =
                                        !isDateSelected;
                                    formController.isTimeSelected.value =
                                        !isTimeSelected;

                                    _showRedBorderNotifier.value =
                                        fromWhereEmpty;
                                    _showRedBorderNotifier2.value =
                                        toWhereEmpty;
                                    print("form not validated");
                                  }

                                  // if (formController.pickupController.text.isEmpty ||
                                  //     formController
                                  //         .dropoffController.text.isEmpty ||
                                  //     formController.selectedDate.value ==
                                  //         null ||
                                  //     formController.selectedTime.value ==
                                  //         null ||
                                  //     formController.selectedVehicle.value ==
                                  //         null ||
                                  //     formController.selectedSeats.value == 0 ||
                                  //     formController
                                  //         .priceController.text.isEmpty) {
                                  //   _showAlertDialog(
                                  //       context,
                                  //       "Please fill out all required fields before offering a ride.",
                                  //       "assets/images/contact-form.png");
                                  //   return;
                                  // }

                                  // if (!SessionController().isLoggedIn!) {
                                  //   await Navigator.push(
                                  //       context,
                                  //       MaterialPageRoute(
                                  //           builder: (context) =>
                                  //               const SignupPage()));
                                  // }
                                },
                              )),
                          SizedBox(
                            height: AppConst.spacing,
                          )
                        ],
                      ),
                    );
        }));
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
}

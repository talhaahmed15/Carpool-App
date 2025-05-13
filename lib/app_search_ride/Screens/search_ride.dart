import 'package:carpool_app/app_map/map_popup.dart';
import 'package:carpool_app/app_offer_ride/Controller/form_controller.dart';
import 'package:carpool_app/app_search_ride/Screens/coordinatemap.dart';
import 'package:carpool_app/app_search_ride/Screens/result_screen.dart';
import 'package:carpool_app/config/app_const.dart';
import 'package:carpool_app/config/app_fonts.dart';
import 'package:carpool_app/config/app_widgets.dart';
import 'package:carpool_app/config/appcolors.dart';
import 'package:carpool_app/config/applabels.dart';
import 'package:carpool_app/controller/map_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_place/google_place.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as pre;

class SearchRide extends StatefulWidget {
  const SearchRide({super.key});

  @override
  State<SearchRide> createState() => _SearchRideState();
}

class _SearchRideState extends State<SearchRide> {
  final mapController = Get.put(CustomMapController());
  OfferFormController formController = Get.put(OfferFormController());
  List<AutocompletePrediction> predictions = [];

  final ValueNotifier<pre.LatLng?> coordinate1 =
      ValueNotifier<pre.LatLng?>(null);
  final ValueNotifier<pre.LatLng?> coordinate2 =
      ValueNotifier<pre.LatLng?>(null);

  void _showErrorDialog(String message, image) {
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.whiteColor,
      body: ListView(
        children: [
          CustomAppBar(text: Applabels.searchRide),
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                              context, mapController, "pickupSearch");

                          formController.pickupSearchController.text =
                              mapController.pickupAddressSearch ?? "";

                          formController.pickupSearchCoordinates =
                              mapController.pickupSearchCoordinates;

                          if (mapController.pickupSearchCoordinates != null) {
                            setState(() {
                              coordinate1.value = pre.LatLng(
                                  mapController
                                      .pickupSearchCoordinates!.latitude,
                                  mapController
                                      .pickupSearchCoordinates!.longitude);
                            });
                          }
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

                            await showSearchBottomSheet(
                                context,
                                mapController,
                                "pickupSearch",
                                formController.pickupSearchController,
                                predictions);

                            formController.pickupSearchCoordinates =
                                mapController.pickupSearchCoordinates;

                            if (mapController.pickupSearchCoordinates != null) {
                              coordinate1.value = pre.LatLng(
                                  mapController
                                      .pickupSearchCoordinates!.latitude,
                                  mapController
                                      .pickupSearchCoordinates!.longitude);
                            }

                            setState(() {});
                          },
                          child: IgnorePointer(
                            ignoring: true,
                            child: FilledTextfield(
                              hintText: "From where?",
                              controller: formController.pickupSearchController,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 12),
                  height: 50,
                  child: const VerticalDivider(
                    width: 20,
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () async {
                          await showMapBottomSheet(
                              context, mapController, "dropoffSearch");

                          formController.dropoffSearchController.text =
                              mapController.dropAddressSearch ?? "";

                          formController.dropoffSearchCoordinates =
                              mapController.dropoffSearchCoordinates;

                          if (mapController.dropoffSearchCoordinates != null) {
                            setState(() {
                              coordinate2.value = pre.LatLng(
                                  mapController
                                      .dropoffSearchCoordinates!.latitude,
                                  mapController
                                      .dropoffSearchCoordinates!.longitude);
                            });
                          }
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
                            await showSearchBottomSheet(
                                context,
                                mapController,
                                "dropoffSearch",
                                formController.dropoffSearchController,
                                predictions);

                            formController.dropoffSearchCoordinates =
                                mapController.dropoffSearchCoordinates;

                            if (mapController.pickupSearchCoordinates != null) {
                              coordinate2.value = pre.LatLng(
                                  mapController
                                      .dropoffSearchCoordinates!.latitude,
                                  mapController
                                      .dropoffSearchCoordinates!.longitude);
                            }
                            print(formController.dropoffSearchCoordinates);

                            setState(() {});
                          },
                          child: IgnorePointer(
                            ignoring: true,
                            child: FilledTextfield(
                              hintText: "To where?",
                              controller:
                                  formController.dropoffSearchController,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                CoordinateMap(
                  pickupCoordinateNotifier: coordinate1,
                  dropoffCoordinateNotifier: coordinate2,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                    text: Applabels.searchRide,
                    onPressed: () async {
                      if (formController.pickupSearchCoordinates == null ||
                          formController.pickupSearchController.text == '') {
                        _showErrorDialog("Please select a pickup location.",
                            "assets/images/warning.png");
                      } else if (formController.dropoffSearchCoordinates ==
                              null ||
                          formController.dropoffSearchController.text == '') {
                        _showErrorDialog("Please select a dropoff location.",
                            "assets/images/warning.png");
                      } else {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    RidesScreen(
                              pickupCoordinate:
                                  formController.pickupSearchCoordinates!,
                              dropoffCoordinate:
                                  formController.dropoffSearchCoordinates!,
                            ),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin =
                                  Offset(1.0, 0.0); // Slide in from right
                              const end = Offset.zero;
                              const curve = Curves.ease;

                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);

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

                        formController.pickupSearchController.clear();
                        formController.dropoffSearchController.clear();
                        // formController.pickupSearchCoordinates = null;
                        // formController.dropoffSearchCoordinates = null;
                      }
                    })
              ],
            ),
          ),
        ],
      ),
    );
  }
}

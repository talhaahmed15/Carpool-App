import 'dart:async';
import 'dart:convert';

import 'package:carpool_app/config/app_fonts.dart';
import 'package:carpool_app/config/app_widgets.dart';
import 'package:carpool_app/config/appcolors.dart';
import 'package:carpool_app/controller/map_controller.dart';
import 'package:carpool_app/google_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_place/google_place.dart';
import 'package:latlong2/latlong.dart';
import 'package:shimmer/shimmer.dart';

Future<void> showMapBottomSheet(BuildContext context,
    CustomMapController mapController, String addressOf) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    enableDrag: false,
    showDragHandle: true,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(8),
        height: MediaQuery.of(context).size.height * 0.8,
        child: MapSample(
          mapController: mapController,
          addressOf: addressOf,
        ),
        // child: MyMap(
        //   mapController: mapController,
        //   addressOf: addressOf,
        // ),
      );
    },
  );
}

Future<void> showSearchBottomSheet(
  BuildContext context,
  CustomMapController mapController,
  String addressOf,
  TextEditingController controller,
  List<AutocompletePrediction> initialPredictions,
) async {
  await showModalBottomSheet(
    context: context,
    // isScrollControlled: true,
    backgroundColor: AppColors.backgroundColor,
    enableDrag: false,
    scrollControlDisabledMaxHeightRatio: 0.8,
    showDragHandle: true,
    builder: (BuildContext context) {
      return SearchMapSheet(
          mapController: mapController,
          addressOf: addressOf,
          controller: controller,
          initialPredictions: initialPredictions);
    },
  );
}

class SearchMapSheet extends StatefulWidget {
  SearchMapSheet(
      {required this.mapController,
      required this.addressOf,
      required this.controller,
      required this.initialPredictions,
      super.key});

  final CustomMapController mapController;
  final String addressOf;
  final TextEditingController controller;
  List<AutocompletePrediction> initialPredictions;

  @override
  State<SearchMapSheet> createState() => _SearchMapSheetState();
}

class _SearchMapSheetState extends State<SearchMapSheet> {
  ValueNotifier<List<AutocompletePrediction>> predictionsNotifier =
      ValueNotifier<List<AutocompletePrediction>>([]);

  ValueNotifier<bool> isLoadingNotifier =
      ValueNotifier<bool>(false); // Reactive loading state

  TextEditingController controller = TextEditingController();
  Timer? _debounce;

  // Function to search locations using autocomplete
  Future<List<AutocompletePrediction>> autoCompleteSearch(
    String value, double lon, double lat) async {
    final configString = await rootBundle.loadString('firebase_config.json');
     final config = json.decode(configString);
    String apiKey = config['apiKey'];
    GooglePlace googlePlace = GooglePlace(apiKey);

    var result = await googlePlace.autocomplete
        .get(value, region: 'pk', language: 'en', origin: LatLon(lat, lon));

    if (result != null && result.predictions != null) {
      return result.predictions!;
    } else {
      print("null predictions");
      return [];
    }
  }

  // Function to get details (latitude and longitude) of the selected place
  Future<void> getPlaceDetails(String placeId) async {
     final configString = await rootBundle.loadString('firebase_config.json');
     final config = json.decode(configString);
    String apiKey = config['apiKey'];
    GooglePlace googlePlace = GooglePlace(apiKey);

    var details = await googlePlace.details.get(placeId);
    if (details != null && details.result != null) {
      double lat = details.result!.geometry!.location!.lat!;
      double lng = details.result!.geometry!.location!.lng!;

      if (widget.addressOf == "pickupSearch") {
        widget.mapController.pickupSearchCoordinates = LatLng(lat, lng);
      } else if (widget.addressOf == "pickup") {
        widget.mapController.pickupCoordinates = LatLng(lat, lng);
      } else if (widget.addressOf == "dropoffSearch") {
        widget.mapController.dropoffSearchCoordinates = LatLng(lat, lng);
      } else {
        widget.mapController.dropoffCoordinates = LatLng(lat, lng);
      }

      print("Selected location Lat: $lat, Lng: $lng");
    } else {
      print("Failed to get place details.");
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.mapController.userLocation == null) {
      initializeLocation();
    }

    controller.text = widget.controller.text;
    // Automatically search for the initial value when the page loads
    if (widget.controller.text.isNotEmpty) {
      _triggerSearch(widget.controller.text);
    }
  }

  initializeLocation() async {
    isLoadingNotifier.value = true;
    await widget.mapController.determinePosition();
    isLoadingNotifier.value = false;
  }

  void _triggerSearch(String value) async {
    if (value.isNotEmpty) {
      if (_debounce?.isActive ?? false) _debounce?.cancel();

      _debounce = Timer(Duration(milliseconds: 200), () async {
        if (widget.mapController.userLocation == null) {
          print("ithey");
          await initializeLocation();
        }

        isLoadingNotifier.value = true;
        List<AutocompletePrediction> newPredictions = await autoCompleteSearch(
            value,
            widget.mapController.userLocation!.longitude,
            widget.mapController.userLocation!.latitude);

        // Filter out predictions where distanceMeters is null
        newPredictions
            .removeWhere((prediction) => prediction.distanceMeters == null);

        // Only sort if there is more than one prediction
        if (newPredictions.length > 1) {
          newPredictions
              .sort((a, b) => a.distanceMeters!.compareTo(b.distanceMeters!));
        }

        isLoadingNotifier.value = false;

        predictionsNotifier.value = newPredictions;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              "Enter your route",
              style: AppTextStyle.poppinsStyle
                  .copyWith(fontSize: 20, color: AppColors.blackColor),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: FilledTextfield(
                    hintText: widget.addressOf == "pickupSearch" ||
                            widget.addressOf == "pickup"
                        ? "From Where?"
                        : "To Where?",
                    controller: controller,
                    onChanged: (value) async {
                      _triggerSearch(value ?? "");
                    },
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    controller.clear();
                    // widget.initialPredictions.clear();
                    // predictionsNotifier.value.clear();
                  },
                )
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: isLoadingNotifier, // Observe loading state
                builder: (context, isLoading, child) {
                  return isLoading
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: ListView.builder(
                            itemCount: 5, // Show 5 shimmer items
                            itemBuilder: (context, index) {
                              return ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                title: Container(
                                  width: double.infinity,
                                  height: 20,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 20,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      Container(
                                        width: 50,
                                        height: 20,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : ValueListenableBuilder<List<AutocompletePrediction>>(
                          valueListenable: predictionsNotifier,
                          builder: (context, predictions, child) {
                            return predictions.isEmpty
                                ? Center(
                                    child: Text(
                                      "No results found",
                                      style: AppTextStyle.poppinsStyle.copyWith(
                                        fontSize: 16,
                                        color: AppColors.blackColor,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: predictions.length,
                                    itemBuilder: (context, index) {
                                      final prediction = predictions[index];
                                      final distanceInKm =
                                          prediction.distanceMeters! / 1000;
                                      return ListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 4.0),
                                        title: Text(
                                          prediction.description!,
                                          style: AppTextStyle.helveticaStyle
                                              .copyWith(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                        ),
                                        trailing: Text(
                                          "~${distanceInKm.toStringAsFixed(2)} km",
                                          style: AppTextStyle.poppinsStyle
                                              .copyWith(fontSize: 12),
                                        ),
                                        onTap: () async {
                                          print(
                                              "Selected location: ${prediction.description}");

                                          // Get place details to print Lat/Lng
                                          await getPlaceDetails(
                                              prediction.placeId!);

                                          // Update the controller only when a location is selected
                                          widget.controller.text =
                                              prediction.description!;

                                          Navigator.pop(context);
                                        },
                                      );
                                    },
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

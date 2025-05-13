import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as pre;

class CustomMapController extends GetxController {
  LatLng? markerPosition;

  String? pickupAddress;
  String? dropoffAddress;

  String? pickupAddressSearch;
  String? dropAddressSearch;

  LatLng? pickupSearchCoordinates;
  LatLng? dropoffSearchCoordinates;

  LatLng? pickupCoordinates;
  LatLng? dropoffCoordinates;

  Position? userLocation;

  RxString mapStatus = "loading".obs;

  @override
  void onClose() {
    // Clean up resources like listeners, streams, etc.
    super.onClose();
  }

  Future<void> getAddressFromLatLng(String addressOf) async {
    if (markerPosition == null) {
      return;
    }

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        markerPosition!.latitude,
        markerPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Construct the pickup address

        if (addressOf == 'pickup') {
          pickupAddress = [
            place.street,
            place.locality,
            place.subLocality,
            place.subAdministrativeArea,
            place.administrativeArea,
            place.postalCode,
            place.country
          ]
              .where((element) => element != null && element.isNotEmpty)
              .join(', ');

          // Update the coordinates
          pickupCoordinates = markerPosition;
          print("Pickup Address: $pickupAddress");
          print("Pickup Coordinates: $pickupCoordinates");
          mapStatus.value = "address_found";
        } else if (addressOf == 'dropoff') {
          dropoffAddress = [
            place.street,
            place.locality,
            place.subLocality,
            place.subAdministrativeArea,
            place.administrativeArea,
            place.postalCode,
            place.country
          ]
              .where((element) => element != null && element.isNotEmpty)
              .join(', ');

          // Update the coordinates
          dropoffCoordinates = markerPosition;
          print("DropOff Address: $dropoffAddress");
          print("Drop Coordinates: $dropoffCoordinates");
          mapStatus.value = "address_found";
        } else if (addressOf == 'pickupSearch') {
          pickupAddressSearch = [
            place.street,
            place.locality,
            place.subLocality,
            place.subAdministrativeArea,
            place.administrativeArea,
            place.postalCode,
            place.country
          ]
              .where((element) => element != null && element.isNotEmpty)
              .join(', ');

          // Update the coordinates
          pickupSearchCoordinates = markerPosition;
          print("Pickup Search Address: $pickupAddressSearch");
          print("Pickup Search Coordinates: $pickupSearchCoordinates");
          mapStatus.value = "address_found";
        } else if (addressOf == 'dropoffSearch') {
          dropAddressSearch = [
            place.street,
            place.locality,
            place.subLocality,
            place.subAdministrativeArea,
            place.administrativeArea,
            place.postalCode,
            place.country
          ]
              .where((element) => element != null && element.isNotEmpty)
              .join(', ');

          // Update the coordinates
          dropoffSearchCoordinates = markerPosition;
          print("DropOff Search Address: $dropAddressSearch");
          print("Drop Search Coordinates: $dropoffSearchCoordinates");
          mapStatus.value = "address_found";
        }
      } else {
        mapStatus.value = "no_address";
        pickupAddress = "No address found";
      }
    } catch (e) {
      mapStatus.value = "error";
      pickupAddress = "Failed to get address";
      print(e);
    }
  }

  Future determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    print("Checking Location");

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      mapStatus.value = "disabled";
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        mapStatus.value = "disabled";
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      mapStatus.value = "disabled-forever";
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    userLocation = await Geolocator.getCurrentPosition();
    markerPosition = LatLng(userLocation!.latitude, userLocation!.longitude);
    print(
        "Got Position at : ${userLocation!.latitude} , ${userLocation!.longitude}");
    // markerPosition = LatLng(33.693221, 73.050627);
    mapStatus.value = "success";
  }

  Future retryPermissionRequest() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        mapStatus.value = "disabled-forever";

        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions');
      } else {
        // Permission granted, re-run the position determination
        mapStatus.value = "loading";
        await determinePosition();
      }
    }
  }
}

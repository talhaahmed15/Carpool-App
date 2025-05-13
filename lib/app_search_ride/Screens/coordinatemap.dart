import 'package:carpool_app/config/app_fonts.dart';
import 'package:carpool_app/config/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CoordinateMap extends StatefulWidget {
  final ValueNotifier<LatLng?> pickupCoordinateNotifier;
  final ValueNotifier<LatLng?> dropoffCoordinateNotifier;

  const CoordinateMap({
    Key? key,
    required this.pickupCoordinateNotifier,
    required this.dropoffCoordinateNotifier,
  }) : super(key: key);

  @override
  _CoordinateMapState createState() => _CoordinateMapState();
}

class _CoordinateMapState extends State<CoordinateMap> {
  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();

    // Add listeners to update the map whenever coordinates change
    widget.pickupCoordinateNotifier.addListener(() {
      _updateCameraPosition(widget.pickupCoordinateNotifier.value,
          widget.dropoffCoordinateNotifier.value);
    });
    widget.dropoffCoordinateNotifier.addListener(() {
      _updateCameraPosition(widget.pickupCoordinateNotifier.value,
          widget.dropoffCoordinateNotifier.value);
    });
  }

  @override
  void dispose() {
    widget.pickupCoordinateNotifier.removeListener(() {
      _updateCameraPosition(widget.pickupCoordinateNotifier.value,
          widget.dropoffCoordinateNotifier.value);
    });
    widget.dropoffCoordinateNotifier.removeListener(() {
      _updateCameraPosition(widget.pickupCoordinateNotifier.value,
          widget.dropoffCoordinateNotifier.value);
    });
    super.dispose();
  }

  void _updateCameraPosition(
      LatLng? pickupCoordinate, LatLng? dropoffCoordinate) {
    print("updating camera position");

    // Only update if the map controller is available
    if (mapController == null) return;

    if (pickupCoordinate != null && dropoffCoordinate != null) {
      // Both coordinates are available, calculate bounds
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          min(pickupCoordinate.latitude, dropoffCoordinate.latitude),
          min(pickupCoordinate.longitude, dropoffCoordinate.longitude),
        ),
        northeast: LatLng(
          max(pickupCoordinate.latitude, dropoffCoordinate.latitude),
          max(pickupCoordinate.longitude, dropoffCoordinate.longitude),
        ),
      );

      // Animate the camera to show both points
      mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100),
      );
    } else if (pickupCoordinate != null) {
      // Only pickup coordinate is available, zoom in on it
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: pickupCoordinate,
            zoom: 14, // Default zoom level for one point
          ),
        ),
      );
    } else if (dropoffCoordinate != null) {
      // Only dropoff coordinate is available, zoom in on it
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: dropoffCoordinate,
            zoom: 14, // Default zoom level for one point
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    LatLng? pickupCoordinate = widget.pickupCoordinateNotifier.value;
    LatLng? dropoffCoordinate = widget.dropoffCoordinateNotifier.value;

    Set<Marker> markers = {};

    if (pickupCoordinate != null) {
      markers.add(
        Marker(
          markerId: MarkerId('pickup'),
          position: pickupCoordinate,
          infoWindow: InfoWindow(title: 'Pickup Point'),
        ),
      );
    }

    if (dropoffCoordinate != null) {
      markers.add(
        Marker(
          markerId: MarkerId('dropoff'),
          position: dropoffCoordinate,
          infoWindow: InfoWindow(title: 'Dropoff Point'),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: pickupCoordinate == null && dropoffCoordinate == null
          ? Center(
              child: Text(
              'Please select a location',
              style: AppTextStyle.helveticaStyle,
            ))
          : GoogleMap(
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
                _updateCameraPosition(pickupCoordinate, dropoffCoordinate);
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(0, 0),
                zoom: 14.4746,
              ),
              markers: markers,
              polylines: _createPolyline(pickupCoordinate, dropoffCoordinate),
            ),
    );
  }

  Set<Polyline> _createPolyline(
      LatLng? pickupCoordinate, LatLng? dropoffCoordinate) {
    Set<Polyline> polylines = {};

    if (pickupCoordinate != null && dropoffCoordinate != null) {
      polylines.add(
        Polyline(
          polylineId: PolylineId('path'),
          points: [pickupCoordinate, dropoffCoordinate],
          color: Colors.blue,
          width: 3,
        ),
      );
    }

    return polylines;
  }

  // Helper methods to calculate min and max
  double min(double a, double b) => a < b ? a : b;
  double max(double a, double b) => a > b ? a : b;
}

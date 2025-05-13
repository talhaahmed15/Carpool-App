import 'dart:async';
import 'package:carpool_app/config/app_fonts.dart';
import 'package:carpool_app/config/appcolors.dart';
import 'package:carpool_app/controller/map_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlong;

class MapSample extends StatefulWidget {
  const MapSample(
      {required this.mapController, required this.addressOf, super.key});

  final CustomMapController mapController;
  final String addressOf;

  @override
  State<MapSample> createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.mapController.determinePosition();
  }

  void _onMapMove(CameraPosition position) {
    widget.mapController.markerPosition =
        latlong.LatLng(position.target.latitude, position.target.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (widget.mapController.mapStatus.value == "loading") {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SpinKitThreeBounce(color: AppColors.appTheme[2]),
                SizedBox(height: 20),
                Text("Loading Maps...",
                    style: AppTextStyle.poppinsStyle.copyWith(fontSize: 22)),
              ],
            ),
          );
        } else if (widget.mapController.mapStatus.value == "disabled") {
          return _buildLocationDisabledUI(
              "Location Turned Off.", "Please enable it to use our services.");
        } else if (widget.mapController.mapStatus.value == "disabled-forever") {
          return _buildLocationDisabledUI("Enable it from settings.", "");
        } else if (widget.mapController.mapStatus.value == "error") {
          return _buildLocationDisabledUI(
              "Error! Can't Load Map.", "Please try later.");
        } else {
          return Stack(
            alignment: Alignment.center,
            children: [
              GoogleMap(
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                zoomControlsEnabled: false,
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                    zoom: 14.4746,
                    target: LatLng(
                        widget.mapController.markerPosition!.latitude,
                        widget.mapController.markerPosition!.longitude)),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  widget.mapController.userLocation;
                },
                onCameraMove: (CameraPosition position) {
                  _onMapMove(position);
                },
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 35),
                child: Icon(Icons.place, color: Colors.red, size: 50),
              ),
            ],
          );
        }
      }),
      floatingActionButton: Obx(() => FloatingActionButton(
            backgroundColor: widget.mapController.mapStatus.value == "success"
                ? AppColors.appTheme[2]
                : Colors.grey,
            onPressed: widget.mapController.mapStatus.value == "success"
                ? () async {
                    if (widget.mapController.markerPosition != null) {
                      await widget.mapController
                          .getAddressFromLatLng(widget.addressOf);
                      Navigator.pop(context);
                    }
                  }
                : null,
            child: Icon(
              widget.mapController.mapStatus.value == "success"
                  ? Icons.check
                  : Icons.disabled_by_default_outlined,
              color: Colors.white,
            ),
          )),
    );
  }

  Widget _buildLocationDisabledUI(String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset("assets/images/loadingerror.png"),
          SizedBox(height: 20),
          Text(title, style: AppTextStyle.poppinsStyle.copyWith(fontSize: 22)),
          if (message.isNotEmpty) ...[
            SizedBox(height: 10),
            Text(message,
                style: AppTextStyle.poppinsStyle.copyWith(fontSize: 22)),
          ],
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                widget.mapController.retryPermissionRequest();
              },
              child: Text("Retry",
                  style: AppTextStyle.poppinsStyle.copyWith(fontSize: 22)),
            ),
          )
        ],
      ),
    );
  }
}

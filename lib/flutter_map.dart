// import 'package:carpool_app/config/app_const.dart';
// import 'package:carpool_app/config/app_fonts.dart';
// import 'package:carpool_app/config/app_widgets.dart';
// import 'package:carpool_app/config/appcolors.dart';
// import 'package:carpool_app/controller/map_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:url_launcher/url_launcher.dart';

// class MyMap extends StatefulWidget {
//   const MyMap(
//       {required this.mapController, required this.addressOf, super.key});

//   final CustomMapController mapController;
//   final String addressOf;

//   @override
//   State<MyMap> createState() => _MyMapState();
// }

// class _MyMapState extends State<MyMap> {
//   Position? points;
//   bool loading = true;

//   // var mapController = Get.put(CustomMapController());

//   @override
//   void initState() {
//     super.initState();
//     widget.mapController.determinePosition();
//   }

//   void _onMapMove(MapPosition position) {
//     widget.mapController.markerPosition = position.center;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Obx(() {
//         return widget.mapController.mapStatus.value == "loading"
//             ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     SpinKitThreeBounce(
//                       color: AppColors.appTheme[2],
//                     ),
//                     SizedBox(
//                       height: AppConst.spacing * 2,
//                     ),
//                     Text(
//                       "Loading Maps..",
//                       style: AppTextStyle.poppinsStyle.copyWith(fontSize: 25),
//                     ),
//                   ],
//                 ),
//               )
//             : widget.mapController.mapStatus.value == "disabled"
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Image.asset("assets/images/loadingerror.png"),
//                         SizedBox(
//                           height: AppConst.spacing * 2,
//                         ),
//                         Text(
//                           "Location Turned Off.",
//                           style: AppTextStyle.poppinsBoldStyle
//                               .copyWith(fontSize: 25),
//                         ),
//                         Text(
//                           "Please enable it to use our services.",
//                           style:
//                               AppTextStyle.poppinsStyle.copyWith(fontSize: 20),
//                         ),
//                         SizedBox(
//                           height: AppConst.spacing * 2,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 16, right: 16),
//                           child: PrimaryButton(
//                               onPressed: () {
//                                 widget.mapController.retryPermissionRequest();
//                               },
//                               text: "Retry"),
//                         )
//                       ],
//                     ),
//                   )
//                 : widget.mapController.mapStatus.value == "disabled-forever"
//                     ? Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Image.asset("assets/images/setting.png"),
//                             SizedBox(
//                               height: AppConst.spacing * 2,
//                             ),
//                             Text(
//                               "Location Turned Off.",
//                               style: AppTextStyle.poppinsBoldStyle
//                                   .copyWith(fontSize: 25),
//                             ),
//                             Text(
//                               "Enable it from settings.",
//                               style: AppTextStyle.poppinsStyle
//                                   .copyWith(fontSize: 20),
//                             ),
//                           ],
//                         ),
//                       )
//                     : widget.mapController.mapStatus.value == "error"
//                         ? Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Image.asset("assets/images/loadingerror.png"),
//                                 SizedBox(
//                                   height: AppConst.spacing * 2,
//                                 ),
//                                 Text(
//                                   "Error! Cant Load Map.",
//                                   style: AppTextStyle.poppinsBoldStyle
//                                       .copyWith(fontSize: 25),
//                                 ),
//                                 Text(
//                                   "Please try later.",
//                                   style: AppTextStyle.poppinsStyle
//                                       .copyWith(fontSize: 20),
//                                 )
//                               ],
//                             ),
//                           )
//                         : Stack(
//                             children: [
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(16),
//                                 child: FlutterMap(
//                                   options: MapOptions(
//                                     center: widget.mapController.markerPosition,
//                                     maxZoom: 22,
//                                     zoom: 16,
//                                     onMapReady: () {
//                                       print("ready map");
//                                     },
//                                     onPositionChanged: (MapPosition position,
//                                         bool hasGesture) {
//                                       if (hasGesture) {
//                                         _onMapMove(position);
//                                       }
//                                     },
//                                   ),
//                                   children: [
//                                     TileLayer(
//                                       urlTemplate:
//                                           "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
//                                       maxNativeZoom: 22,
//                                     ),
//                                     RichAttributionWidget(
//                                       alignment:
//                                           AttributionAlignment.bottomLeft,
//                                       attributions: [
//                                         TextSourceAttribution(
//                                           'OpenStreetMap contributors',
//                                           onTap: () => launchUrl(Uri.parse(
//                                               'https://openstreetmap.org/copyright')),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               // Marker at the center of the screen
//                               const Padding(
//                                 padding: EdgeInsets.only(bottom: 20),
//                                 child: Center(
//                                   child: Icon(
//                                     Icons.location_on_sharp,
//                                     color: Colors.red,
//                                     size: 50,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           );
//       }),
//       floatingActionButton: Obx(() => FloatingActionButton(
//             backgroundColor: widget.mapController.mapStatus.value == "success"
//                 ? AppColors.appThemeLow[2]
//                 : AppColors.grey,
//             isExtended: true,
//             onPressed: widget.mapController.mapStatus.value == "success"
//                 ? () async {
//                     if (widget.mapController.markerPosition != null) {
//                       await widget.mapController
//                           .getAddressFromLatLng(widget.addressOf);

//                       if (context.mounted) {
//                         Navigator.pop(context);
//                       }
//                     }
//                   }
//                 : null,
//             child: widget.mapController.mapStatus.value == "success"
//                 ? const Icon(
//                     Icons.check,
//                     color: Colors.white,
//                   )
//                 : Icon(
//                     Icons.disabled_by_default_outlined,
//                     color: AppColors.appThemeLow[2],
//                   ),
//           )),
//     );
//   }
// }

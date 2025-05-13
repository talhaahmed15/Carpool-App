import 'package:carpool_app/Models/vehicle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Ride {
  final DateTime date;
  final String rideId;
  final String dropoffAddress;
  final GeoPoint dropoffCoordinates;
  final String pickupAddress;
  final GeoPoint pickupCoordinates;
  final String pricePerSeat;
  final int totalSeats;
  final int bookedSeats;
  final String time;
  final Vehicle selectedVehicle;
  final String? details;
  final String addedBy;
  final String contactNumber;
  final String rideStatus;
  final List? bookedBy;

  Ride(
      {required this.rideId,
      required this.date,
      required this.dropoffAddress,
      required this.dropoffCoordinates,
      required this.pickupAddress,
      required this.pickupCoordinates,
      required this.pricePerSeat,
      required this.totalSeats,
      required this.time,
      required this.addedBy,
      required this.bookedSeats,
      required this.contactNumber,
      this.details,
      required this.selectedVehicle,
      required this.rideStatus,
      required this.bookedBy});

  factory Ride.fromFirestore(Map<String, dynamic> data) {
    return Ride(
        rideId: data['rideId'],
        date: (data['date'] as Timestamp).toDate(),
        dropoffAddress: data['dropoffAddress'],
        dropoffCoordinates: data["dropoffCoordinates"],
        pickupAddress: data['pickupAddress'],
        pickupCoordinates: data["pickupCoordinates"],
        pricePerSeat: data['pricePerSeat'],
        totalSeats: data['totalSeats'],
        time: data['time'],
        details: data['routeDetails'],
        selectedVehicle: Vehicle.fromJson(data['selectedVehicle']),
        addedBy: data['addedBy'],
        bookedSeats: data['bookedSeats'],
        contactNumber: data['contactNumber'],
        rideStatus: data['rideStatus'],
        bookedBy: data['bookedBy']);
  }
}

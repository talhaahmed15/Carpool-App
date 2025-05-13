import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? userId;
  String? phoneNumber;
  String? firstName;
  String? lastName;
  String? email;
  String? password;

  UserModel({
    this.userId,
    this.phoneNumber,
    this.firstName,
    this.lastName,
    this.email,
    this.password,
  });

  // Factory constructor to create a UserModel from JSON data
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      password: json['password'],
      phoneNumber: json['phone'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      userId: json['userId'],
    );
  }

  // Factory constructor to create a UserModel from a Firestore document
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      userId: data['userId'],
      phoneNumber: data['phone'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      email: data['email'],
      password: data['password'], // Optional to include in your model
    );
  }
}

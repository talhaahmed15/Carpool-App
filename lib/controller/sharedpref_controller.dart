import 'package:carpool_app/Models/user_model.dart';
import 'package:carpool_app/controller/session_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefController {
  static final SharedPrefController _instance =
      SharedPrefController._internal();

  static const String _userNameKey = 'userName';
  static const String _mobileNumberKey = 'mobileNumber';
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _rideStatusKey = 'rideStatus';

  SharedPrefController._internal();

  factory SharedPrefController() {
    return _instance;
  }

  Future<void> saveSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, SessionController().userName ?? '');
    await prefs.setString(
        _mobileNumberKey, SessionController().mobileNumber ?? '');
    await prefs.setBool(
        _isLoggedInKey, SessionController().isLoggedIn ?? false);
    await prefs.setBool(
        _rideStatusKey, SessionController().rideStatus ?? false);
    await prefs.setString("userId", SessionController().user.userId!);
  }

  Future getSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    SessionController().isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    SessionController().rideStatus = prefs.getBool(_rideStatusKey) ?? false;
    SessionController().userName = prefs.getString(_userNameKey) ?? "Anonymous";
    SessionController().mobileNumber =
        prefs.getString(_mobileNumberKey) ?? "03##-#######";

    SessionController().user.userId = prefs.getString("userId") ?? "";

    if (SessionController().isLoggedIn == true) {
      CollectionReference users =
          FirebaseFirestore.instance.collection("users");

      var userSnapshot = await users
          .where("userId", isEqualTo: SessionController().user.userId)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = userSnapshot.docs.first;
        SessionController().user = UserModel.fromDocument(userDoc);
      } else {
        print("No user found with the provided userId.");
      }

      CollectionReference rides =
          FirebaseFirestore.instance.collection('rides');

      // Check if the user has already offered an active ride
      var querySnapshot = await rides
          .where('contactNumber', isEqualTo: SessionController().mobileNumber)
          .where('rideStatus', isEqualTo: 'active')
          .get();

      // If an active ride exists, skip the upload
      if (querySnapshot.docs.isNotEmpty) {
        SessionController().rideStatus = true;
        prefs.setBool(_rideStatusKey, true);
        print("User already has an active ride.");
      }
    }
  }

  Future setString(key, value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future setBool(key, value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> clearSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userNameKey);
    await prefs.remove(_mobileNumberKey);
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_rideStatusKey);
  }
}

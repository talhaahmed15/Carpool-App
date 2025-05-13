import 'package:carpool_app/Models/user_model.dart';
import 'package:carpool_app/controller/sharedpref_controller.dart';

class SessionController {
  static final SessionController _instance = SessionController._internal();

  String? userName;
  String? mobileNumber;
  bool? isLoggedIn;
  bool? rideStatus;

  UserModel user = UserModel();

  SessionController._internal();

  factory SessionController() {
    return _instance;
  }

  void clearSession() {
    userName = "Anonymous";
    mobileNumber = "03##-#######";
    isLoggedIn = false;
    rideStatus = false;

    user = UserModel();

    SharedPrefController().clearSession();
  }
}

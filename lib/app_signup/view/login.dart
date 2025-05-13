import 'package:carpool_app/app_signup/controller/signupController.dart';
import 'package:carpool_app/app_signup/view/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import 'package:carpool_app/config/app_const.dart';
import 'package:carpool_app/config/app_fonts.dart';
import 'package:carpool_app/config/app_widgets.dart';
import 'package:carpool_app/config/appcolors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final loginController = Get.put(SignupController());

  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final RxString errorMessage = ''.obs; // RxString to hold the error message

  @override
  void dispose() {
    super.dispose();
    _numberController.dispose();
    _passwordController.dispose();
  }

  // Method to validate input fields
  String? _validateMobileNumber(String? value) {
    // Pakistani phone number validation
    final regex = RegExp(r'^(?:\+92|0)?3[0-9]{2}[0-9]{7}$');
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    } else if (!regex.hasMatch(value)) {
      return 'Invalid mobile number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      loginController
          .loginFireBase(
              context, _numberController.text, _passwordController.text)
          .then((result) {
        if (result == null) {
          // Display error message if login fails
          errorMessage.value = 'Incorrect Credentials, Please try again.';
        } else {
          errorMessage.value = '';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Obx(() {
        return loginController.isUploading.value
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SpinKitThreeBounce(
                      size: 50,
                      color: AppColors.appTheme[2],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Logging In",
                      style: AppTextStyle.poppinsStyle.copyWith(fontSize: 23),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey, // Wrap the fields inside a Form
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: AppConst.spacing * 5),
                          Text(
                            "Login",
                            style: AppTextStyle.poppinsBoldStyle
                                .copyWith(fontSize: 40),
                          ),
                          SizedBox(
                            height: AppConst.spacing,
                          ),
                          Text(
                            "Please enter your credentials",
                            style: AppTextStyle.poppinsStyle
                                .copyWith(fontSize: 20),
                          ),
                          SizedBox(
                            height: AppConst.spacing * 2,
                          ),
                          FilledTextfield(
                            controller: _numberController,
                            keyboardType: TextInputType.numberWithOptions(),
                            hintText: "Mobile Number",
                            validator: _validateMobileNumber, // Add validation
                          ),
                          SizedBox(
                            height: AppConst.spacing,
                          ),
                          FilledTextfield(
                            controller: _passwordController,
                            obscureText: true,
                            hintText: "Password",
                            validator: _validatePassword, // Add validation
                          ),
                          SizedBox(
                            height: AppConst.spacing,
                          ),
                          // Display error message if login fails
                          Obx(() => errorMessage.value.isNotEmpty
                              ? Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    errorMessage.value,
                                    style: AppTextStyle.helveticaStyle.copyWith(
                                        fontSize: 12, color: Colors.red),
                                  ),
                                )
                              : SizedBox.shrink()),
                          SizedBox(height: AppConst.spacing * 2),
                          PrimaryButton(
                            text: "Login",
                            onPressed: _handleLogin, // Call the login handler
                          ),
                          SizedBox(height: AppConst.spacing),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignupPage()));
                            },
                            child: Text(
                              "Don't have an account? Sign Up",
                              style: AppTextStyle.helveticaStyle.copyWith(
                                color: AppColors.blackColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
      }),
    );
  }
}

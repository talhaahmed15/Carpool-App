import 'package:carpool_app/app_signup/controller/signupController.dart';
import 'package:carpool_app/config/app_const.dart';
import 'package:carpool_app/config/app_fonts.dart';
import 'package:carpool_app/config/app_widgets.dart';
import 'package:carpool_app/config/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final signUpController = Get.put(SignupController());

  @override
  void dispose() {
    super.dispose();

    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
  }

  String? _validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      // Basic email validation
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      if (!emailRegex.hasMatch(value)) {
        return 'Enter a valid email';
      }
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Regex to validate Pakistani phone number format (03XXXXXXXXX or +923XXXXXXXXX)
    if (!RegExp(r'^(?:\+92|03)\d{9}$').hasMatch(value)) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Ensures the layout resizes when the keyboard is visible
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: Obx(() {
        return signUpController.isUploading.value
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
                      "Checking Credentials",
                      style: AppTextStyle.poppinsStyle.copyWith(fontSize: 23),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: AppConst.spacing * 4,
                        ),
                        Text(
                          "SignUp",
                          style: AppTextStyle.poppinsBoldStyle
                              .copyWith(fontSize: 40),
                        ),
                        Text(
                          "We need something more",
                          style:
                              AppTextStyle.poppinsStyle.copyWith(fontSize: 20),
                        ),
                        SizedBox(
                          height: AppConst.spacing * 2,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: FilledTextfield(
                                hintText: "First Name",
                                controller: _firstNameController,
                                validator: (value) =>
                                    _validateNotEmpty(value, "First Name"),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledTextfield(
                                hintText: "Last Name",
                                controller: _lastNameController,
                                validator: (value) =>
                                    _validateNotEmpty(value, "Last Name"),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: AppConst.spacing,
                        ),
                        FilledTextfield(
                          hintText: "Email (Optional)",
                          controller: _emailController,
                          validator: _validateEmail,
                        ),
                        SizedBox(
                          height: AppConst.spacing,
                        ),
                        FilledTextfield(
                          hintText: "Mobile Number",
                          controller: _phoneController,
                          keyboardType: TextInputType.number,
                          validator: _validatePhone,
                        ),
                        SizedBox(
                          height: AppConst.spacing,
                        ),
                        FilledTextfield(
                          hintText: "Password",
                          controller: _passwordController,
                          obscureText: true,
                          validator: (value) =>
                              _validateNotEmpty(value, "Password"),
                        ),
                        SizedBox(
                          height: AppConst.spacing * 2,
                        ),
                        PrimaryButton(
                          text: "Submit",
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              signUpController.signUpFireBase(
                                context,
                                _firstNameController.text,
                                _lastNameController.text,
                                _emailController.text,
                                _phoneController.text,
                                _passwordController.text,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
      }),
    );
  }
}

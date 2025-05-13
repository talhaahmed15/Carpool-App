import 'package:carpool_app/config/app_const.dart';
import 'package:carpool_app/config/app_fonts.dart';
import 'package:carpool_app/config/appcolors.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text; // Must-have field
  final VoidCallback onPressed; // Must-have field
  final Color? color; // Customizable field
  final TextStyle? textStyle; // Customizable field
  final double? elevation; // Customizable field
  final EdgeInsetsGeometry? padding; // Customizable field
  final double? borderRadius; // Customizable field

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textStyle,
    this.elevation,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.appTheme[2],
          elevation: elevation ?? 2.0,
          padding: padding ??
              const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 4.0),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: textStyle ??
              AppTextStyle.poppinsStyle
                  .copyWith(fontSize: 16.0, color: Colors.white),
        ),
      ),
    );
  }
}

class PrimaryTextField extends StatelessWidget {
  final String labelText;
  final ValueChanged<String>? onChanged;

  const PrimaryTextField({super.key, required this.labelText, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        focusColor: AppColors.appTheme[2],
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.appTheme[2], width: 2),
            borderRadius: const BorderRadius.all(Radius.circular(4.0))),
        border: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.appTheme[2]),
            borderRadius: const BorderRadius.all(Radius.circular(4.0))),
        labelText: labelText,
      ),
      onChanged: onChanged,
    );
  }
}

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          // color: Colors.amber,
          padding: EdgeInsets.all(AppConst.padding),
          margin:
              EdgeInsets.only(top: AppConst.margin + 8, left: AppConst.margin),
          width: double.infinity,
          child: Text(
            text,
            style: AppTextStyle.poppinsStyle
                .copyWith(color: Colors.grey[800], fontSize: 25),
          ),
        ),
        Divider(
          thickness: 1,
          color: Colors.grey[500],
        )
      ],
    );
  }
}

class CustomAppBar2 extends StatelessWidget {
  const CustomAppBar2(
      {super.key, required this.text, required this.subtext, this.fun});

  final String text;
  final String subtext;
  final Function()? fun;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            InkWell(
              onTap: fun ??
                  () {
                    Navigator.pop(context);
                  },
              child: Container(
                margin: EdgeInsets.only(
                    top: AppConst.margin + 8, left: AppConst.margin),
                padding: EdgeInsets.only(
                    left: AppConst.padding, top: AppConst.padding),
                child: const Icon(Icons.arrow_back),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    // color: Colors.amber,
                    padding: EdgeInsets.only(top: AppConst.padding),
                    margin: EdgeInsets.only(
                        top: AppConst.margin + 8, left: AppConst.margin),
                    width: double.infinity,
                    child: Text(
                      text,
                      style: AppTextStyle.poppinsStyle
                          .copyWith(color: Colors.grey[800], fontSize: 25),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: AppConst.margin * 1),
                    width: double.infinity,
                    child: Text(
                      subtext,
                      style: AppTextStyle.poppinsStyle
                          .copyWith(color: Colors.grey[800], fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Divider(
          thickness: 1,
          color: Colors.grey[500],
        )
      ],
    );
  }
}

class IconInsideContainer extends StatelessWidget {
  const IconInsideContainer(
      {required this.icon, this.color, this.size, super.key});

  final IconData icon;
  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: AppColors.grey, borderRadius: BorderRadius.circular(8)),
      child: Icon(
        icon,
        color: color ?? Colors.grey[900],
        size: 30,
      ),
    );
  }
}

class FilledTextfield extends StatelessWidget {
  FilledTextfield(
      {super.key,
      this.hintText,
      this.keyboardType,
      this.controller,
      this.obscureText = false,
      this.validator,
      this.isOptional = false,
      this.onChanged});

  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final bool isOptional;
  final Function(String?)? onChanged;

  final ValueNotifier<bool> _isObscureNotifier = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _isObscureNotifier,
      builder: (context, isObscure, child) {
        return TextFormField(
          style: AppTextStyle.helveticaStyle.copyWith(fontSize: 16),
          onChanged: onChanged,
          controller: controller,
          autovalidateMode: AutovalidateMode.onUnfocus,
          onEditingComplete: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          onTapOutside: (value) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          onFieldSubmitted: (value) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          obscureText: obscureText ? isObscure : false,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyle.helveticaStyle,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: AppColors.grey,
            suffixIcon: obscureText
                ? IconButton(
                    icon: Icon(
                      isObscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      _isObscureNotifier.value = !_isObscureNotifier.value;
                    },
                  )
                : null,
            errorStyle: TextStyle(color: Colors.red), // Error text style
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: Colors.red), // Red border when there's an error
            ),
          ),
          keyboardType: keyboardType ?? TextInputType.multiline,
          validator: validator ??
              (value) {
                if (!isOptional && (value == null || value.isEmpty)) {
                  return 'Please fill out this field';
                }
                return null;
              },
        );
      },
    );
  }
}

class FilledTextfield2 extends StatelessWidget {
  FilledTextfield2({
    super.key,
    this.hintText,
    this.keyboardType,
    this.controller,
    required this.showRedBorderNotifier,
  });

  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final ValueNotifier<bool> showRedBorderNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: showRedBorderNotifier,
      builder: (context, showRedBorder, child) {
        return TextFormField(
          style: AppTextStyle.helveticaStyle.copyWith(fontSize: 16),
          controller: controller,
          onEditingComplete: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          onTapOutside: (value) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          onFieldSubmitted: (value) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyle.helveticaStyle,
            filled: true,
            fillColor: AppColors.grey,
            border: OutlineInputBorder(
              borderSide: showRedBorder
                  ? const BorderSide(color: Colors.red)
                  : BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
            errorText: null,
            error: const SizedBox.shrink(),
          ),
          keyboardType: keyboardType ?? TextInputType.multiline,
        );
      },
    );
  }
}

class CustomPopup extends StatelessWidget {
  final String imageUrl;
  final String message;

  const CustomPopup({
    Key? key,
    required this.imageUrl,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      contentPadding: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image Section
          Image.asset(
            imageUrl,
            width: double.infinity,
            height: 100,
          ),
          // Text Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              message,
              style: AppTextStyle.helveticaStyle.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: PrimaryButton(
              text: "Ok",
              onPressed: () {
                Navigator.of(context).pop(); // Close the popup
              },
            ),
          ),
        ],
      ),
    );
  }
}

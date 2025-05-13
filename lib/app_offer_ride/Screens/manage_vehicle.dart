import 'package:carpool_app/app_offer_ride/Controller/form_controller.dart';
import 'package:carpool_app/config/app_const.dart';
import 'package:carpool_app/config/app_fonts.dart';
import 'package:carpool_app/config/app_widgets.dart';
import 'package:carpool_app/config/applabels.dart';
import 'package:flutter/material.dart';

class ManageVehicle extends StatelessWidget {
  ManageVehicle({required this.offerController, super.key});

  final OfferFormController? offerController;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController makeController = TextEditingController();
  final TextEditingController modelController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar2(
              text: Applabels.manageVehicle,
              subtext: "Create your own Vehicle",
            ),
            SizedBox(height: AppConst.spacing * 2),
            Padding(
              padding: EdgeInsets.all(AppConst.padding * 2),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Text(
                              "Name *",
                              style: AppTextStyle.helveticaStyle
                                  .copyWith(fontSize: 18),
                            )),
                        Expanded(
                          flex: 2,
                          child: FilledTextfield(
                            hintText: "Car Name",
                            controller: nameController,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: AppConst.spacing),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Text(
                              "Company",
                              style: AppTextStyle.helveticaStyle
                                  .copyWith(fontSize: 18),
                            )),
                        Expanded(
                          flex: 2,
                          child: FilledTextfield(
                            hintText: "Company Name",
                            controller: makeController,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: AppConst.spacing),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Text(
                              "Model",
                              style: AppTextStyle.helveticaStyle
                                  .copyWith(fontSize: 18),
                            )),
                        Expanded(
                          flex: 2,
                          child: FilledTextfield(
                            hintText: "Year",
                            controller: modelController,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: AppConst.spacing * 2),
                  Row(
                    children: [
                      Expanded(
                          child: PrimaryButton(
                        text: "Save",
                        onPressed: () async {
                          // Check if all fields are filled
                          if (nameController.text.isEmpty ||
                              makeController.text.isEmpty ||
                              modelController.text.isEmpty) {
                            // Show the alert dialog if any field is empty
                            await _showAlertDialog(
                              context,
                              "Please fill out all required fields before saving the vehicle.",
                              "assets/images/contact-form.png",
                            );
                          } else {
                            // Proceed with saving the vehicle if all fields are filled
                            String resultMessage =
                                await offerController!.addVehicle(
                              nameController.text,
                              makeController.text,
                              modelController.text,
                            );

                            print(resultMessage);

                            // Close the current screen
                            Navigator.pop(context);
                          }
                        },
                      )),
                      SizedBox(
                        width: AppConst.spacing,
                      ),
                      Expanded(
                          child: PrimaryButton(
                              color: const Color(0xFFC4C4C4),
                              text: "Cancel",
                              onPressed: () {
                                Navigator.pop(context);
                              }))
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future _showAlertDialog(
      BuildContext context, String message, String image) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Image.asset(
                image,
                height: 100,
              ),
              SizedBox(height: AppConst.spacing * 2),
              Text(
                message,
                style: AppTextStyle.poppinsStyle.copyWith(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                "OK",
                style: AppTextStyle.helveticaStyle.copyWith(fontSize: 14),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

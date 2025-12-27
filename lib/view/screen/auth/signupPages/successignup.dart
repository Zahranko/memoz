import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:memzoProject/controller/auth/successsignupcontroller.dart';
import 'package:memzoProject/core/constant/color.dart';
import 'package:memzoProject/core/functions/alertexitapp.dart';
import 'package:memzoProject/view/widget/auth/custombuttomauth.dart';
import 'package:memzoProject/view/widget/auth/cutomtitleauth.dart';

class SuccessSignUp extends StatelessWidget {
  const SuccessSignUp({super.key});

  @override
  Widget build(BuildContext context) {
    SuccessSignUpdControllerImp controller = Get.put(
      SuccessSignUpdControllerImp(),
    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.pagePrimaryColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColor.pagePrimaryColor,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop) {
              final shouldPop = await alertExitApp();
              if (shouldPop) {
                Get.back(); // Pop manually if confirmed
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Icon(
                    Icons.check_circle_outline_outlined,
                    size: 200,
                    color: AppColor.buttonColor,
                    weight: 10.0,
                  ),
                ),
                const SizedBox(height: 15),
                const CustomTitleAuth(title: "Succefully Created"),

                const Text("Your account has been created successfully"),
                Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: CustomButtonAuth(
                    text: "Go to Login",
                    onPressed: () {
                      controller.goToLoginPage();
                    },
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

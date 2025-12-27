import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:memzoProject/controller/auth/logincontroller.dart';
import 'package:memzoProject/core/constant/routes.dart';

abstract class VerifyCodeLoginController extends GetxController {
  Future<void> checkCode(String enteredOtp);
  void goToHomePage();
}

class VerifyCodeLoginControllerImp extends VerifyCodeLoginController {
  int numberOfErrors = 0;
  final box = GetStorage();
  final LoginControllerImplement loginController =
      Get.find<LoginControllerImplement>();
  var isLoading = false.obs;

  @override
  Future<void> checkCode(String enteredOtp) async {
    String? storedOtp = box.read("otpCode");
    if (enteredOtp != storedOtp) {
      numberOfErrors++;
      if (numberOfErrors > 5) {
        Get.offAllNamed(AppRoute.login);
      }
      Get.snackbar("Error", "Invalid OTP. Please try again.");
      return;
    }

    goToHomePage();
  }

  void showLoadingDialog() {
    Get.dialog(
      Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }

  @override
  void goToHomePage() {
    Get.offAllNamed(AppRoute.HomeView);
  }
}

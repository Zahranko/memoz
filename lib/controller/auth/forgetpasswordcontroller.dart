import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memzoProject/core/constant/routes.dart';

abstract class ForgetPasswordController extends GetxController {
  sendResetEmail();
}

class ForgetPasswordControllerImp extends ForgetPasswordController {
  late TextEditingController email;

  @override
  sendResetEmail() async {
    String userEmail = email.text.trim();

    if (!GetUtils.isEmail(userEmail)) {
      Get.snackbar("Error", "Please enter a valid email address.");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: userEmail);

      Get.snackbar("Success", "Password reset link sent to your email.");

      Get.toNamed(
        AppRoute.successresetpassword,
        arguments: {"email": userEmail},
      );
    } catch (e) {
      if (e is FirebaseAuthException && e.code == "user-not-found") {
        Get.snackbar("Error", "Email not registered.");
      } else {
        Get.snackbar("Error", "Failed to send reset email.");
      }
    }
  }

  @override
  void onInit() {
    email = TextEditingController();
    super.onInit();
  }

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }
}

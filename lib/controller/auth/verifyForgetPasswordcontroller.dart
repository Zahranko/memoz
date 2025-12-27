import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:memzoProject/core/constant/routes.dart';

abstract class VerifyForgetPassCodeController extends GetxController {
  checkCode(String enteredOtp);
}

class VerifyForgetPassCodeControllerImp extends VerifyForgetPassCodeController {
  late String sentOtp;
  late String email;

  @override
  void onInit() {
    sentOtp = Get.arguments["otp"];
    email = Get.arguments["email"];
    super.onInit();
  }

  @override
  Future<void> checkCode(String enteredOtp) async {
    if (enteredOtp == sentOtp) {
      try {
        await FirebaseAuth.instance.signInAnonymously();

        Get.offNamed(AppRoute.resetpassword, arguments: {"email": email});
      } catch (e) {
        Get.snackbar("Error", "Authentication failed: $e");
      }
    } else {
      Get.snackbar("Error", "Invalid OTP. Please try again.");
    }
  }
}

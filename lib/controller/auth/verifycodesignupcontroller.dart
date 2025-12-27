import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:memzoProject/controller/auth/signupcontroller.dart';
import 'package:memzoProject/core/constant/routes.dart';

abstract class VerifyCodeSignUPController extends GetxController {
  checkCode(String enteredOtp);
  resendOtp();
}

class VerifyCodeSignUpControllerImp extends VerifyCodeSignUPController {
  int numberoftimeserrorcode = 0;
  User? user;
  var userid;
  String userEmail = "";
  String? verifyCode;

  // Use Get.put to ensure the controller exists in memory
  final SignupcontrollerImp signupController = Get.put(SignupcontrollerImp());

  @override
  void onInit() {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userid = user!.uid;
      userEmail = user!.email ?? "";
    }
    verifyCode = Get.arguments?.toString();
    super.onInit();
  }

  @override
  resendOtp() async {
    try {
    
      signupController.email.text = userEmail;

     
      await signupController.sendOtpVerification();

      if (signupController.otpCode != null) {
        verifyCode = signupController.otpCode;
      }

      numberoftimeserrorcode = 0;
      print("Resend Success. Synced Code: $verifyCode");
    } catch (e) {
      Get.snackbar("Error", "Failed to resend: $e");
    }
  }

  @override
  checkCode(String enteredOtp) async {
 
    print("Checking: Entered '$enteredOtp' vs Actual '$verifyCode'");

    if (enteredOtp.trim() == verifyCode) {
      try {
        await FirebaseFirestore.instance.collection("users").doc(userid).set({
          "emailVerified": true,
        }, SetOptions(merge: true));

        Get.snackbar("Success", "OTP Verified Successfully");
        Get.offAllNamed(AppRoute.createProfile);
      } catch (e) {
        Get.snackbar("Error", "Failed to update verification status.");
      }
    } else {
      numberoftimeserrorcode++;
      if (numberoftimeserrorcode > 6) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userid)
            .delete();
        if (FirebaseAuth.instance.currentUser != null) {
          await FirebaseAuth.instance.currentUser!.delete();
        }
        Get.offAllNamed(AppRoute.signup);
      }
      Get.snackbar("Error", "Invalid OTP. Please try again.");
    }
  }
}

import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:memzoProject/core/constant/routes.dart';
import 'package:memzoProject/core/functions/generateotp.dart';
import 'package:memzoProject/core/functions/sendotp.dart';

abstract class Logincontroller extends GetxController {
  login();
  SignUP();
  goToForgetPassword();
  gotoverifycode();
  sendOtpVerification();
  signInWithGoogle();
}

class LoginControllerImplement extends Logincontroller {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  late TextEditingController email;
  late TextEditingController password;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final box = GetStorage();
  String otpCode = '';

  bool isShowPassword = true;

  showPassword() {
    isShowPassword = !isShowPassword;
    update();
  }

  @override
  login() async {
    var formdata = formstate.currentState;
    if (formdata!.validate()) {
      try {
        final credential = await _auth.signInWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text,
        );

        if (credential.user != null) {
          box.write("userEmail", email.text.trim());
          sendOtpVerification();
        }
      } on FirebaseAuthException catch (e) {
        Get.snackbar("Login Error", e.message ?? "Unknown error");
      }
    }
  }

  @override
  sendOtpVerification() async {
    String? storedEmail = box.read("userEmail");
    if (storedEmail == null ||
        storedEmail.isEmpty ||
        !storedEmail.contains("@")) {
      Get.snackbar("Error", "Invalid email. Please log in again.");
      return;
    }

    otpCode = generateOtp();
    await sendOtpWithSendGrid(storedEmail, otpCode);

    box.write("otpCode", otpCode);
    Get.snackbar("OTP Sent", "Check your email for the OTP.");
    Get.offNamed(AppRoute.verifycodelogin);
  }

  @override
  SignUP() {
    Get.offNamed(AppRoute.signup);
  }

  @override
  goToForgetPassword() {
    Get.toNamed(AppRoute.forgetpassword);
  }

  @override
  gotoverifycode() {
    Get.offNamed(AppRoute.verifycodelogin);
  }

  @override
  void onInit() {
    email = TextEditingController();
    password = TextEditingController();
    super.onInit();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  signInWithGoogle() {
    throw UnimplementedError();
  }
}

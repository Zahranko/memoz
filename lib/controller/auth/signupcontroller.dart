import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:memzoProject/core/constant/routes.dart';
import 'package:memzoProject/core/functions/generateotp.dart';
import 'package:memzoProject/core/functions/sendotp.dart';

abstract class Signupcontroller extends GetxController {
  signUp();
  goToSignIn();
  signInWithGoogle();
  sendOtpVerification();
}

class SignupcontrollerImp extends Signupcontroller {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  late TextEditingController email;
  late TextEditingController phone;
  late TextEditingController password;
  late TextEditingController confirmpassword;
  String otpCode = "";
  String? gender;
   bool isShowPassword = true;

  showPassword() {
    isShowPassword = !isShowPassword;
    update();
  }

  @override
  Future<void> signUp() async {
    var formdata = formstate.currentState;
    if (formdata!.validate()) {
      if (password.text != confirmpassword.text) {
        Get.snackbar("Error", "Passwords do not match.");
        return;
      }

      try {
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: email.text,
              password: password.text,
            );

        String uid = credential.user!.uid;

        await FirebaseFirestore.instance.collection("users").doc(uid).set({
          "email": email.text,
          "phone": phone.text,
          "gender": gender,
          "created_at": FieldValue.serverTimestamp(),
        });

        await sendOtpVerification();
        Get.offNamed(AppRoute.verifyCodeSignup, arguments: otpCode);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          Get.snackbar("Error", "The password provided is too weak.");
        } else if (e.code == 'email-already-in-use') {
          Get.snackbar("Error", "The account already exists for that email.");
        } else {
          Get.snackbar("Error", "Signup failed: ${e.message}");
        }
      } catch (e) {
        Get.snackbar("Error", "An unexpected error occurred: $e");
      }
    }
  }

  @override
  goToSignIn() {
    Get.offAllNamed(AppRoute.login);
  }

  @override
  Future<void> sendOtpVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      Get.snackbar("Error", "No user is logged in or email is missing.");
      return;
    }

    otpCode = generateOtp();
    await sendOtpWithSendGrid(user.email!, otpCode);

    Get.snackbar("OTP Sent", "Check your email for the OTP.");
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  void onInit() {
    password = TextEditingController();
    email = TextEditingController();
    phone = TextEditingController();
    confirmpassword = TextEditingController();
    super.onInit();
  }

  @override
  void dispose() {
    email.dispose();
    phone.dispose();
    password.dispose();
    confirmpassword.dispose();
    super.dispose();
  }
}

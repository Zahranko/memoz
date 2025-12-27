import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:memzoProject/controller/auth/timercontroller.dart';
import 'package:memzoProject/controller/auth/verifycodesignupcontroller.dart';
import 'package:memzoProject/core/constant/color.dart';
import 'package:memzoProject/core/constant/routes.dart';
import 'package:memzoProject/core/functions/alertexitappverifycode.dart';
import 'package:memzoProject/view/widget/auth/textsignup.dart';

class VerifyCodeSignUp extends StatelessWidget {
  const VerifyCodeSignUp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    final VerifyCodeSignUpControllerImp controller = Get.put(
      VerifyCodeSignUpControllerImp(),
    );
    final TimerController timerController = Get.put(TimerController());

    return Scaffold(
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
              final shouldPop = await alertExitAppVerifyUser();
              if (shouldPop) {
                Get.back();
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Text(
                  "Enter OTP Code",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 10),
                const Text(
                  "We have sent a 4-digit code to your email. Please enter it below.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),

                Text(
                  controller.userEmail,
                  style: const TextStyle(color: Colors.black),
                ),

                const SizedBox(height: 50),

                OtpTextField(
                  focusedBorderColor: AppColor.buttonColor,
                  enabledBorderColor: Colors.black,
                  fieldWidth: 60.0,
                  borderRadius: BorderRadius.circular(15),

                  numberOfFields: 4, // ✅ MUST BE 4

                  borderColor: Colors.brown,
                  showFieldAsBox: true,
                  onSubmit: (String verificationCode) {
                    // This runs automatically when 4 digits are filled
                    controller.checkCode(verificationCode);
                  },
                ),

                const SizedBox(height: 20),

                // --- Resend OTP Button ---
                Obx(
                  () => TextButton(
                    onPressed:
                        timerController.canResend.value
                            ? () {
                              // Call the controller logic
                              controller.resendOtp();
                              // Reset timer UI
                              timerController.startResendTimer();
                            }
                            : null,
                    child: Text(
                      timerController.canResend.value
                          ? "Resend OTP"
                          : "Resend in ${timerController.resendTimer.value}s",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color:
                            timerController.canResend.value
                                ? AppColor.buttonColor
                                : Colors.grey,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 3),

                CustomTextSignupOrSignin(
                  textone: "Get back to ",
                  texttwo: "Login page",
                  onTap: () {
                    Get.offAllNamed(AppRoute.login);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

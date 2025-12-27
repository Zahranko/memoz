import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:memzoProject/controller/auth/timercontroller.dart';
import 'package:memzoProject/controller/auth/verifycodelogin.dart';
import 'package:memzoProject/core/constant/color.dart';
import 'package:memzoProject/core/constant/routes.dart';
import 'package:memzoProject/view/widget/auth/textsignup.dart';

class LoginVerifyCode extends StatelessWidget {
  const LoginVerifyCode({super.key});

  @override
  Widget build(BuildContext context) {
    final VerifyCodeLoginControllerImp controller = Get.put(
      VerifyCodeLoginControllerImp(),
    );
    final TimerController timerController = Get.put(TimerController());

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.pagePrimaryColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColor.pagePrimaryColor,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            ); // ✅ Show loading screen
          }

          return Container(
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
                const SizedBox(height: 50),

                OtpTextField(
                  focusedBorderColor: Colors.orange,
                  enabledBorderColor: Colors.black,
                  fieldWidth: 60.0,
                  borderRadius: BorderRadius.circular(15),
                  numberOfFields: 4,
                  borderColor: Colors.brown,
                  showFieldAsBox: true,
                  onSubmit: (String verificationCode) {
                    controller.checkCode(verificationCode);
                  },
                ),

                const SizedBox(height: 20),

                // Resend OTP Button with Timer
                Obx(
                  () => TextButton(
                    onPressed:
                        timerController.canResend.value
                            ? () {
                              String? storedEmail = controller
                                  .loginController
                                  .box
                                  .read("userEmail");

                              if (storedEmail == null ||
                                  storedEmail.isEmpty ||
                                  !storedEmail.contains("@")) {
                                Get.snackbar(
                                  "Error",
                                  "Invalid email. Please log in again.",
                                );
                                return;
                              }

                              Get.snackbar(
                                "OTP",
                                "Resending OTP to: $storedEmail",
                              );

                              controller.loginController.sendOtpVerification();
                              timerController.startResendTimer();
                            }
                            : null,
                    child: Text(
                      timerController.canResend.value
                          ? "Resend OTP"
                          : "Resend in ${timerController.resendTimer.value}s",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color:
                            timerController.canResend.value
                                ? Colors.orange[500]
                                : Colors.grey,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),
                CustomTextSignupOrSignin(
                  textone: "Get back to ",
                  texttwo: "Login page",
                  onTap: () {
                    Get.offAllNamed(AppRoute.login);
                  },
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

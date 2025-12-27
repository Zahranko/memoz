import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:memzoProject/controller/auth/verifyForgetPasswordcontroller.dart';
import 'package:memzoProject/core/constant/color.dart';

class VerifyCode extends StatelessWidget {
  const VerifyCode({super.key});

  @override
  Widget build(BuildContext context) {
    VerifyForgetPassCodeControllerImp controller = Get.put(
      VerifyForgetPassCodeControllerImp(),
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
        child: Container(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const SizedBox(height: 70),
              Container(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  "Check Your email",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              const SizedBox(height: 7),
              Container(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  "We sent a reset link to your email. enter 4 digit code that mentioned in email",
                  style: TextStyle(color: Colors.grey[600]),
                ),
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

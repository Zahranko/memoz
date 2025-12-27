import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:memzoProject/controller/auth/forgetpasswordcontroller.dart';
import 'package:memzoProject/core/constant/color.dart';
import 'package:memzoProject/core/functions/validateinput.dart';
import 'package:memzoProject/view/widget/auth/custombuttomauth.dart';
import 'package:memzoProject/view/widget/auth/customtextformauth.dart';

class Forgetpassword extends StatelessWidget {
  const Forgetpassword({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => ForgetPasswordControllerImp());
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.pagePrimaryColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColor.pagePrimaryColor,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: GetBuilder<ForgetPasswordControllerImp>(
          builder:
              (controller) => Container(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  children: [
                    const SizedBox(height: 70),
                    Container(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        "Forget Password",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Container(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        "Please enter your email to reset your password",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 50),
                    CustomTextFormAuth(
                      isNumber: false,
                      hinttext: "Enter your email",
                      labeltext: "Email",
                      icondata: Icons.email_outlined,
                      mycontroller: controller.email,
                      valid: (val) {
                        return validateInput(val!, 5, 50, "email");
                      },
                    ),

                    CustomButtonAuth(
                      text: "Reset Password",
                      onPressed: () {
                        controller.sendResetEmail();
                      },
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

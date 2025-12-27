import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:memzoProject/controller/auth/signupcontroller.dart';
import 'package:memzoProject/core/constant/color.dart';
import 'package:memzoProject/core/constant/imagesasset.dart';
import 'package:memzoProject/core/functions/alertexitapp.dart';
import 'package:memzoProject/core/functions/validateinput.dart';
import 'package:memzoProject/view/widget/auth/custom_icon_auth.dart';
import 'package:memzoProject/view/widget/auth/custombuttomauth.dart';
import 'package:memzoProject/view/widget/auth/customgenderbutton.dart';
import 'package:memzoProject/view/widget/auth/customtextformauth.dart';
import 'package:memzoProject/view/widget/auth/textsignup.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => SignupcontrollerImp());
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.pagePrimaryColor,
      body: SafeArea(
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop) {
              final shouldPop = await alertExitApp();
              if (shouldPop) {
                Get.back(); // Pop manually if confirmed
              }
            }
          },
          child: GetBuilder<SignupcontrollerImp>(
            builder:
                (controller) => Container(
                  padding: const EdgeInsets.all(15),
                  child: Form(
                    key: controller.formstate,
                    child: ListView(
                      children: [
                        Image.asset(
                          ImagesAsset.signinImage,
                          height: 200,
                          width: 200,
                        ),

                        CustomTextFormAuth(
                          isNumber: false,
                          hinttext: "Enter your Email",
                          labeltext: "Email",
                          icondata: Icons.email_outlined,
                          mycontroller: controller.email,
                          valid: (val) {
                            return validateInput(val!, 5, 50, "email");
                          },
                        ),

                        CustomTextFormAuth(
                          isNumber: true,
                          hinttext: "Enter your phone number",
                          labeltext: "Phone Number",
                          icondata: Icons.phone_android_outlined,
                          mycontroller: controller.phone,
                          valid: (val) {
                            return validateInput(val!, 10, 13, "phone");
                          },
                        ),

                        Container(
                          padding: EdgeInsets.only(left: 30),
                          child: Text("Gender:"),
                        ),

                        Container(
                          padding: EdgeInsets.only(left: 60),
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Wrap(
                              children: [
                                CustomGenderButton(
                                  onGenderSelected: (selectedGender) {
                                    controller.gender = selectedGender;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        CustomTextFormAuth(
                          isNumber: false,
                          hinttext: "Enter your Password",
                          labeltext: "Password",
                          icondata: Icons.remove_red_eye_outlined,
                        onTapIon: () {
                          controller.showPassword();
                        },
                          mycontroller: controller.password,
                          obscureText: controller.isShowPassword,
                          valid: (val) {
                            return validateInput(val!, 8, 50, "password");
                          },
                        ),
                        CustomTextFormAuth(
                          isNumber: false,
                          hinttext: "Confirm password",
                          labeltext: "Password",
                          icondata: Icons.remove_red_eye_outlined,
                        onTapIon: () {
                          controller.showPassword();
                        },
                        obscureText: controller.isShowPassword,
                          mycontroller: controller.confirmpassword,
                          valid: (val) {
                            return validateInput(val!, 8, 50, "password");
                          },
                        ),

                        CustomButtonAuth(
                          text: "Sign up",
                          onPressed: () {
                            controller.signUp();
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "━━",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            Text(
                              " Sign up with social accounts ",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "━━",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconAuth(
                              iconWidget: FontAwesomeIcons.apple,
                              onPressed: () {},
                            ),
                            CustomIconAuth(
                              iconWidget: FontAwesomeIcons.google,
                              onPressed: () {
                                controller.signInWithGoogle();
                              },
                            ),
                          ],
                        ),
                        CustomTextSignupOrSignin(
                          textone: "Already have an account ?",
                          texttwo: "Sign in",
                          onTap: () {
                            controller.goToSignIn();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }
}

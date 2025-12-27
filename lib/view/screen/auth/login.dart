import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:memzoProject/controller/auth/logincontroller.dart';
import 'package:memzoProject/core/constant/color.dart';
import 'package:memzoProject/core/constant/imagesasset.dart';
import 'package:memzoProject/core/functions/alertexitapp.dart';
import 'package:memzoProject/core/functions/validateinput.dart';
import 'package:memzoProject/view/widget/auth/custom_icon_auth.dart';
import 'package:memzoProject/view/widget/auth/custombuttomauth.dart';
import 'package:memzoProject/view/widget/auth/customtextformauth.dart';
import 'package:memzoProject/view/widget/auth/textsignup.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => LoginControllerImplement());
    return GetBuilder<LoginControllerImplement>(
      builder:
          (controller) => Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: AppColor.pagePrimaryColor,
            appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0.0),
            body: PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (!didPop) {
                  final shouldPop = await alertExitApp();
                  if (shouldPop) {
                    Get.back();
                  }
                }
              },
              child: Container(
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
                      const SizedBox(height: 150),
                      CustomTextFormAuth(
                        isNumber: false,
                        hinttext: "Enter your Email",
                        labeltext: "Email",
                        icondata: Icons.person_2_outlined,
                        mycontroller: controller.email,
                        valid: (val) {
                          return validateInput(val!, 5, 70, "email");
                        },
                      ),
                      CustomTextFormAuth(
                        isNumber: false,
                        hinttext: "Enter your password",
                        labeltext: "Password",
                        icondata: Icons.remove_red_eye_outlined,
                        onTapIon: () {
                          controller.showPassword();
                        },
                        obscureText: controller.isShowPassword,
                        mycontroller: controller.password,
                        valid: (val) {
                          return validateInput(val!, 8, 50, "password");
                        },
                      ),
                      InkWell(
                        onTap: () {
                          controller.goToForgetPassword();
                        },
                        child: const Text(
                          "Forget Password",
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      CustomButtonAuth(
                        text: "Log in",
                        onPressed: () {
                          controller.login();
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
                            " Login with social accounts ",
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
                        textone: "Don't have an account ?",
                        texttwo: "Sign Up",
                        onTap: () {
                          controller.SignUP();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }
}

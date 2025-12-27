import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:memzoProject/controller/auth/create_profile_controller.dart';
import 'package:memzoProject/core/constant/color.dart';
import 'package:memzoProject/core/functions/validateinput.dart';
import 'package:memzoProject/view/widget/auth/ProfileAvatarPicker.dart';
import 'package:memzoProject/view/widget/auth/custombuttomauth.dart';
import 'package:memzoProject/view/widget/auth/customtextformauth.dart';
import 'package:memzoProject/view/widget/auth/customtextformdatepicker.dart';

class CreateProfileView extends StatelessWidget {
  final CreateProfileController controller = Get.put(CreateProfileController());

  CreateProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pagePrimaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          textAlign: TextAlign.center,
          "Complete Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- 1. Profile Picture Picker ---
              const SizedBox(height: 10),
              Obx(
                () => ProfileAvatarPicker(
                  image: controller.profileImage.value,
                  onTap: controller.pickImage,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Upload Profile Picture",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),

              const SizedBox(height: 30),

              // --- 2. Name Fields (Row) ---
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormAuth(
                      isNumber: false,
                      hinttext: "First Name..",
                      labeltext: "First Name",
                      icondata: Icons.person_2_outlined,
                      mycontroller: controller.firstNameController,
                      valid: (val) {
                        return validateInput(val!, 5, 70, "email"); //change
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: CustomTextFormAuth(
                      isNumber: false,
                      hinttext: "Last Name..",
                      labeltext: "Last Name",
                      icondata: Icons.person_2_outlined,
                      mycontroller: controller.lastNameController,
                      valid: (val) {
                        return validateInput(val!, 5, 70, "email"); //change
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // --- 3. Username Field ---
              CustomTextFormAuth(
                isNumber: false,
                hinttext: "Enter your username",
                labeltext: "Username",
                icondata: Icons.person_2_outlined,
                mycontroller: controller.usernameController,
                valid: (val) {
                  return validateInput(val!, 5, 70, "email"); //change
                },
              ),

              const SizedBox(height: 20),

              CustomTextFormBirthdateAuth(
                hinttext: "Enter your birthdate",
                labeltext: "Birthdate",
                mycontroller: controller.bdate,
                icondata: Icons.calendar_today,
                valid: (val) {
                  return validateInput(val!, 5, 70, "birthdate");
                },
                isNumber: false,
                onChange: (val) {
                  controller.bdate.text = val;
                },
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                child: CustomButtonAuth(
                  text: "Submit Profile",
                  onPressed: () {
                    controller.submitProfile();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//add a button to return to the login page and then delets the account.

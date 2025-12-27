import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:memzoProject/controller/usercontroller/editProfileController.dart';
import 'package:memzoProject/controller/usercontroller/profilePageController.dart';
import 'package:memzoProject/core/constant/color.dart';
import 'package:memzoProject/view/widget/auth/customtextformauth.dart';

class EditProfileView extends StatelessWidget {
  EditProfileView({Key? key}) : super(key: key);

  final EditProfileController controller = Get.put(EditProfileController());
  final ProfileController profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pagePrimaryColor,
      appBar: AppBar(
        backgroundColor: AppColor.pagePrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Obx(
            () =>
                controller.isLoading.value
                    ? const Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                    : IconButton(
                      icon: const Icon(
                        Icons.check,
                        color: AppColor.buttonColor,
                      ),
                      onPressed: () => controller.saveProfile(),
                    ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    Obx(() {
                      ImageProvider image;
                      if (controller.selectedImage.value != null) {
                        image = FileImage(controller.selectedImage.value!);
                      } else if (profileController
                          .profilePic
                          .value
                          .isNotEmpty) {
                        image = NetworkImage(
                          profileController.profilePic.value,
                        );
                      } else {
                        image = const NetworkImage("https://i.pravatar.cc/300");
                      }

                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: image,
                        ),
                      );
                    }),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => controller.pickImage(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColor.buttonColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              CustomTextFormAuth(
                labeltext: "Full Name",
                hinttext: "Enter your name",
                icondata: Icons.person_outline,
                mycontroller: controller.nameController,
                isNumber: false,
                valid: (val) {
                  if (val == null || val.isEmpty) return "Name cannot be empty";
                  return null;
                },
              ),

              CustomTextFormAuth(
                labeltext: "Username",
                hinttext: "Enter username",
                icondata: Icons.alternate_email,
                mycontroller: controller.usernameController,
                isNumber: false,
                valid: (val) {
                  if (val == null || val.isEmpty)
                    return "Username cannot be empty";
                  return null;
                },
              ),

              CustomTextFormAuth(
                labeltext: "Bio",
                hinttext: "Write something about yourself",
                icondata: Icons.info_outline,
                mycontroller: controller.bioController,
                isNumber: false,
                valid: (val) => null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

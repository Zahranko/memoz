import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Add intl to pubspec.yaml for date formatting
import 'dart:io';
import 'package:memzoProject/controller/usercontroller/create_profile_controller.dart';

class CreateProfileView extends StatelessWidget {
  final CreateProfileController controller = Get.put(CreateProfileController());

  CreateProfileView({Key? key}) : super(key: key);

  // Constants based on your design
  final Color primaryColor = const Color(0xFFC87859); // The Terracotta/Brown
  final Color bgColor = const Color(0xFFFFF8F0); // The Cream/Beige background

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Complete Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
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
                    child: _buildTextField(
                      controller: controller.firstNameController,
                      label: "First Name",
                      icon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildTextField(
                      controller: controller.lastNameController,
                      label: "Last Name",
                      icon: Icons.person_outline,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // --- 3. Username Field ---
              _buildTextField(
                controller: controller.usernameController,
                label: "Unique Username",
                icon: Icons.alternate_email,
              ),

              const SizedBox(height: 20),

              // --- 4. Birthday Picker ---
              Obx(() {
                String dateText =
                    controller.selectedDate.value == null
                        ? "Select Birthday"
                        : DateFormat(
                          'dd MMM yyyy',
                        ).format(controller.selectedDate.value!);

                return GestureDetector(
                  onTap: () => controller.chooseDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateText,
                          style: TextStyle(
                            color:
                                controller.selectedDate.value == null
                                    ? Colors.grey[600]
                                    : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        const Icon(
                          Icons.calendar_month_outlined,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 40),

              // --- 5. Submit Button ---
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed:
                        controller.isLoading.value
                            ? null
                            : controller.submitProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child:
                        controller.isLoading.value
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              "Create Profile",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for consistent TextFields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Enter $label",
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 18,
              ),
              suffixIcon: Icon(icon, color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.grey, width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: primaryColor, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
class ProfileAvatarPicker extends StatelessWidget {
  final File? image;
  final VoidCallback onTap;

  const ProfileAvatarPicker({
    Key? key,
    this.image, // CHANGED: Removed 'required'
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: image != null
                  ? Image.file(
                      image!,
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                    )
                  : Icon(Icons.person, size: 60, color: Colors.grey[400]),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFC87859),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}
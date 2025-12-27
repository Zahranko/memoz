import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memzoProject/controller/usercontroller/profilePageController.dart';

class EditProfileController extends GetxController {
  final ProfileController _profileController = Get.find<ProfileController>();

  late TextEditingController nameController;
  late TextEditingController usernameController;
  late TextEditingController bioController;

  var isLoading = false.obs;
  var selectedImage = Rxn<File>();

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController(
      text: _profileController.fullName.value,
    );
    usernameController = TextEditingController(
      text: _profileController.username.value,
    );
    bioController = TextEditingController(text: _profileController.bio.value);
  }

  @override
  void onClose() {
    nameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    super.onClose();
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
    }
  }

  // --- UPDATED SAVE FUNCTION ---
  Future<void> saveProfile() async {
    isLoading.value = true;
    String uid = FirebaseAuth.instance.currentUser!.uid;
    String newUsername = usernameController.text.trim();
    String currentUsername = _profileController.username.value;
    
    // --- 1. UNIQUENESS CHECK START ---
    
    // Only check Firestore if the username is DIFFERENT from what it was before.
    if (newUsername != currentUsername) {
      try {
        final usernameCheck = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: newUsername)
            .get();

        // If we found any documents, it means the username is taken
        if (usernameCheck.docs.isNotEmpty) {
          Get.snackbar(
            "Username Taken", 
            "The username '$newUsername' is already in use.",
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
          );
          isLoading.value = false;
          return; // STOP the function here
        }
      } catch (e) {
        Get.snackbar("Error", "Could not verify username uniqueness.");
        isLoading.value = false;
        return;
      }
    }
    // --- UNIQUENESS CHECK END ---

    String? imageUrl;

    try {
      if (selectedImage.value != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('$uid.jpg');

        await ref.putFile(selectedImage.value!);
        imageUrl = await ref.getDownloadURL();
      }

      Map<String, dynamic> updateData = {
        'name': nameController.text.trim(),
        'username': newUsername, // Use the variable we cleaned
        'bio': bioController.text.trim(),
      };

      if (imageUrl != null) {
        updateData['profilePic'] = imageUrl;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update(updateData);

      // Update Local Controller
      _profileController.fullName.value = nameController.text.trim();
      _profileController.username.value = newUsername;
      _profileController.bio.value = bioController.text.trim();
      if (imageUrl != null) {
        _profileController.profilePic.value = imageUrl;
      }

      Get.back();
      Get.snackbar(
        "Success",
        "Profile updated successfully",
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update profile: $e",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memzoProject/core/constant/routes.dart';

class CreateProfileController extends GetxController {
  // UI Controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();

  // Observables
  var selectedDate = Rxn<DateTime>();
  var profileImage = Rxn<File>();
  var isLoading = false.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- 1. Pick Image Logic ---
  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      profileImage.value = File(pickedFile.path);
    }
  }

  // --- 2. Date Picker Logic ---
  void chooseDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFC87859),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  // --- 3. Submission Logic ---
  Future<void> submitProfile() async {
    if (profileImage.value == null) {
      Get.snackbar("Missing Info", "Please select a profile picture");
      return;
    }
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        usernameController.text.isEmpty ||
        selectedDate.value == null) {
      Get.snackbar("Missing Info", "Please fill all fields");
      return;
    }

    try {
      isLoading.value = true;
      String uid = _auth.currentUser!.uid;

      // A. Check Username Uniqueness
      final usernameCheck =
          await _firestore
              .collection('users')
              .where('username', isEqualTo: usernameController.text.trim())
              .get();

      if (usernameCheck.docs.isNotEmpty) {
        isLoading.value = false;
        Get.snackbar("Error", "Username already taken, please choose another.");
        return;
      }

      // B. Upload Image to Firebase Storage
      String fileName = 'profile_$uid.jpg';
      Reference ref = _storage.ref().child('user_avatars').child(fileName);
      UploadTask uploadTask = ref.putFile(profileImage.value!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // C. Save User Data to Firestore
      await _firestore.collection('users').doc(uid).set({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'username': usernameController.text.trim(),
        'email': _auth.currentUser?.email,
        'birthDate': selectedDate.value!.toIso8601String(),
        'userAvatar': downloadUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'uid': uid,
      });

      isLoading.value = false;
      Get.toNamed(AppRoute.successSignup);
      ; // Navigate to Home after success
    } catch (e) {
      isLoading.value = false;
      print(e);
      Get.snackbar("Error", "Failed to create profile: $e");
    }
  }
}

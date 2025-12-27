import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memzoProject/core/constant/routes.dart';

class CreateProfileController extends GetxController {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final bdate = TextEditingController();

  var profileImage = Rxn<File>();
  var isLoading = false.obs;
  
 
  final String defaultAvatarUrl = 'https://firebasestorage.googleapis.com/v0/b/firstpro-37e05.appspot.com/o/user_avatars%2Fimages.jpg?alt=media';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    bdate.dispose();
    super.onClose();
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      profileImage.value = File(pickedFile.path);
    }
  }

  Future<void> submitProfile() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      Get.snackbar("Error", "User not logged in");
      return;
    }

    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        usernameController.text.isEmpty) {
      Get.snackbar("Missing Info", "Please fill all fields");
      return;
    }

    try {
      isLoading.value = true;
      String uid = currentUser.uid;

    
      final usernameCheck = await _firestore
          .collection('users')
          .where('username', isEqualTo: usernameController.text.trim())
          .get();

      if (usernameCheck.docs.isNotEmpty) {
        isLoading.value = false;
        Get.snackbar("Error", "Username already taken, please choose another.");
        return;
      }

      
      
      
      String finalAvatarUrl = defaultAvatarUrl;

     
      if (profileImage.value != null) {
        String fileName = 'profile_$uid.jpg';
        Reference ref = _storage.ref().child('user_avatars').child(fileName);
        
   
        UploadTask uploadTask = ref.putFile(profileImage.value!);
        TaskSnapshot snapshot = await uploadTask;
        
       
        finalAvatarUrl = await snapshot.ref.getDownloadURL();
      }
      
    

      await _firestore.collection('users').doc(uid).set({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'username': usernameController.text.trim(),
        'birthDate': bdate.text,
        'userAvatar': finalAvatarUrl, 
        'createdAt': FieldValue.serverTimestamp(),
        'uid': uid,
      }, SetOptions(merge: true));

      isLoading.value = false;
      Get.offAllNamed(AppRoute.successSignup);
      
    } catch (e) {
      isLoading.value = false;
      print(e);
      Get.snackbar("Error", "Failed to create profile: $e");
    }
  }
}
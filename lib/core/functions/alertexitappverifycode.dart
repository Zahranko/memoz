import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool> alertExitAppVerifyUser() {
  Get.defaultDialog(
    title: 'Exit App',
    middleText: "Are you sure you want to exit the app?",
    actions: [
      ElevatedButton(
        onPressed: () {
          User? user = FirebaseAuth.instance.currentUser;
          FirebaseFirestore.instance
              .collection("users")
              .doc(user!.uid)
              .delete();
          FirebaseAuth.instance.currentUser!.delete();
          exit(0);
        },
        child: Text("Confirm"),
      ),
      ElevatedButton(
        onPressed: () {
          Get.back();
        },
        child: Text("Cancel"),
      ),
    ],
  );
  return Future.value(true);
}

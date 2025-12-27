import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:memzoProject/core/constant/routes.dart';

class AppController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    // Start the check once the app is fully ready
    _checkUserLogin();
  }

  void _checkUserLogin() async {
    // Optional: Artificial delay if you want the logo to be seen for at least 1-2 seconds
    // await Future.delayed(const Duration(seconds: 2));

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in -> Go to Home
      // Use offAllNamed to remove the splash placeholder from the back stack
      Get.offAllNamed(AppRoute.HomeView);
    } else {
      // User is NOT logged in -> Go to Login
      Get.offAllNamed(AppRoute.login);
    }

    // 4. REMOVE SPLASH SCREEN
    // Now that we have navigated, lift the curtain.
    FlutterNativeSplash.remove();
  }
}

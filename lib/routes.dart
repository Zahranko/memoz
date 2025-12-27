import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:memzoProject/core/constant/routes.dart';
import 'package:memzoProject/login_binding.dart';
import 'package:memzoProject/view/screen/auth/forgetpassword/forgetpassword.dart';
import 'package:memzoProject/view/screen/auth/forgetpassword/successresetpassword.dart';
import 'package:memzoProject/view/screen/auth/forgetpassword/verifycoderesetpassword.dart';
import 'package:memzoProject/view/screen/auth/login.dart';
import 'package:memzoProject/view/screen/auth/loginverifycode.dart';
import 'package:memzoProject/view/screen/auth/signupPages/signup.dart';
import 'package:memzoProject/view/screen/auth/signupPages/successignup.dart';
import 'package:memzoProject/view/screen/auth/signupPages/verifycodesignup.dart';
import 'package:memzoProject/view/screen/user/AddpostView.dart';
import 'package:memzoProject/view/screen/user/ExoploreView.dart';
import 'package:memzoProject/view/screen/user/ProfilePageView.dart';
import 'package:memzoProject/view/screen/user/editProfileView.dart';
import 'package:memzoProject/view/screen/user/home_view.dart';
import 'package:memzoProject/view/screen/user/navbar_view.dart';
import 'package:memzoProject/view/screen/auth/signupPages/create_profile_view.dart';

List<GetPage<dynamic>>? routes = [
  GetPage(name: AppRoute.login, page: () => const Login()),
  GetPage(name: AppRoute.signup, page: () => const SignUp()),
  GetPage(name: AppRoute.forgetpassword, page: () => const Forgetpassword()),
  GetPage(name: AppRoute.verifycode, page: () => const VerifyCode()),

  GetPage(name: AppRoute.successSignup, page: () => const SuccessSignUp()),
  GetPage(
    name: AppRoute.successresetpassword,
    page: () => const SuccessResetPassword(),
  ),
  GetPage(
    name: AppRoute.verifyCodeSignup,
    page: () => const VerifyCodeSignUp(),
    binding: LoginBinding(),
  ),
  GetPage(
    name: AppRoute.verifycodelogin,
    page: () => LoginVerifyCode(),
    binding: LoginBinding(),
  ),

  // --- ADD THIS NEW ROUTE ---
  GetPage(
    name:
        AppRoute
            .createProfile, // Ensure this string exists in your AppRoute class
    page: () => CreateProfileView(),
  ),

  // --------------------------
  GetPage(name: AppRoute.navbar, page: () => const CustomBottomNavBar()),
  GetPage(name: AppRoute.HomeView, page: () => const HomeView()),
  GetPage(name: AppRoute.AddPostView, page: () => AddPostView()),
  GetPage(name: AppRoute.ProfilePageView, page: () => ProfileView()),
  GetPage(name: AppRoute.ExploreView, page: () => ExploreView()),
  GetPage(name: AppRoute.editProfileView, page: () => EditProfileView()),
];

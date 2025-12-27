import 'package:get/get.dart';
import 'package:memzoProject/core/constant/routes.dart';

abstract class SuccessResetPasswordController {
  goToLoginPage();
}

class SuccessResetPasswordControllerImp extends SuccessResetPasswordController {
  var userEmail = "No email provided".obs;

  SuccessResetPasswordControllerImp() {
    var args = Get.arguments;
    if (args != null && args["email"] != null) {
      userEmail.value = args["email"];
    }
  }

  @override
  goToLoginPage() {
    Get.offAllNamed(AppRoute.login);
  }
}

import 'package:get/get.dart';
import 'package:memzoProject/core/constant/routes.dart';

abstract class SuccessSignUpdController {
  goToLoginPage();
}

class SuccessSignUpdControllerImp extends SuccessSignUpdController {
  @override
  goToLoginPage() {
    Get.offAllNamed(AppRoute.login);
  }
}

import 'package:get/get.dart';
import 'package:memzoProject/app_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Puts the AppController into memory immediately when the app starts
    Get.put(AppController());
  }
}

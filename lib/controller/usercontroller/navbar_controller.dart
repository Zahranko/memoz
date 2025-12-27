import 'package:get/get.dart';

class NavBarController extends GetxController {
  var currentIndex = 0.obs; // The current index of the tab

  void changeTabIndex(int index) {
    currentIndex.value = index; // Change the current index
  }
}

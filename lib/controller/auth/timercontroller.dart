import 'dart:async';
import 'package:get/get.dart';

class TimerController extends GetxController {
  RxInt resendTimer = 10.obs;
  RxBool canResend = true.obs;
  Timer? _timer;

  void startResendTimer() {
    canResend.value = false;
    resendTimer.value = 10;

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

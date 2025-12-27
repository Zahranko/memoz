String generateOtp() {
  return (1000 +
          (9999 - 1000) *
              (DateTime.now().millisecondsSinceEpoch % 10000) ~/
              10000)
      .toString();
}

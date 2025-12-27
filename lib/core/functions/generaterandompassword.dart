import 'dart:math';

String generateRandomPassword({int length = 12}) {
  const String upperCase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const String lowerCase = 'abcdefghijklmnopqrstuvwxyz';
  const String numbers = '0123456789';
  const String symbols = '!@#\$%^&*()_-+=<>?';

  const String allChars = upperCase + lowerCase + numbers + symbols;
  final Random random = Random.secure();

  return List.generate(length, (index) {
    return allChars[random.nextInt(allChars.length)];
  }).join();
}

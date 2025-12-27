import 'package:get/get_utils/src/get_utils/get_utils.dart';

String? validateInput(String val, int min, int max, String type) {
  if (val.isEmpty) return "Please enter a value";

  switch (type) {
    case "username":
      if (!GetUtils.isUsername(val)) return "Invalid username";
      break;

    case "email":
      if (!GetUtils.isEmail(val)) return "Invalid Email";
      break;

    case "phone":
      final jordanPhoneRegex = RegExp(r'^(079|078|077)\d{7}$|^\+9627\d{8}$');
      if (!jordanPhoneRegex.hasMatch(val)) {
        return "Invalid phone number";
      }
      break;

    case "License":
      if (val == "press on add button to insert image") {
        return "Add License Image";
      }
      break;

    case "NotExisted":
      return "Email doesn't exist";

    case "wrong":
      return "Wrong Password";

    case "birthdate":
      if (val.isEmpty) return "Please enter your birthdate";

      try {
        // Parse the input using the custom format: DD/MM/YYYY
        List<String> dateParts = val.split('/');
        if (dateParts.length != 3) {
          return "Invalid date format (use DD/MM/YYYY)";
        }
        int day = int.parse(dateParts[0]);
        int month = int.parse(dateParts[1]);
        int year = int.parse(dateParts[2]);

        DateTime birthDate = DateTime(year, month, day);
        DateTime now = DateTime.now();
        int age = now.year - birthDate.year;

        if (birthDate.isAfter(now)) return "Birthdate can't be in the future";

        if (now.month < birthDate.month ||
            (now.month == birthDate.month && now.day < birthDate.day)) {
          age--;
        }

        if (age < 18) return "You must be at least 18 years old";
        if (age > 100) return "Please enter a valid birthdate";
      } catch (e) {
        return "Invalid date format (use DD/MM/YYYY)";
      }
      break;

    case "Location":
  }

  if (val.length < min) return "Can't be less than $min characters";
  if (val.length > max) return "Can't be more than $max characters";

  return null;
}

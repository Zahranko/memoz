import 'package:flutter/material.dart';
import 'package:gender_picker/gender_picker.dart';
import 'package:gender_picker/source/enums.dart';
import 'package:memzoProject/core/constant/color.dart';

class CustomGenderButton extends StatelessWidget {
  final Function(String) onGenderSelected; // Pass gender to controller

  const CustomGenderButton({super.key, required this.onGenderSelected});

  @override
  Widget build(BuildContext context) {
    return GenderPickerWithImage(
      showOtherGender: false,
      linearGradient: AppColor.primaryGradient,
      verticalAlignedText: false,
      selectedGender: Gender.Male,
      selectedGenderTextStyle: TextStyle(
        color: Color(0xFFC67761),
        fontWeight: FontWeight.bold,
      ),
      unSelectedGenderTextStyle: TextStyle(
        color: Colors.grey[700],
        fontWeight: FontWeight.normal,
      ),
      onChanged: (Gender? gender) {
        if (gender != null) {
          String genderString = gender == Gender.Male ? "Male" : "Female";
          onGenderSelected(genderString);
        }
      },
      equallyAligned: true,
      animationDuration: Duration(milliseconds: 300),
      isCircular: true,
      opacityOfGradient: 0.4,
      padding: const EdgeInsets.all(3),
      size: 60, //default : 40
    );
  }
}

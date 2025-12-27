import 'package:flutter/material.dart';
import 'package:memzoProject/core/constant/color.dart';

class CustomButtonAuth extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  const CustomButtonAuth({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColor.primaryGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.only(top: 10),
        child: MaterialButton(
          padding: EdgeInsets.symmetric(vertical: 12),
          onPressed: onPressed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 14.5),
          ),
        ),
      ),
    );
  }
}

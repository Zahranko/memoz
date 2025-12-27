import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomIconAuth extends StatelessWidget {
  final void Function()? onPressed;
  final IconData iconWidget; // Dynamic icon

  const CustomIconAuth({super.key, required this.iconWidget, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      iconSize: 20,
      icon: FaIcon(iconWidget), // ✅ Use the dynamic icon
    );
  }
}

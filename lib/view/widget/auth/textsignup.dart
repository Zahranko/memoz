import 'package:flutter/material.dart';

class CustomTextSignupOrSignin extends StatelessWidget {
  final String textone;
  final String texttwo;
  final void Function() onTap;
  const CustomTextSignupOrSignin({
    super.key,
    required this.textone,
    required this.texttwo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(textone, style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        InkWell(
          onTap: onTap,
          child: Text(
            texttwo,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFC67761),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class CustomTitleAuth extends StatelessWidget {
  final String title;
  const CustomTitleAuth({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, 
    textAlign: TextAlign.center, 
    style: TextStyle(
      fontWeight: FontWeight.bold, fontSize: 20),);

  }
  

}
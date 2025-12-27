import 'package:flutter/material.dart';

class CustomTextFormAuth extends StatelessWidget {
  final String hinttext;
  final String labeltext;
  final IconData icondata;
  final TextEditingController? mycontroller;
  final String? Function(String?)? valid;
  final bool isNumber;
  final bool? obscureText;
  final void Function()? onTapIon;
  final bool? readonly;
  const CustomTextFormAuth({
    super.key,
    required this.hinttext,
    required this.labeltext,
    required this.mycontroller,
    required this.icondata,
    required this.valid,
    required this.isNumber,
    this.obscureText,
    this.onTapIon,
    this.readonly,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: TextFormField(
          keyboardType:
              isNumber
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
          validator: valid,
          readOnly: readonly == null ? false : readonly!,
          controller: mycontroller,
          obscureText:
              obscureText == null || obscureText == false ? false : true,
          decoration: InputDecoration(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 30,
            ),
            label: Container(
              margin: const EdgeInsets.symmetric(horizontal: 9),
              child: Text(labeltext),
            ),
            hintText: hinttext,
            hintStyle: const TextStyle(fontSize: 14),
            suffixIcon: InkWell(onTap: onTapIon, child: Icon(icondata)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ),
    );
  }
}

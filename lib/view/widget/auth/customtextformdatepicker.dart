import 'package:flutter/material.dart';

class CustomTextFormBirthdateAuth extends StatelessWidget {
  final String hinttext;
  final String labeltext;
  final IconData icondata;
  final TextEditingController? mycontroller;
  final String? Function(String?)? valid;
  final bool isNumber;
  final bool? readonly;
  final void Function(String)? onChange;

  const CustomTextFormBirthdateAuth({
    super.key,
    required this.hinttext,
    required this.labeltext,
    required this.mycontroller,
    required this.icondata,
    required this.valid,
    required this.isNumber,
    this.readonly,
    this.onChange,
  });

  void _openDatePicker(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final formatted =
          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      mycontroller?.text = formatted;
      if (onChange != null) onChange!(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: TextFormField(
          keyboardType: TextInputType.text,
          validator: valid,
          readOnly: true,
          controller: mycontroller,
          onTap: () => _openDatePicker(context),
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
            suffixIcon: Icon(icondata),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ),
    );
  }
}

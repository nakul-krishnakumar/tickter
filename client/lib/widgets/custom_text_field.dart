import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final TextEditingController controller; // 1. Add the controller variable

  const CustomTextField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    required this.controller, // 2. Add it to the constructor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller, // 3. Use the controller here
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }
}
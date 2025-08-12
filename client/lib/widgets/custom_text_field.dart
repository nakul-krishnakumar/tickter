import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool isPassword;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.isPassword = false,
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
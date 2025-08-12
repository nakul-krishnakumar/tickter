import 'package:flutter/material.dart';
import 'package:tickter/widgets/custom_dropdown.dart';
import 'package:tickter/widgets/custom_text_field.dart';

class Student_SignUpScreen extends StatelessWidget {
  const Student_SignUpScreen({super.key});

  @override


  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        },
            icon: Transform.translate(
          offset: const Offset(15,10.0),
          child: Image.asset(
            'assets/images/back_button.webp',
            width: 40,
            height: 40,
          ),
        )),
      ),
      body: SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal:24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Center(
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              )
          ),
          const SizedBox(height: 30),
          CustomTextField(hintText: 'First Name'),
          const SizedBox(height: 16),
          CustomTextField(hintText: 'Last Name'),
          const SizedBox(height: 16),
          CustomTextField(hintText: 'Email Address'),
          const SizedBox(height: 16),
          CustomTextField(hintText: 'Password', isPassword: true),
          const SizedBox(height: 16),
          CustomTextField(hintText: 'Confirm Password', isPassword: true),
          const SizedBox(height: 16),
          CustomDropdown(
            hintText: 'Select Gender',
            items: ['Male', 'Female', 'Other'],
          ),
          const SizedBox(height: 16),
          const CustomDropdown(
            hintText: 'Select Course',
            items: ['DSP - B1', 'DSP - B2', 'QC'],
          ),
        ],
      ),
    ),
      )

    );
  }
}
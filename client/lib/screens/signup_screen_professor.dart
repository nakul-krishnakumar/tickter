import 'package:flutter/material.dart';

// Import your new custom widgets
import 'package:tickter/widgets/custom_text_field.dart';
import 'package:tickter/widgets/custom_dropdown.dart';

class ProfessorSignUpScreen extends StatelessWidget {
  // ... (build method, etc.)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... (your existing AppBar and Scaffold setup)
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ... (your heading)
              const SizedBox(height: 30),

              // Use the new, reusable widgets
              const CustomTextField(hintText: 'First Name'),
              const SizedBox(height: 16),
              const CustomTextField(hintText: 'Last Name'),
              const SizedBox(height: 16),
              const CustomTextField(hintText: 'Email Address'),
              const SizedBox(height: 16),
              const CustomTextField(hintText: 'Password', isPassword: true),
              const SizedBox(height: 16),
              const CustomTextField(
                  hintText: 'Confirm Password', isPassword: true),
              const SizedBox(height: 16),
              const CustomDropdown(
                hintText: 'Select Gender',
                items: ['Male', 'Female', 'Other'],
              ),
              const SizedBox(height: 16),

            ],
          ),
        ),
      ),
    );
  }
}
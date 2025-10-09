import 'package:flutter/material.dart';
import 'package:tickter/widgets/custom_dropdown.dart';
import 'package:tickter/widgets/custom_text_field.dart';

// 1. Convert to StatefulWidget
class ProfessorSignUpScreen extends StatefulWidget {
  const ProfessorSignUpScreen({super.key});

  @override
  State<ProfessorSignUpScreen> createState() => _ProfessorSignUpScreenState();
}

class _ProfessorSignUpScreenState extends State<ProfessorSignUpScreen> {
  // 2. Declare controllers and state variables
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedGender;

  @override
  void dispose() {
    // 3. Dispose controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d0d0d),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Transform.translate(
            offset: const Offset(15, 10.0),
            child: Image.asset(
              'assets/images/back_button.webp',
              width: 40,
              height: 40,
            ),
          ),
        ),
      ),
      // 4. Use a single, correctly structured body with a Form
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Center(
                  child: Text(
                    'Professor Sign Up', // Updated heading
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  controller: _firstNameController,
                  hintText: 'First Name',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _lastNameController,
                  hintText: 'Last Name',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Email Address',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  isPassword: true,
                ),
                const SizedBox(height: 16),
                CustomDropdown(
                  hintText: 'Select Gender',
                  items: const ['Male', 'Female', 'Other'],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    final isValid = _formKey.currentState?.validate() ?? false;
                    if (isValid) {
                      // TODO: Call Professor Supabase sign up function
                      print('First Name: ${_firstNameController.text}');
                      print('Selected Gender: $_selectedGender');
                    }
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      // Use a SingleChildScrollView to prevent overflow when the keyboard appears
      body: SingleChildScrollView(
        child: Container(
          // Ensure the content is at least as tall as the screen
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Padding(
              padding: const EdgeInsets.only(bottom: 70.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. ICON MOVED TO THE TOP
              SizedBox(
                height: 100, // Adjust size as needed
                child: Image.asset('assets/images/login_icon.png'),
              ),
              const SizedBox(height: 24), // Space between icon and card

              // This is your original white card
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 2. NEW BOX FOR FORMS
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16.0), // Spacing between fields

                    // PASSWORD FIELD
                    TextFormField(
                      obscureText: true, // Hides the password
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    ElevatedButton.icon(
                        onPressed: (){

                        },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Image.asset(
                          'assets/images/login_button.png',
                      height: 50,
                      ),
                      label: const Text(
                        '',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
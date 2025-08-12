import 'package:flutter/material.dart';
import 'package:tickter/screens/signup_screen_professor.dart';
import 'signup_screen_student.dart';

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
                    InkWell(
                      onTap: () {
                        // TODO: Add login logic here
                      },
                      // This makes the ripple effect circular, which looks nice for round buttons.
                      // You can remove it for a rectangular ripple.
                      customBorder: const CircleBorder(),
                      child: Image.asset(
                        'assets/images/login_button.png',
                        height: 50,
                      ),
                    ),
                    const SizedBox(height: 5), // Space before the sign up text

                    // VVVV ADD THE SIGN UP TEXT HERE VVVV
                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () {
                              Navigator.push(context,
                                MaterialPageRoute(builder: (context) => const Student_SignUpScreen()),
                              );
                            },
                            child: const Text('Sign up as student'),
                          ),
                          const SizedBox(height: 0),
                          TextButton(
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () {
                              Navigator.push(context,
                                MaterialPageRoute(builder: (context) =>  ProfessorSignUpScreen()),
                              );
                            },
                            child: const Text('Sign up as Professor/staff'),
                          )
                        ],
                      )


                    ),
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
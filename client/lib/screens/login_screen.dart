import 'package:flutter/material.dart';
import 'package:tickter/screens/signup_screen_professor.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';
import 'signup_screen_student.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signIn() async {
    try {
      print(
        'LOGIN: Attempting to sign in with email: ${_emailController.text.trim()}',
      );

      // Use AuthService to sign in
      final authService = AuthService();
      final userProfile = await authService.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      print('🎉 ===== LOGIN SUCCESSFUL! =====');
      print('👤 USER PROFILE: $userProfile');
      print('🎭 USER ROLE: ${userProfile?.role.name.toUpperCase()}');
      print('👑 IS ADMIN: ${userProfile?.isAdmin}');
      print('🏠 NAVIGATING TO HOME SCREEN...');
      print('================================');

      // If the widget is still in the tree, navigate to the home screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (error) {
      print('LOGIN: Sign in failed with error: $error');
      // If sign-in fails, show an error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: ${error.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Container(
          // Ensure the container takes up at least the screen height
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 70.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon
                SizedBox(
                  height: 100,
                  child: Image.asset('assets/images/login_icon.png'),
                ),
                const SizedBox(height: 24),

                // White card for login form
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
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Email Text Field
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16.0),

                      // Password Text Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 32.0),

                      // Login Button
                      InkWell(
                        onTap: _signIn,
                        customBorder: const CircleBorder(),
                        child: Image.asset(
                          'assets/images/login_button.png',
                          height: 50,
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Sign up options
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const StudentSignUpScreen(),
                                  ),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProfessorSignUpScreen(),
                                  ),
                                );
                              },
                              child: const Text('Sign up as Professor/staff'),
                            ),
                          ],
                        ),
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

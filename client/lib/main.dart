import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 1. Import the dotenv package
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';

// 2. Make the main function async to wait for files to load
Future<void> main() async {
  // 3. Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Load the environment variables from the .env file
  await dotenv.load(fileName: ".env");

  // 5. Initialize Supabase using the variables from dotenv
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

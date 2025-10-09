import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 1. Import the dotenv package
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/config_service.dart';

// 2. Make the main function async to wait for files to load
Future<void> main() async {
  // 3. Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Load the environment variables from the .env file
  try {
    await dotenv.load(fileName: ".env");
    print('✅ MAIN: .env file loaded successfully');
  } catch (e) {
    print('⚠️  MAIN: Could not load .env file: $e');
    print('⚠️  MAIN: Using hardcoded fallback values');
  }

  // 4.1. Validate environment variables
  ConfigService.validateEnvironment();

  // 5. Initialize Supabase using the ConfigService
  await Supabase.initialize(
    url: ConfigService.supabaseUrl,
    anonKey: ConfigService.supabaseAnonKey,
  );

  // 6. Initialize AuthService
  print('MAIN: Initializing AuthService...');
  await AuthService().initialize();
  print('MAIN: AuthService initialized successfully');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0d0d0d),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1a1a1a),
          foregroundColor: Colors.white,
        ),
        cardColor: const Color(0xFF2a2a2a),
        primaryColor: Colors.white,
      ),
      home: const LoginScreen(),
    );
  }
}

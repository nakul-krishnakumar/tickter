import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://owqmxdgbcoqqzzasyiuh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im93cW14ZGdiY29xcXp6YXN5aXVoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU1MTM4MDQsImV4cCI6MjA3MTA4OTgwNH0.W2wb3W6inND012yUzkp7wurMvELNkmrpXcX7rGgLW2A',
  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: LoginScreen(),
    );
  }
}
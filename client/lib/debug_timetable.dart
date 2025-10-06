import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Test timetable data
  await testTimetableData();
}

Future<void> testTimetableData() async {
  final supabase = Supabase.instance.client;
  
  try {
    print('🔍 Testing timetable database connection...');
    
    // Check if timetables table exists and has data
    print('\n1. Checking timetables table...');
    final timetables = await supabase.from('timetables').select('*').limit(5);
    print('   Found ${timetables.length} timetables:');
    for (var timetable in timetables) {
      print('   - ID: ${timetable['id']}');
      print('     Semester: ${timetable['semester']}, Course: ${timetable['course_code']}, Batch: ${timetable['batch']}');
    }
    
    // Check if timetable_periods table exists and has data
    print('\n2. Checking timetable_periods table...');
    final periods = await supabase.from('timetable_periods').select('*').limit(5);
    print('   Found ${periods.length} periods:');
    for (var period in periods) {
      print('   - Day: ${period['day']}, Time: ${period['start_time']}-${period['end_time']}');
      print('     Subject: ${period['subject_name']} (${period['subject_code']})');
    }
    
    // Test specific query that the app uses
    print('\n3. Testing specific query (Semester 5, CSE, Batch A, 2024-25)...');
    final specificTimetable = await supabase
        .from('timetables')
        .select('*')
        .eq('semester', 5)
        .eq('course_code', 'CSE')
        .eq('batch', 'A')
        .eq('academic_year', '2024-25')
        .limit(1);
        
    if (specificTimetable.isEmpty) {
      print('   ❌ No timetable found for these parameters');
      print('   💡 You need to add a timetable with these exact values:');
      print('      - semester: 5');
      print('      - course_code: CSE');
      print('      - batch: A');
      print('      - academic_year: 2024-25');
    } else {
      print('   ✅ Timetable found: ${specificTimetable.first['id']}');
      
      // Check periods for this timetable
      final timetableId = specificTimetable.first['id'];
      final periodsForTimetable = await supabase
          .from('timetable_periods')
          .select('*')
          .eq('timetable_id', timetableId);
          
      print('   📅 Found ${periodsForTimetable.length} periods for this timetable');
    }
    
  } catch (error) {
    print('❌ Error testing database: $error');
  }
}
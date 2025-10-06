// Simple test to check Supabase timetable data without running the full Flutter app
import 'dart:convert';
import 'dart:io';

void main() async {
  // Read environment variables manually
  final envFile = File('/home/nakul/devfiles/PROJECTS/tickter/client/.env');
  final envContent = await envFile.readAsString();
  
  String? supabaseUrl;
  String? supabaseKey;
  
  for (final line in envContent.split('\n')) {
    if (line.startsWith('SUPABASE_URL=')) {
      supabaseUrl = line.split('=')[1].replaceAll('"', '');
    } else if (line.startsWith('SUPABASE_ANON_KEY=')) {
      supabaseKey = line.split('=')[1].replaceAll('"', '');
    }
  }
  
  if (supabaseUrl == null || supabaseKey == null) {
    print('❌ Could not read Supabase credentials from .env file');
    return;
  }
  
  print('🔍 Testing Supabase connection...');
  print('URL: $supabaseUrl');
  
  // Test basic connection
  final client = HttpClient();
  
  try {
    // Test 1: Check if timetables table exists
    print('\n1. Checking timetables table...');
    final timetablesRequest = await client.getUrl(
      Uri.parse('$supabaseUrl/rest/v1/timetables?select=*&limit=5')
    );
    timetablesRequest.headers.add('apikey', supabaseKey);
    timetablesRequest.headers.add('Authorization', 'Bearer $supabaseKey');
    
    final timetablesResponse = await timetablesRequest.close();
    final timetablesData = await timetablesResponse.transform(utf8.decoder).join();
    
    if (timetablesResponse.statusCode == 200) {
      final timetables = jsonDecode(timetablesData) as List;
      print('✅ Found ${timetables.length} timetables');
      for (var timetable in timetables) {
        print('   - Semester: ${timetable['semester']}, Course: ${timetable['course_code']}, Batch: ${timetable['batch']}, Year: ${timetable['academic_year']}');
      }
    } else {
      print('❌ Error: ${timetablesResponse.statusCode} - $timetablesData');
    }
    
    // Test 2: Check if timetable_periods table exists
    print('\n2. Checking timetable_periods table...');
    final periodsRequest = await client.getUrl(
      Uri.parse('$supabaseUrl/rest/v1/timetable_periods?select=*&limit=5')
    );
    periodsRequest.headers.add('apikey', supabaseKey);
    periodsRequest.headers.add('Authorization', 'Bearer $supabaseKey');
    
    final periodsResponse = await periodsRequest.close();
    final periodsData = await periodsResponse.transform(utf8.decoder).join();
    
    if (periodsResponse.statusCode == 200) {
      final periods = jsonDecode(periodsData) as List;
      print('✅ Found ${periods.length} periods');
      for (var period in periods) {
        print('   - ${period['day']}: ${period['start_time']}-${period['end_time']} | ${period['subject_name']}');
      }
    } else {
      print('❌ Error: ${periodsResponse.statusCode} - $periodsData');
    }
    
    // Test 3: Check specific query (Semester 5, CSE, Batch 1, 2025)
    print('\n3. Testing specific query (Semester 5, CSE, Batch 1, 2025)...');
    final specificRequest = await client.getUrl(
      Uri.parse('$supabaseUrl/rest/v1/timetables?semester=eq.5&course_code=eq.CSE&batch=eq.1&academic_year=eq.2025')
    );
    specificRequest.headers.add('apikey', supabaseKey);
    specificRequest.headers.add('Authorization', 'Bearer $supabaseKey');
    
    final specificResponse = await specificRequest.close();
    final specificData = await specificResponse.transform(utf8.decoder).join();
    
    if (specificResponse.statusCode == 200) {
      final results = jsonDecode(specificData) as List;
      if (results.isEmpty) {
        print('❌ No timetable found for these specific parameters');
        print('💡 You need to add a timetable row with:');
        print('   - semester: 5');
        print('   - course_code: CSE');  
        print('   - batch: 1');
        print('   - academic_year: 2025');
      } else {
        print('✅ Found matching timetable: ${results.first['id']}');
      }
    } else {
      print('❌ Error: ${specificResponse.statusCode} - $specificData');
    }
    
  } catch (error) {
    print('❌ Connection error: $error');
  } finally {
    client.close();
  }
}
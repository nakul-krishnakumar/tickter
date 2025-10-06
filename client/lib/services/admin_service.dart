import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:typed_data';

class AdminService {
  static const String baseUrl = 'http://localhost:8080/api/v1/admin';

  /// Upload timetable PDF
  static Future<Map<String, dynamic>> uploadTimetable(
    PlatformFile pdfFile,
  ) async {
    try {
      print('🔄 AdminService: Uploading timetable PDF...');

      final uri = Uri.parse('$baseUrl/upload-timetable');
      final request = http.MultipartRequest('POST', uri);

      // Add the PDF file using bytes (works on web and mobile)
      Uint8List fileBytes;
      if (pdfFile.bytes != null) {
        // Web platform - use bytes directly
        fileBytes = pdfFile.bytes!;
      } else {
        // Mobile platform - read from path
        throw Exception(
          'File bytes not available. This should not happen on web.',
        );
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'timetable', // Field name expected by backend
          fileBytes,
          filename: pdfFile.name,
        ),
      );

      print('📤 AdminService: Sending timetable upload request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print(
        '📥 AdminService: Timetable upload response status: ${response.statusCode}',
      );
      print(
        '📥 AdminService: Timetable upload response body: ${response.body}',
      );

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          print('✅ AdminService: Timetable uploaded successfully');
          return data;
        } catch (parseError) {
          print('❌ AdminService: JSON parsing error - $parseError');
          throw Exception('Server response parsing failed: $parseError');
        }
      } else {
        try {
          final error = json.decode(response.body);
          throw Exception(
            error['message'] ??
                'Failed to upload timetable (${response.statusCode})',
          );
        } catch (parseError) {
          throw Exception(
            'Upload failed with status ${response.statusCode}: ${response.body}',
          );
        }
      }
    } catch (e) {
      print('❌ AdminService: Timetable upload error - $e');
      rethrow;
    }
  }

  /// Upload calendar PDF
  static Future<Map<String, dynamic>> uploadCalendar(
    PlatformFile pdfFile,
  ) async {
    try {
      print('🔄 AdminService: Uploading calendar PDF...');

      final uri = Uri.parse('$baseUrl/upload-calendar');
      final request = http.MultipartRequest('POST', uri);

      // Add the PDF file using bytes (works on web and mobile)
      Uint8List fileBytes;
      if (pdfFile.bytes != null) {
        // Web platform - use bytes directly
        fileBytes = pdfFile.bytes!;
      } else {
        // Mobile platform - read from path
        throw Exception(
          'File bytes not available. This should not happen on web.',
        );
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'calendar', // Field name expected by backend
          fileBytes,
          filename: pdfFile.name,
        ),
      );

      print('📤 AdminService: Sending calendar upload request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print(
        '📥 AdminService: Calendar upload response status: ${response.statusCode}',
      );
      print('📥 AdminService: Calendar upload response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          print('✅ AdminService: Calendar uploaded successfully');
          return data;
        } catch (parseError) {
          print('❌ AdminService: JSON parsing error - $parseError');
          throw Exception('Server response parsing failed: $parseError');
        }
      } else {
        try {
          final error = json.decode(response.body);
          throw Exception(
            error['message'] ??
                'Failed to upload calendar (${response.statusCode})',
          );
        } catch (parseError) {
          throw Exception(
            'Upload failed with status ${response.statusCode}: ${response.body}',
          );
        }
      }
    } catch (e) {
      print('❌ AdminService: Calendar upload error - $e');
      rethrow;
    }
  }
}

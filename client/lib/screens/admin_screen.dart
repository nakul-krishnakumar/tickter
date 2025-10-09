import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../services/admin_service.dart';
import '../widgets/role_guard.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  PlatformFile? _selectedTimetableFile;
  PlatformFile? _selectedCalendarFile;
  bool _isUploadingTimetable = false;
  bool _isUploadingCalendar = false;
  String? _timetableResult;
  String? _calendarResult;

  /// Pick a PDF file for timetable
  Future<void> _pickTimetableFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: true, // Important for web - ensures bytes are loaded
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedTimetableFile = result.files.first;
          _timetableResult = null; // Clear previous result
        });
        print('📄 Selected timetable file: ${_selectedTimetableFile!.name}');
      }
    } catch (e) {
      _showErrorSnackBar('Error selecting timetable file: $e');
    }
  }

  /// Pick a PDF file for calendar
  Future<void> _pickCalendarFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: true, // Important for web - ensures bytes are loaded
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedCalendarFile = result.files.first;
          _calendarResult = null; // Clear previous result
        });
        print('📄 Selected calendar file: ${_selectedCalendarFile!.name}');
      }
    } catch (e) {
      _showErrorSnackBar('Error selecting calendar file: $e');
    }
  }

  /// Upload timetable PDF
  Future<void> _uploadTimetable() async {
    if (_selectedTimetableFile == null) {
      _showErrorSnackBar('Please select a timetable PDF first');
      return;
    }

    setState(() {
      _isUploadingTimetable = true;
      _timetableResult = null;
    });

    try {
      final response = await AdminService.uploadTimetable(
        _selectedTimetableFile!,
      );

      setState(() {
        _timetableResult =
            'Success: ${response['message']}\n'
            'Processed ${response['data']['totalTimetables']} timetables';
      });

      _showSuccessSnackBar('Timetable uploaded successfully!');
    } catch (e) {
      setState(() {
        _timetableResult = 'Error: $e';
      });
      _showErrorSnackBar('Failed to upload timetable: $e');
    } finally {
      setState(() {
        _isUploadingTimetable = false;
      });
    }
  }

  /// Upload calendar PDF
  Future<void> _uploadCalendar() async {
    if (_selectedCalendarFile == null) {
      _showErrorSnackBar('Please select a calendar PDF first');
      return;
    }

    setState(() {
      _isUploadingCalendar = true;
      _calendarResult = null;
    });

    try {
      final response = await AdminService.uploadCalendar(
        _selectedCalendarFile!,
      );

      setState(() {
        _calendarResult =
            'Success: ${response['message']}\n'
            'Processed ${response['data']['totalEvents']} events';
      });

      _showSuccessSnackBar('Calendar uploaded successfully!');
    } catch (e) {
      setState(() {
        _calendarResult = 'Error: $e';
      });
      _showErrorSnackBar('Failed to upload calendar: $e');
    } finally {
      setState(() {
        _isUploadingCalendar = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminOnlyWidget(
      fallback: Scaffold(
        backgroundColor: const Color(0xFF0d0d0d),
        appBar: AppBar(
          title: const Text('Access Denied'),
          backgroundColor: const Color(0xFF1a1a1a),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'You need admin privileges to access this page.',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF0d0d0d),
        appBar: AppBar(
          title: const Text(
            'Admin Panel',
            style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
          backgroundColor: const Color(0xFF1a1a1a),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Upload Documents',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload PDF files to automatically extract and process data',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              // Timetable Upload Section
              _buildUploadSection(
                title: 'Upload Timetable',
                description:
                    'Upload a PDF containing class timetables for automatic processing',
                icon: Icons.schedule_rounded,
                color: Colors.blue,
                selectedFile: _selectedTimetableFile,
                isUploading: _isUploadingTimetable,
                result: _timetableResult,
                onPickFile: _pickTimetableFile,
                onUpload: _uploadTimetable,
              ),

              const SizedBox(height: 24),

              // Calendar Upload Section
              _buildUploadSection(
                title: 'Upload Academic Calendar',
                description:
                    'Upload a PDF containing academic calendar events for automatic processing',
                icon: Icons.calendar_today_rounded,
                color: Colors.green,
                selectedFile: _selectedCalendarFile,
                isUploading: _isUploadingCalendar,
                result: _calendarResult,
                onPickFile: _pickCalendarFile,
                onUpload: _uploadCalendar,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadSection({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onPickFile,
    required VoidCallback onUpload,
    required PlatformFile? selectedFile,
    required bool isUploading,
    required String? result,
  }) {
    return Card(
      elevation: 2,
      color: const Color(0xFF2a2a2a),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // File Selection
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
                color: selectedFile != null
                    ? color.withOpacity(0.05)
                    : Colors.grey[50],
              ),
              child: Column(
                children: [
                  Icon(
                    selectedFile != null
                        ? Icons.check_circle
                        : Icons.upload_file,
                    size: 48,
                    color: selectedFile != null ? color : Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    selectedFile != null
                        ? 'Selected: ${selectedFile.name}'
                        : 'Select a PDF file to upload',
                    style: TextStyle(
                      fontSize: 14,
                      color: selectedFile != null ? color : Colors.grey[600],
                      fontWeight: selectedFile != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPickFile,
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Select PDF'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: color),
                      foregroundColor: color,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: selectedFile != null && !isUploading
                        ? onUpload
                        : null,
                    icon: isUploading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: Text(isUploading ? 'Uploading...' : 'Upload'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            // Result Display
            if (result != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: result.startsWith('Success')
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: result.startsWith('Success')
                        ? Colors.green.withOpacity(0.3)
                        : Colors.red.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  result,
                  style: TextStyle(
                    fontSize: 14,
                    color: result.startsWith('Success')
                        ? Colors.green[800]
                        : Colors.red[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

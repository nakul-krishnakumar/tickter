import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final _captionController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final status = await Permission.photos.request();

    if (status.isGranted) {
      final picker = ImagePicker();
      final XFile? imageFile =
      await picker.pickImage(source: ImageSource.gallery);
      if (imageFile != null) {
        setState(() {
          _selectedImage = File(imageFile.path);
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Library permission required to select an image')));
      }
    }
  }

  Future<void> _createPost() async {
    final caption = _captionController.text.trim();
    if (caption.isEmpty && _selectedImage == null) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Uploading..."),
          ],
        ),
      ),
    );

    try {
      // VVVV  CONNECT TO YOUR LOCAL SERVER HERE  VVVV
      // Use 10.0.2.2 for the Android emulator to connect to your computer's localhost.
      final uri = Uri.parse('http://10.0.2.2:8081/api/v1/posts/upload');
      final request = http.MultipartRequest('POST', uri);

      request.fields['title'] = 'Default Title';
      request.fields['content'] = caption;
      request.fields['author'] = Supabase.instance.client.auth.currentUser!.id;

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'images',
          _selectedImage!.path,
        ));
      }

      final response = await request.send();
      Navigator.pop(context); // Dismiss the loading dialog

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post created successfully!')),
          );
          Navigator.pop(context); // Go back to the home screen
        }
      } else {
        final responseBody = await response.stream.bytesToString();
        final errorJson = jsonDecode(responseBody);
        throw Exception('Failed: ${errorJson['message']}');
      }
    } catch (e) {
      if (Navigator.of(context).canPop()) {
        Navigator.pop(context); // Dismiss loading dialog on error
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text('Error: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            InkWell(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                )
                    : const Center(
                  child: Icon(Icons.add_a_photo,
                      size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _captionController,
              decoration: const InputDecoration(
                hintText: 'Write a caption...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _createPost,
              child: const Text('Create Post'),
            ),
          ],
        ),
      ),
    );
  }
}
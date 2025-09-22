import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost>{
  final _captionController = TextEditingController();
  File? _selectedImage;
  bool isLoading = false;

  Future<void> _pickImage() async{
    final status = await Permission.photos.request();

    if(status.isGranted){
      final picker = ImagePicker();
      final XFile? imageFile = await picker.pickImage(source: ImageSource.gallery);
      if(imageFile != null){
        setState((){
          _selectedImage = File(imageFile.path);
        }
        );
      }
    }else{
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Library permission required to select an image'))
        );
      }
    }
  }

  Future<void> _createPost() async{
    final caption = _captionController.text.trim();
    if(caption.isEmpty && _selectedImage == null){
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      String? imageUrl;

      if (_selectedImage != null) {
        final fileName = '${DateTime
            .now()
            .millisecondsSinceEpoch}.png';
        await Supabase.instance.client.storage
            .from('posts_media')
            .upload(fileName, _selectedImage!);

        imageUrl = Supabase.instance.client.storage
            .from('posts_media')
            .getPublicUrl(fileName);
      }
      await Supabase.instance.client.from('posts').insert({
        'user_id': Supabase.instance.client.auth.currentUser!.id,
        'content': caption.isNotEmpty ? caption : null,
        'photo_url': imageUrl,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created succesfully')),

        );
        Navigator.pop(context);
      }
    }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error Creating Post: $e'),
              backgroundColor: Colors.red,
            ),
        );
      }


    setState((){
      isLoading = false;
    });
  }
  @override
  void dispose(){
    _captionController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // Scaffold provides the basic Material Design visual layout structure.
    return Scaffold(
      // AppBar is the top bar of the screen.
      appBar: AppBar(
        title: const Text('Create New Post'),
        // 'actions' are widgets displayed after the title. Here we have the 'Post' button.
        actions: [
          TextButton(
            // The button is disabled while loading to prevent multiple submissions.
            onPressed: isLoading ? null : _createPost,
            // Show a loading circle if _isLoading is true, otherwise show the 'Post' text.
            child: isLoading
                ? const SizedBox(
                width: 20, height: 20, child: CircularProgressIndicator())
                : const Text('Post'),
          ),
        ],
      ),
      // The body is the primary content of the Scaffold.
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // A Column to arrange the UI elements vertically.
        child: Column(
          children: [
            // An InkWell makes its child tappable. Tapping it will call _pickImage.
            InkWell(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                // This is a conditional UI (ternary operator).
                // If an image is selected, show it. Otherwise, show an 'add photo' icon.
                child: _selectedImage != null
                    ? ClipRRect( // ClipRRect ensures the image has the same rounded corners as the container.
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                )
                    : const Center(
                  child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // A TextFormField for multi-line text input for the caption.
            TextFormField(
              controller: _captionController,
              decoration: const InputDecoration(
                hintText: 'Write a caption...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5, // Allows the text field to expand up to 5 lines.
            ),
          ],
        ),
      ),
    );
  }
}
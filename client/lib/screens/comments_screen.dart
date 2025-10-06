import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _commentController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    _commentsFuture = _fetchComments();
  }

  Future<List<Map<String, dynamic>>> _fetchComments() async {
    final response = await Supabase.instance.client
        .from('comments')
        .select('*, profiles(first_name, last_name)') // Join with profiles
        .eq('post_id', widget.postId)
        .order('created_at');
    return response as List<Map<String, dynamic>>;
  }

  /// Adds error handling to the comment submission process.
  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) {
      return;
    }

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      await Supabase.instance.client.from('comments').insert({
        'post_id': widget.postId,
        'user_id': userId,
        'content': content,
      });

      _commentController.clear();
      setState(() {
        // Refresh the comments after adding a new one
        _commentsFuture = _fetchComments();
      });
    } catch (error) {
      // If an error occurs, show it in a SnackBar.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add comment: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comments')),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No comments yet. Be the first!'));
                }
                final comments = snapshot.data!;
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final profile = comment['profiles'];
                    final firstName = profile?['first_name'] ?? '';
                    final lastName = profile?['last_name'] ?? '';
                    final fullName = '$firstName $lastName'.trim();
                    final username = fullName.isNotEmpty ? fullName : 'Anonymous';

                    return ListTile(
                      title: Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(comment['content']),
                    );
                  },
                );
              },
            ),
          ),
          // This is the UI for adding a new comment.
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


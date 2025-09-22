import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'create_post.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // A list to hold the posts and a boolean to track loading state.
  List<Map<String, dynamic>>? _posts;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Fetch the posts when the screen is first loaded.
    _fetchPosts();
  }

  /// Fetches posts from the Supabase 'posts' table.
  Future<void> _fetchPosts() async {
    try {
      final response = await Supabase.instance.client
          .from('posts')
          .select()
          .order('created_at', ascending: false); // Show newest posts first

      setState(() {
        _posts = response as List<Map<String, dynamic>>;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  /// Handles the pull-to-refresh action.
  Future<void> _handleRefresh() async {
    await _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : RefreshIndicator(
        onRefresh: _handleRefresh, // Link to the refresh function
        child: ListView.builder(
          itemCount: _posts?.length ?? 0,
          itemBuilder: (context, index) {
            final post = _posts![index];
            return PostCard(post: post);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePost()),
          ).then((_) {
            // Refresh the feed after a new post is created
            _fetchPosts();
          });
        },
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/Create_icon.png',
          ),
        ),
      ),
    );
  }
}

/// A custom widget to display a single post in a card format.
class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final String? content = post['content'];
    final String? photoUrl = post['photo_url'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (photoUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                photoUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    heightFactor: 4,
                    child: CircularProgressIndicator(),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    heightFactor: 4,
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              ),
            ),
          if (content != null)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(content),
            ),
        ],
      ),
    );
  }
}
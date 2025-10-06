import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'comments_screen.dart';
import 'create_post.dart';
import 'calendar_screen_student.dart';
import 'login_screen.dart'; // Import for logout navigation
import 'profile_screen.dart'; // Import for profile navigation

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>>? _posts;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      final response = await Supabase.instance.client
          .from('posts')
          .select('*, profiles(first_name, last_name)') // Also fetch author name
          .order('created_at', ascending: false);
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

  Future<void> _handleRefresh() async {
    await _fetchPosts();
  }

  /// Handles the sign out logic
  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (error) {
      // Handle potential errors, e.g., show a snackbar
    } finally {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false, // This removes all previous routes
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Feed'),
        // Add the three icon buttons to the actions list
        actions: [
          // 1. Logout Button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Logout',
          ),
          // 2. Calendar Button
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarScreen()),
              );
            },
            tooltip: 'Calendar',
          ),
          // 3. Profile Button
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            tooltip: 'Profile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : RefreshIndicator(
        onRefresh: _handleRefresh,
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

/// PostCard is now a StatefulWidget to manage its own state (likes).
class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isLiked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchLikeStatus();
  }

  /// Fetches the like count and checks if the current user has liked this post.
  Future<void> _fetchLikeStatus() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser!.id;
    final postId = widget.post['id'];

    final count = await supabase
        .from('likes')
        .count(CountOption.exact)
        .eq('post_id', postId);

    final userLikeResponse = await supabase
        .from('likes')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', userId)
        .limit(1);

    if (mounted) {
      setState(() {
        _likeCount = count;
        _isLiked = userLikeResponse.isNotEmpty;
      });
    }
  }

  /// Handles the like/unlike action when the button is tapped.
  Future<void> _toggleLike() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser!.id;
    final postId = widget.post['id'];

    if (_isLiked) {
      await supabase.from('likes').delete().match({'post_id': postId, 'user_id': userId});
      setState(() {
        _isLiked = false;
        _likeCount--;
      });
    } else {
      await supabase.from('likes').insert({'post_id': postId, 'user_id': userId});
      setState(() {
        _isLiked = true;
        _likeCount++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? content = widget.post['content'];
    final String? photoUrl = widget.post['photo_url'];
    final String postId = widget.post['id'].toString();

    final profile = widget.post['profiles'];
    final firstName = profile?['first_name'] ?? '';
    final lastName = profile?['last_name'] ?? '';
    final authorName = '$firstName $lastName'.trim();


    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Text(
              authorName.isNotEmpty ? authorName : 'Anonymous',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (photoUrl != null)
            Image.network(
              photoUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(heightFactor: 4, child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(heightFactor: 4, child: Icon(Icons.broken_image, color: Colors.grey));
              },
            ),
          if (content != null)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(content),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red : Colors.grey,
                      ),
                      onPressed: _toggleLike,
                    ),
                    Text('$_likeCount'),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.comment_outlined, color: Colors.grey),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentsScreen(postId: postId),
                      ),
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}


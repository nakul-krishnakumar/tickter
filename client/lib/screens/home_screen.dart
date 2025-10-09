import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../services/auth_service.dart';
import 'calendar_screen_student.dart';
import 'comments_screen.dart';
import 'create_post.dart';
import 'login_screen.dart'; // Import for logout navigation
import 'profile_screen.dart'; // Import for profile navigation
import 'search_screen.dart'; // Import the search screen

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
          .select('*, profiles(first_name, last_name)')
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _posts = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          'Home',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        // Updated and reordered actions
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CalendarScreen()),
            ),
            tooltip: 'Calendar',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            ),
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            ),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePost()),
          ).then((_) => _fetchPosts());
        },
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/Create_icon.png'),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }
    if (_posts == null || _posts!.isEmpty) {
      return const Center(child: Text('No posts yet. Be the first to share!'));
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.separated(
        itemCount: _posts!.length,
        itemBuilder: (context, index) {
          final post = _posts![index];
          return PostCard(post: post);
        },
        separatorBuilder: (context, index) =>
            const Divider(height: 1, thickness: 1, color: Color(0xFF4a4a4a)),
      ),
    );
  }
}

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

  Future<void> _fetchLikeStatus() async {
    if (!mounted) return;
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final postId = widget.post['id'];

    try {
      final countRes = await supabase
          .from('likes')
          .count(CountOption.exact)
          .eq('post_id', postId);
      final userLikeRes = await supabase
          .from('likes')
          .select('id')
          .eq('post_id', postId)
          .eq('user_id', userId)
          .limit(1);

      if (mounted) {
        setState(() {
          _likeCount = countRes;
          _isLiked = userLikeRes.isNotEmpty;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _toggleLike() async {
    if (!mounted) return;
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final postId = widget.post['id'];

    setState(() {
      if (_isLiked) {
        _isLiked = false;
        _likeCount--;
        supabase
            .from('likes')
            .delete()
            .match({'post_id': postId, 'user_id': userId})
            .catchError((_) {
              if (mounted) {
                setState(() {
                  _isLiked = true;
                  _likeCount++;
                });
              }
            });
      } else {
        _isLiked = true;
        _likeCount++;
        supabase
            .from('likes')
            .insert({'post_id': postId, 'user_id': userId})
            .catchError((_) {
              if (mounted) {
                setState(() {
                  _isLiked = false;
                  _likeCount--;
                });
              }
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.post['profiles'];
    final firstName = profile?['first_name'] ?? '';
    final lastName = profile?['last_name'] ?? '';
    final authorName = '$firstName $lastName'.trim().isEmpty
        ? 'Anonymous'
        : '$firstName $lastName'.trim();

    final createdAt = DateTime.parse(widget.post['created_at']);
    final timeAgo = timeago.format(createdAt);

    final String? content = widget.post['content'];
    final String? photoUrl = widget.post['photo_url'];
    final String postId = widget.post['id'].toString();

    return Container(
      color: const Color(0xFF2a2a2a),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPostHeader(authorName, timeAgo),
                if (content != null && content.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                    child: Text(
                      content,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.3,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (photoUrl != null) _buildPostImage(photoUrl),
                _buildActionButtons(postId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostHeader(String authorName, String timeAgo) {
    return Row(
      children: [
        Text(
          authorName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Text(timeAgo, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildPostImage(String photoUrl) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.network(
          photoUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : const Center(child: CircularProgressIndicator()),
          errorBuilder: (context, error, stack) =>
              const Icon(Icons.broken_image, color: Colors.grey, size: 40),
        ),
      ),
    );
  }

  Widget _buildActionButtons(String postId) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(
            icon: Icons.comment_outlined,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommentsScreen(postId: postId),
              ),
            ),
          ),
          _buildActionButton(
            icon: _isLiked ? Icons.favorite : Icons.favorite_border,
            text: _likeCount > 0 ? '$_likeCount' : '',
            color: _isLiked ? Colors.red : Colors.grey,
            onPressed: _toggleLike,
          ),
          _buildActionButton(icon: Icons.share_outlined, onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    String text = '',
    Color? color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey),
          if (text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Text(
                text,
                style: TextStyle(color: color ?? Colors.grey, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }
}

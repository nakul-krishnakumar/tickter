import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart'; // Import for logout navigation

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final Future<Map<String, dynamic>> _profileFuture;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchProfile();
  }

  /// Fetches the profile for the currently logged-in user from the database.
  Future<Map<String, dynamic>> _fetchProfile() async {
    final userId = _supabase.auth.currentUser!.id;
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return response;
  }

  /// Signs the user out and navigates back to the login screen.
  Future<void> _signOut() async {
    try {
      await _supabase.auth.signOut();
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
        title: const Text('My Profile'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Profile not found.'));
          }

          final profile = snapshot.data!;
          final firstName = profile['first_name'] ?? 'N/A';
          final lastName = profile['last_name'] ?? 'N/A';
          final rollNumber = profile['roll_number'] ?? 'N/A';
          final batch = profile['batch'] ?? 'N/A';
          final elective = profile['elective'] ?? 'N/A';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      const Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.black12,
                          child:
                          Icon(Icons.person, size: 60, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildProfileInfoTile(
                        icon: Icons.person_outline,
                        title: 'Name',
                        subtitle: '$firstName $lastName',
                      ),
                      const Divider(),
                      _buildProfileInfoTile(
                        icon: Icons.confirmation_number_outlined,
                        title: 'Roll Number',
                        subtitle: rollNumber,
                      ),
                      const Divider(),
                      _buildProfileInfoTile(
                        icon: Icons.group_outlined,
                        title: 'Batch',
                        subtitle: batch,
                      ),
                      const Divider(),
                      _buildProfileInfoTile(
                        icon: Icons.book_outlined,
                        title: 'Elective',
                        subtitle: elective,
                      ),
                    ],
                  ),
                ),
                // Logout Button at the bottom
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _signOut,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}


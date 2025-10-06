import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  UserProfile? _currentUser;
  bool _isLoading = false;

  // Getters
  UserProfile? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn =>
      _currentUser != null && _supabase.auth.currentUser != null;

  // Initialize auth service
  Future<void> initialize() async {
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session?.user != null) {
        await _loadUserProfile(session!.user.id);
      } else if (event == AuthChangeEvent.signedOut) {
        _clearUserData();
      }
    });

    // Check if user is already logged in
    final currentSession = _supabase.auth.currentSession;
    if (currentSession?.user != null) {
      await _loadUserProfile(currentSession!.user.id);
    }
  }

  // Sign in with email and password
  Future<UserProfile?> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);

      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserProfile(response.user!.id);
        return _currentUser;
      }

      throw Exception('Sign in failed: No user data received');
    } catch (error) {
      print('AuthService: Sign in error - $error');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _supabase.auth.signOut();
      _clearUserData();
    } catch (error) {
      print('AuthService: Sign out error - $error');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Load user profile from database
  Future<void> _loadUserProfile(String userId) async {
    try {
      print('AuthService: Loading user profile for ID: $userId');
      
      // Get from profiles table (corrected table name)
      final profileResponse = await _supabase
          .from('profiles')
          .select('*')
          .eq('id', userId)
          .maybeSingle();

      print('AuthService: Profile response: $profileResponse');

      if (profileResponse != null) {
        _currentUser = UserProfile.fromJson(profileResponse);
        print('AuthService: User loaded - Role: ${_currentUser?.role.name}, Name: ${_currentUser?.fullName}');
      } else {
        print('AuthService: No profile found in database, creating default profile');
        // Fallback: create basic profile from auth user
        final authUser = _supabase.auth.currentUser;
        if (authUser != null) {
          _currentUser = UserProfile(
            id: authUser.id,
            role: UserRole.student, // Default role
            firstName: authUser.userMetadata?['first_name'] as String?,
            lastName: authUser.userMetadata?['last_name'] as String?,
          );
          print('AuthService: Created default profile - Role: ${_currentUser?.role.name}');
        }
      }
      
      notifyListeners();
    } catch (error) {
      print('AuthService: Error loading user profile - $error');
      // Create minimal profile if database fetch fails
      final authUser = _supabase.auth.currentUser;
      if (authUser != null) {
        _currentUser = UserProfile(
          id: authUser.id,
          role: UserRole.student,
        );
        print('AuthService: Created minimal profile due to error - Role: ${_currentUser?.role.name}');
        notifyListeners();
      }
    }
  }  // Update user profile
  Future<void> updateUserProfile(UserProfile updatedProfile) async {
    try {
      _setLoading(true);

      await _supabase
          .from('user_profiles')
          .update(updatedProfile.toJson())
          .eq('id', updatedProfile.id);

      _currentUser = updatedProfile;
      notifyListeners();
    } catch (error) {
      print('AuthService: Error updating user profile - $error');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Create user profile (for new registrations)
  Future<UserProfile> createUserProfile({
    required String userId,
    required String email,
    required UserRole role,
    String? fullName,
    int? semester,
    String? courseCode,
    String? batch,
    String? department,
  }) async {
    try {
      final profileData = {
        'id': userId,
        'email': email,
        'role': role.name,
        'full_name': fullName,
        'semester': semester,
        'course_code': courseCode,
        'batch': batch,
        'department': department,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('user_profiles').insert(profileData);

      final newProfile = UserProfile.fromJson(profileData);
      _currentUser = newProfile;
      notifyListeners();

      return newProfile;
    } catch (error) {
      print('AuthService: Error creating user profile - $error');
      rethrow;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearUserData() {
    _currentUser = null;
    notifyListeners();
  }

  // Role-based helper methods
  bool hasRole(UserRole role) {
    return _currentUser?.role == role;
  }

  bool canAccess(List<UserRole> allowedRoles) {
    return _currentUser != null && allowedRoles.contains(_currentUser!.role);
  }
}

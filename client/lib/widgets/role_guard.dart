import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';

class RoleGuard extends StatelessWidget {
  final List<UserRole> allowedRoles;
  final Widget child;
  final Widget? fallback;
  final bool showFallbackForNoAccess;

  const RoleGuard({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
    this.showFallbackForNoAccess = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthService(),
      builder: (context, _) {
        final authService = AuthService();
        final currentUser = authService.currentUser;

        print('🔒 ROLE_GUARD: Required roles: $allowedRoles');
        print('👤 ROLE_GUARD: Current user: $currentUser');
        print('🎭 ROLE_GUARD: Current user role: ${currentUser?.role}');

        // If no user is logged in, show fallback or empty container
        if (currentUser == null) {
          print('❌ ROLE_GUARD: No user logged in, showing fallback');
          return fallback ??
              (showFallbackForNoAccess ? const SizedBox.shrink() : child);
        }

        // If user has required role, show child
        if (allowedRoles.contains(currentUser.role)) {
          print('✅ ROLE_GUARD: User has required role, showing child');
          return child;
        }

        // User doesn't have required role
        print('🚫 ROLE_GUARD: User does not have required role, showing fallback');
        return fallback ??
            (showFallbackForNoAccess ? const SizedBox.shrink() : child);
      },
    );
  }
}

// Convenience widgets for specific roles
class StudentOnlyWidget extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const StudentOnlyWidget({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      allowedRoles: const [UserRole.student],
      fallback: fallback,
      child: child,
    );
  }
}

class ProfessorOnlyWidget extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const ProfessorOnlyWidget({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      allowedRoles: const [UserRole.professor],
      fallback: fallback,
      child: child,
    );
  }
}

class AdminOnlyWidget extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const AdminOnlyWidget({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context) {
    // Debug: Print admin access check
    final authService = AuthService();
    final currentUser = authService.currentUser;
    print('🔑 ADMIN_WIDGET: Current user: $currentUser');
    print('🎭 ADMIN_WIDGET: User role: ${currentUser?.role.name}');
    print('👑 ADMIN_WIDGET: Is admin: ${currentUser?.isAdmin}');
    print('🎯 ADMIN_WIDGET: Should show widget: ${currentUser?.isAdmin == true}');
    
    return RoleGuard(
      allowedRoles: const [UserRole.admin],
      fallback: fallback,
      child: child,
    );
  }
}

class FacultyWidget extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const FacultyWidget({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      allowedRoles: const [UserRole.professor, UserRole.admin],
      fallback: fallback,
      child: child,
    );
  }
}

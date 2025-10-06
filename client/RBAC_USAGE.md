# Role-Based Access Control (RBAC) Usage Guide

## Overview

This system provides comprehensive role-based access control for your Flutter app with three user roles: `student`, `professor`, and `admin`.

## 1. Database Setup

Run the SQL in `database_setup.sql` to create the `user_profiles` table and set up automatic profile creation.

## 2. How Roles Work

### User Roles:

-   **Student**: Default role, can view content
-   **Professor**: Can create posts, view all timetables
-   **Admin**: Full access, can manage users

### Sample User Data:

```sql
-- Insert sample users with different roles
INSERT INTO user_profiles (id, email, full_name, role, semester, course_code, batch) VALUES
('user-id-1', 'student@example.com', 'John Student', 'student', 5, 'CSE', '1'),
('user-id-2', 'prof@example.com', 'Dr. Jane Professor', 'professor', NULL, 'CSE', NULL),
('user-id-3', 'admin@example.com', 'Admin User', 'admin', NULL, NULL, NULL);
```

## 3. Using AuthService

### Getting Current User:

```dart
final authService = AuthService();
final currentUser = authService.currentUser;

if (currentUser != null) {
  print('User: ${currentUser.fullName}');
  print('Role: ${currentUser.role.name}');
  print('Semester: ${currentUser.semester}');
}
```

### Checking Permissions:

```dart
// Check specific role
if (authService.hasRole(UserRole.professor)) {
  // Show professor-only content
}

// Check multiple roles
if (authService.canAccess([UserRole.professor, UserRole.admin])) {
  // Show faculty content
}

// Use user profile methods
if (currentUser?.canCreatePosts() == true) {
  // Show create post button
}
```

## 4. Using RoleGuard Widgets

### Basic Role Guard:

```dart
RoleGuard(
  allowedRoles: [UserRole.professor, UserRole.admin],
  child: ElevatedButton(
    onPressed: () => Navigator.push(context, CreatePostScreen()),
    child: Text('Create Post'),
  ),
  fallback: Text('Only professors can create posts'),
)
```

### Convenience Widgets:

```dart
// Student-only content
StudentOnlyWidget(
  child: Text('Student Dashboard'),
)

// Professor-only content
ProfessorOnlyWidget(
  child: FloatingActionButton(
    onPressed: () => createPost(),
    child: Icon(Icons.add),
  ),
)

// Admin-only content
AdminOnlyWidget(
  child: ListTile(
    title: Text('User Management'),
    onTap: () => openUserManagement(),
  ),
)

// Faculty (Professor + Admin) content
FacultyWidget(
  child: Text('Faculty Resources'),
)
```

## 5. Example Implementation in Home Screen

```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tickter'),
        actions: [
          // Only show create post button for professors and admins
          FacultyWidget(
            child: IconButton(
              icon: Icon(Icons.add),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreatePostScreen())
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Show user info
          ListenableBuilder(
            listenable: AuthService(),
            builder: (context, _) {
              final user = AuthService().currentUser;
              return Container(
                padding: EdgeInsets.all(16),
                color: Colors.blue[50],
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Welcome, ${user?.fullName ?? user?.email}'),
                    Spacer(),
                    Chip(
                      label: Text(user?.role.name.toUpperCase() ?? 'UNKNOWN'),
                      backgroundColor: _getRoleColor(user?.role),
                    ),
                  ],
                ),
              );
            },
          ),

          // Role-specific content
          Expanded(
            child: ListView(
              children: [
                // Student-specific content
                StudentOnlyWidget(
                  child: Card(
                    child: ListTile(
                      title: Text('My Timetable'),
                      subtitle: Text('Semester ${AuthService().currentUser?.semester}'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CalendarScreen()),
                      ),
                    ),
                  ),
                ),

                // Professor-specific content
                ProfessorOnlyWidget(
                  child: Card(
                    child: ListTile(
                      title: Text('All Timetables'),
                      subtitle: Text('View all student timetables'),
                      onTap: () => openAllTimetables(),
                    ),
                  ),
                ),

                // Admin-specific content
                AdminOnlyWidget(
                  child: Card(
                    child: ListTile(
                      title: Text('Admin Panel'),
                      subtitle: Text('Manage users and system settings'),
                      onTap: () => openAdminPanel(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Logout button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await AuthService().signOut();
        },
        label: Text('Logout'),
        icon: Icon(Icons.logout),
      ),
    );
  }

  Color _getRoleColor(UserRole? role) {
    switch (role) {
      case UserRole.student:
        return Colors.blue;
      case UserRole.professor:
        return Colors.green;
      case UserRole.admin:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
```

## 6. Calendar Integration

The calendar now automatically uses the current user's data:

```dart
// Calendar automatically gets user's semester, course, and batch
final calendar = CalendarScreen(); // Uses AuthService().currentUser data

// Manual override if needed:
final userSemester = AuthService().currentUser?.semester ?? 5;
final userBatch = AuthService().currentUser?.batch ?? '1';
```

## 7. Authentication Flow

1. **Login** → AuthService.signInWithPassword()
2. **Auto Profile Load** → Fetches user_profiles data
3. **Role Available** → Throughout app via AuthService().currentUser
4. **Logout** → AuthService.signOut() clears all data

## 8. Security Features

-   **Row Level Security**: Users can only access their own data
-   **Admin Override**: Admins can access all data
-   **Automatic Profile Creation**: New users get profiles automatically
-   **Role Validation**: Database enforces valid roles

This system provides a complete RBAC solution that's easy to use and maintain!

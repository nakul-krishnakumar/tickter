/// App constants and configuration values
/// This file contains NON-SENSITIVE fallback values when .env is not available
/// DO NOT put secret keys, passwords, or sensitive data here!
library;

class AppConstants {
  /// API Configuration - Only public URLs, no secrets
  static const String apiBaseUrl =
      'https://tickter-server.politedune-284f8f74.southindia.azurecontainerapps.io/api';

  /// Supabase Configuration - Only public URL, NO KEYS
  static const String supabaseUrl = 'https://owqmxdgbcoqqzzasyiuh.supabase.co';

  // 🚫 SECURITY NOTE: Keys are NOT stored here for security reasons
  // Keys MUST come from .env file or environment variables

  /// App Information
  static const String appName = 'Tickter';
  static const String appVersion = '1.0.0';

  /// UI Constants
  static const double defaultPadding = 16.0;
  static const double borderRadius = 8.0;

  /// API Endpoints (relative to apiBaseUrl)
  static const String postsEndpoint = 'v1/posts';
  static const String searchEndpoint = 'v1/posts/search';
  static const String uploadEndpoint = 'v1/posts/upload';
  static const String adminEndpoint = 'v1/admin';
}

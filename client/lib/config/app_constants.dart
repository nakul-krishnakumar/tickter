/// App constants and configuration values
/// This file contains fallback values when .env is not available (e.g., web builds)
library;

class AppConstants {
  /// API Configuration
  static const String apiBaseUrl =
      'https://tickter-server.politedune-284f8f74.southindia.azurecontainerapps.io/api';

  /// Supabase Configuration
  static const String supabaseUrl = 'https://owqmxdgbcoqqzzasyiuh.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im93cW14ZGdiY29xcXp6YXN5aXVoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU1MTM4MDQsImV4cCI6MjA3MTA4OTgwNH0.W2wb3W6inND012yUzkp7wurMvELNkmrpXcX7rGgLW2A';
  static const String supabaseServiceKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im93cW14ZGdiY29xcXp6YXN5aXVoIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NTUxMzgwNCwiZXhwIjoyMDcxMDg5ODA0fQ.k0RNd4Zprm6n_jOIBCWSfHVMtR1QqxPews24gxrBPCM';

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

import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../config/app_constants.dart';

/// Service class to manage app configuration from environment variables
class ConfigService {
  /// Private constructor to ensure singleton pattern
  ConfigService._internal();

  /// Singleton instance
  static final ConfigService _instance = ConfigService._internal();

  /// Factory constructor returns the singleton instance
  factory ConfigService() => _instance;

  /// Get the API base URL from environment
  static String get apiBaseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      // Fallback to constants for web/production builds
      print(
        '⚠️  CONFIG: API_BASE_URL not found in .env, using fallback: ${AppConstants.apiBaseUrl}',
      );
      return AppConstants.apiBaseUrl;
    }
    return url;
  }

  /// Get Supabase URL from environment
  static String get supabaseUrl {
    final url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty) {
      // Fallback to constants for web/production builds
      print(
        '⚠️  CONFIG: SUPABASE_URL not found in .env, using fallback: ${AppConstants.supabaseUrl}',
      );
      return AppConstants.supabaseUrl;
    }
    return url;
  }

  /// Get Supabase anonymous key from environment
  static String get supabaseAnonKey {
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty) {
      // Fallback to constants for web/production builds
      print('⚠️  CONFIG: SUPABASE_ANON_KEY not found in .env, using fallback');
      return AppConstants.supabaseAnonKey;
    }
    return key;
  }

  /// Get Supabase service key from environment
  static String get supabaseServiceKey {
    final key = dotenv.env['SUPABASE_SERVICE_KEY'];
    if (key == null || key.isEmpty) {
      // Fallback to constants for web/production builds
      print(
        '⚠️  CONFIG: SUPABASE_SERVICE_KEY not found in .env, using fallback',
      );
      return AppConstants.supabaseServiceKey;
    }
    return key;
  }

  /// Helper method to build API URLs
  static String buildApiUrl(String endpoint) {
    return '$apiBaseUrl/$endpoint';
  }

  /// Helper method to build API URLs with version
  static String buildApiUrlV1(String endpoint) {
    return '$apiBaseUrl/v1/$endpoint';
  }

  /// Debug method to check if all required environment variables are loaded
  static void validateEnvironment() {
    print('🔧 CONFIG: Validating environment variables...');

    // Check if .env file was loaded properly
    final envLoaded = dotenv.env.isNotEmpty;
    print('� .env file loaded: ${envLoaded ? "✓" : "✗ (using fallbacks)"}');

    // Validate each configuration
    final apiUrl = apiBaseUrl;
    final supaUrl = supabaseUrl;
    final anonKey = supabaseAnonKey;
    final serviceKey = supabaseServiceKey;

    print('�📡 API Base URL: $apiUrl');
    print('🔗 Supabase URL: $supaUrl');
    print(
      '🔑 Supabase Anon Key: ${anonKey.isNotEmpty ? "✓ Loaded" : "✗ Missing"}',
    );
    print(
      '🔐 Supabase Service Key: ${serviceKey.isNotEmpty ? "✓ Loaded" : "✗ Missing"}',
    );

    if (envLoaded) {
      print('✅ CONFIG: All environment variables loaded from .env file!');
    } else {
      print(
        '⚠️  CONFIG: Using hardcoded fallbacks (recommended for production builds)',
      );
    }
  }
}

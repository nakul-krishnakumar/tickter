# 🔐 Security Best Practices for Environment Variables

## ⚠️ IMPORTANT SECURITY NOTICE

**NEVER commit sensitive keys to your repository!**

This project uses a secure approach for handling environment variables:

## 📁 File Structure

```
lib/
├── config/
│   └── app_constants.dart     # ✅ Public URLs only, NO secrets
└── services/
    └── config_service.dart    # ✅ Reads from .env, throws if missing
.env                           # ✅ Contains secrets, in .gitignore
```

## 🔒 What Goes Where

### ✅ In `app_constants.dart` (Safe to commit):

-   Public API URLs
-   Public Supabase project URLs
-   App configuration (name, version, etc.)
-   UI constants

### 🚫 In `.env` file (NEVER commit):

-   API keys
-   Secret keys
-   Service keys
-   Database passwords
-   OAuth secrets

## 📋 Setup Instructions

### 1. Local Development

```bash
# Create .env file in your project root
touch .env

# Add your secrets (replace with your actual values)
echo 'API_BASE_URL="https://your-server.com/api"' >> .env
echo 'SUPABASE_URL="https://your-project.supabase.co"' >> .env
echo 'SUPABASE_ANON_KEY="your-anon-key"' >> .env
echo 'SUPABASE_SERVICE_KEY="your-service-key"' >> .env
```

### 2. Production Deployment

#### For Web Hosting (Netlify, Vercel, etc.):

1. Set environment variables in your hosting platform's dashboard
2. The ConfigService will automatically use them

#### For Mobile App Stores:

1. Build with your production .env file
2. Keys get bundled into the app (secure for mobile)

## 🛡️ Security Features

### 1. **No Hardcoded Secrets**

```dart
// ❌ BAD - Don't do this
static const String apiKey = 'sk-123abc...';

// ✅ GOOD - Our approach
static String get apiKey {
  final key = dotenv.env['API_KEY'];
  if (key == null) {
    throw Exception('API_KEY not found in .env!');
  }
  return key;
}
```

### 2. **Fail-Safe Behavior**

-   App crashes if sensitive keys are missing (better than running insecurely)
-   Clear error messages guide developers to fix configuration
-   Public URLs have safe fallbacks

### 3. **Development vs Production**

-   Development: Uses `.env` file
-   Production: Uses platform environment variables
-   No secrets in source code, ever!

## 🚀 Deployment Checklist

-   [ ] `.env` file is in `.gitignore`
-   [ ] No secrets in `app_constants.dart`
-   [ ] Environment variables set in hosting platform
-   [ ] App validates configuration on startup
-   [ ] Error handling works for missing variables

## 🔍 Common Issues

### "SUPABASE_ANON_KEY not found in .env file!"

**Solution:** Add the key to your `.env` file:

```
SUPABASE_ANON_KEY="your-actual-key-here"
```

### App works locally but fails in production

**Solution:** Set environment variables in your hosting platform:

1. Netlify: Site settings → Environment variables
2. Vercel: Project settings → Environment Variables
3. Firebase Hosting: Use `firebase functions:config:set`

## 📖 References

-   [Flutter Environment Variables](https://docs.flutter.dev/development/data-and-backend/state-mgmt/options#environment-variables)
-   [Supabase Security Best Practices](https://supabase.com/docs/guides/auth/auth-helpers/nextjs)
-   [OWASP Secure Coding Practices](https://owasp.org/www-project-secure-coding-practices-quick-reference-guide/)

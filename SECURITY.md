# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in Quest ON, please report it responsibly:

- Email: stophyuk94@gmail.com
- Subject: [SECURITY] Quest ON Vulnerability Report
- Do NOT open public issues for security vulnerabilities

We will respond within 48 hours.

---

## Security Best Practices

### For Developers

#### 1. Environment Variables
Never commit sensitive credentials to Git. All API keys must be passed via environment variables:

```bash
flutter run \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=... \
  -d <device_id>
```

Or use the provided scripts:
```bash
# Copy example and add your keys
cp scripts/run_dev.bat.example scripts/run_dev.bat

# Edit run_dev.bat with your actual keys
# Then run:
scripts\run_dev.bat
```

#### 2. Supabase Security
- **Row Level Security (RLS)** is REQUIRED for all tables
- Users can only access their own data
- Service role key must NEVER be exposed to clients
- Regenerate keys immediately if exposed

#### 3. .gitignore
The following files are ignored and must never be committed:
- `scripts/run_dev.bat` (contains actual keys)
- `scripts/run_dev.sh` (contains actual keys)
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `firebase_options.dart`
- `.env` files

#### 4. Dependency Updates
- Run `flutter pub upgrade` regularly
- Monitor security advisories
- Use GitHub Dependabot

---

## Security Features

### Implemented
- ✅ Environment variable validation in `lib/core/constants/env.dart`
- ✅ Supabase RLS policies on all tables
- ✅ Firebase authentication with Google OAuth
- ✅ Secure API communication (HTTPS only)
- ✅ Client-side input validation

### Roadmap
- 🔜 Implement Sentry for error tracking
- 🔜 Add rate limiting on API endpoints
- 🔜 Implement certificate pinning
- 🔜 Add biometric authentication option

---

## Known Security Considerations

### Supabase Anon Key
The Supabase anon key is designed to be public-facing, but:
- ⚠️ RLS policies MUST be properly configured
- ⚠️ Never expose the service role key
- ⚠️ Regularly audit RLS policies

### OpenAI API
- API keys are stored securely in Supabase Edge Functions
- Never exposed to client-side code
- Usage limits enforced server-side

### Firebase
- Authentication tokens expire after 1 hour
- Refresh tokens stored securely
- Google Sign-In uses secure OAuth 2.0 flow

---

## Incident Response Plan

If a security breach occurs:

1. **Immediate Action**
   - Revoke compromised credentials
   - Generate new keys
   - Deploy emergency patch

2. **Investigation**
   - Assess scope of breach
   - Identify affected users
   - Document timeline

3. **Communication**
   - Notify affected users
   - Publish security advisory
   - Update security measures

4. **Post-Mortem**
   - Conduct root cause analysis
   - Implement preventive measures
   - Update security documentation

---

## Compliance

### Data Privacy
- User data is stored securely in Supabase (PostgreSQL)
- Firebase Analytics follows GDPR guidelines
- No personal data shared with third parties without consent

### App Store Requirements
- Follows Google Play security best practices
- Implements required security features
- Regular security audits before releases

---

## Security Checklist for Releases

Before each release, verify:

- [ ] No hardcoded credentials in codebase
- [ ] All dependencies up to date
- [ ] RLS policies tested and verified
- [ ] Firebase rules configured correctly
- [ ] ProGuard/R8 enabled for production builds
- [ ] API rate limiting in place
- [ ] Error messages don't leak sensitive info
- [ ] HTTPS enforced for all API calls

---

## Contact

For security concerns:
- Email: stophyuk94@gmail.com
- GitHub: [@Stophyuk](https://github.com/Stophyuk)

---

**Last Updated**: 2025-11-11
**Version**: 1.0.0

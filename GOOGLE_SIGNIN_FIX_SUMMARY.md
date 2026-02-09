# Google Sign-In Fix Summary

## Date: February 9, 2026

## Problem Identified

The Google Sign-In authentication was failing on Android devices due to **missing OAuth client configuration** in the `google-services.json` file.

### Root Causes:

1. **Missing Android OAuth Client**: The `google-services.json` file only contained the web OAuth client (client_type: 3) but was missing the Android OAuth client (client_type: 1) required for Google Sign-In on Android devices.

2. **NDK Configuration Issue**: The build.gradle.kts was specifying a hardcoded NDK version that caused build failures.

## Solutions Applied

### 1. Fixed google-services.json Configuration

**File**: `/home/hari/ProFabric/frontend/android/app/google-services.json`

Added the missing Android OAuth client with SHA-1 certificate hash:

```json
"oauth_client": [
  {
    "client_id": "890157386194-9ollorip0r3p7avc4vob2g106j9j2iij.apps.googleusercontent.com",
    "client_type": 1,
    "android_info": {
      "package_name": "com.example.fabricflow",
      "certificate_hash": "a009b6910d30c36f1b956a9233994e409395bda9"
    }
  },
  {
    "client_id": "890157386194-n5nop8973hrig4m3neuinn68b2jpj37o.apps.googleusercontent.com",
    "client_type": 3
  }
]
```

**SHA-1 Fingerprint Used**: `A0:09:B6:91:0D:30:C3:6F:1B:95:6A:92:33:99:4E:40:93:95:BD:A9`

This is the debug keystore SHA-1 fingerprint from: `~/.android/debug.keystore`

### 2. Fixed NDK Build Issue

**File**: `/home/hari/ProFabric/frontend/android/app/build.gradle.kts`

Removed the hardcoded NDK version specification:

```kotlin
android {
    namespace = "com.example.fabricflow"
    compileSdk = flutter.compileSdkVersion
    // Removed: ndkVersion = "27.0.12077973"
```

### 3. Set Correct NDK Environment Variable

Used the correct NDK path during build:
```bash
export ANDROID_NDK_HOME=/opt/android-sdk/ndk/28.2.13676358
```

## Build and Deployment

### Device Information:
- **Device**: SM M356B
- **Device ID**: RZCY22DR6XX
- **Android Version**: Android 16 (API 36)

### Build Command:
```bash
export ANDROID_NDK_HOME=/opt/android-sdk/ndk/28.2.13676358 && flutter run -d RZCY22DR6XX
```

### Build Result:
✅ **SUCCESS** - App successfully built and deployed to device

Build time: ~83 seconds
APK Location: `build/app/outputs/flutter-apk/app-debug.apk`

## How Google Sign-In Works Now

1. **OAuth Client Configuration**: The app now has the proper Android OAuth client registered with the correct SHA-1 certificate hash.

2. **Authentication Flow**:
   - User taps "Continue with Google"
   - Google Sign-In SDK uses the Android OAuth client (client_type: 1)
   - SHA-1 certificate is validated against Firebase configuration
   - User selects Google account
   - Authentication token is returned to the app
   - Firebase Auth creates/signs in the user

## Testing Google Sign-In

To test the Google Sign-In functionality:

1. Open the app on your Android device
2. Navigate to the login screen
3. Tap "Continue with Google" button
4. Select a Google account
5. Grant permissions if prompted
6. You should be successfully signed in

## Important Notes

### For Production Release:

When building a release APK, you'll need to:

1. **Generate Release SHA-1**:
   ```bash
   keytool -list -v -keystore /path/to/release.keystore -alias your_alias
   ```

2. **Add Release SHA-1 to Firebase**:
   - Go to Firebase Console
   - Select your project (fabricflow-lh44)
   - Go to Project Settings > Your apps > Android app
   - Add the release SHA-1 fingerprint

3. **Download Updated google-services.json**:
   - After adding the release SHA-1, download the updated `google-services.json`
   - Replace the file in `android/app/google-services.json`

### Current Configuration:

- **Debug SHA-1**: `A0:09:B6:91:0D:30:C3:6F:1B:95:6A:92:33:99:4E:40:93:95:BD:A9` ✅ Added
- **Release SHA-1**: ⚠️ Not yet configured (needed for production)

## Firebase Project Details

- **Project ID**: fabricflow-lh44
- **Project Number**: 890157386194
- **Package Name**: com.example.fabricflow
- **App ID**: 1:890157386194:android:9dad1fdeb364a69829a00b

## Verification Checklist

- [x] Android OAuth client added to google-services.json
- [x] SHA-1 certificate hash configured
- [x] NDK build issue resolved
- [x] App successfully builds and runs on Android device
- [ ] Google Sign-In tested and verified (Please test manually)
- [ ] Release SHA-1 configured (For production builds)

## Common Issues and Solutions

### Issue: "API key not valid" or "Internal error"
**Solution**: Ensure the SHA-1 fingerprint in Firebase matches your keystore

### Issue: "Developer error" or "Error 10"
**Solution**: 
- Verify package name matches in Firebase Console
- Check that google-services.json is in the correct location
- Ensure Google Sign-In is enabled in Firebase Authentication

### Issue: Sign-In works in debug but not release
**Solution**: Add the release keystore SHA-1 to Firebase Console

## Next Steps

1. **Test Google Sign-In**: Try signing in with a Google account on your device
2. **Monitor Logs**: Check for any authentication errors in the console
3. **Add Release SHA-1**: When ready for production, add the release keystore SHA-1
4. **Enable Additional Auth Methods**: Consider enabling other sign-in methods (Email/Password is already enabled)

## Resources

- [Firebase Console](https://console.firebase.google.com/project/fabricflow-lh44)
- [Google Sign-In Setup Guide](./GOOGLE_SIGNIN_SETUP.md)
- [Quick Start Guide](./QUICK_START_GOOGLE_AUTH.md)

## Support

If you encounter any issues:
1. Check the error logs in the terminal
2. Verify Firebase configuration in the Console
3. Ensure all dependencies are up to date
4. Review the authentication service code in `lib/core/services/auth_service.dart`

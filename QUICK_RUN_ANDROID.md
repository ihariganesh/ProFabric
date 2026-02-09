# Quick Start: Running ProFabric on Android

## Prerequisites
Set the NDK environment variable:
```bash
export ANDROID_NDK_HOME=/opt/android-sdk/ndk/28.2.13676358
```

## Build and Run

### Option 1: Quick Run (Recommended)
```bash
cd /home/hari/ProFabric/frontend
export ANDROID_NDK_HOME=/opt/android-sdk/ndk/28.2.13676358 && flutter run -d RZCY22DR6XX
```

### Option 2: Clean Build
```bash
cd /home/hari/ProFabric/frontend
flutter clean
flutter pub get
export ANDROID_NDK_HOME=/opt/android-sdk/ndk/28.2.13676358 && flutter run -d RZCY22DR6XX
```

## Device Information
- **Device Name**: SM M356B
- **Device ID**: RZCY22DR6XX
- **Android Version**: Android 16 (API 36)

## Testing Google Sign-In

1. Open the app on your device
2. Navigate to login/signup screen
3. Tap "Continue with Google"
4. Select your Google account
5. Grant permissions
6. ✅ You should be signed in successfully!

## Troubleshooting

### If build fails with NDK error:
```bash
export ANDROID_NDK_HOME=/opt/android-sdk/ndk/28.2.13676358
```

### If Google Sign-In shows error but user is authenticated:
This is expected - the workaround handles it automatically. Check if you're signed in.

### To check connected devices:
```bash
flutter devices
```

### To view logs:
The terminal will show all logs automatically when running the app.

## Hot Reload

While the app is running, you can:
- Press `r` for hot reload (fast)
- Press `R` for hot restart (slower, full restart)
- Press `q` to quit

## Files Modified

1. `/home/hari/ProFabric/frontend/android/app/google-services.json` - Added Android OAuth client
2. `/home/hari/ProFabric/frontend/android/app/build.gradle.kts` - Removed hardcoded NDK version
3. `/home/hari/ProFabric/frontend/lib/core/services/auth_service.dart` - Added error handling workaround
4. `/home/hari/ProFabric/frontend/pubspec.yaml` - Updated package versions

## Success Indicators

When Google Sign-In works, you'll see in the logs:
```
D/FirebaseAuth: Notifying id token listeners about user ( ... ).
I/flutter: Google Sign In successful: your-email@gmail.com
```

## Next Steps

- Test with different Google accounts
- Test other app features
- Add release SHA-1 for production builds
- Test on other Android devices

For detailed information, see:
- `GOOGLE_SIGNIN_FINAL_SOLUTION.md` - Complete fix documentation
- `GOOGLE_SIGNIN_FIX_SUMMARY.md` - Initial fix summary
- `GOOGLE_SIGNIN_SETUP.md` - Setup guide

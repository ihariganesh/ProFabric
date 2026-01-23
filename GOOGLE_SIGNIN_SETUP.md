# Google Sign-In Setup Guide for FabricFlow

This guide will help you set up Google Sign-In for the FabricFlow application.

## Prerequisites

- Google account
- Firebase project
- Flutter development environment

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Name your project (e.g., "ProFabric")
4. Follow the setup wizard

## Step 2: Enable Authentication

1. In Firebase Console, go to **Build** > **Authentication**
2. Click **Get Started**
3. Go to **Sign-in method** tab
4. Enable **Email/Password** provider
5. Enable **Google** provider
   - Enter project support email
   - Click **Save**

## Step 3: Register Your App

### For Web (Linux Desktop uses Web configuration):

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Under "Your apps", click the **Web** icon (`</>`)
3. Register app with a nickname (e.g., "FabricFlow Web")
4. Copy the Firebase configuration object

### For Android (if you want to support Android):

1. Click the **Android** icon
2. Enter your package name: `com.example.fabricflow`
3. Download `google-services.json`
4. Place it in `android/app/`
5. Follow the setup instructions

### For iOS (if you want to support iOS):

1. Click the **iOS** icon
2. Enter your bundle ID: `com.example.fabricflow`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/`

## Step 4: Configure Your App

### Update Firebase Configuration in main.dart

Replace the Firebase configuration in `/frontend/lib/main.dart`:

\`\`\`dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "YOUR_API_KEY_HERE",
    authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_PROJECT_ID.appspot.com",
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
    appId: "YOUR_APP_ID",
  ),
);
\`\`\`

**Get these values from:**
Firebase Console > Project Settings > Your apps > Web app config

### Update Web Configuration (Optional)

Edit `/frontend/web/firebase-config.js` with your Firebase config:

\`\`\`javascript
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT_ID.appspot.com",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  appId: "YOUR_APP_ID"
};
\`\`\`

## Step 5: Configure Google Sign-In for Linux Desktop

For Linux desktop applications, Google Sign-In uses the web flow:

1. In Firebase Console > Authentication > Settings > Authorized domains
2. Add `localhost` to authorized domains
3. No additional Linux-specific configuration needed

## Step 6: Install Dependencies

Run in your project directory:

\`\`\`bash
cd frontend
flutter pub get
\`\`\`

This will install:
- `firebase_core`: ^2.24.2
- `firebase_auth`: ^4.15.3
- `google_sign_in`: ^6.2.1

## Step 7: Build and Run

### For Linux Desktop:

\`\`\`bash
flutter run -d linux
\`\`\`

### For Android:

\`\`\`bash
flutter run -d android
\`\`\`

Make sure you've added `google-services.json` to `android/app/`

### For Web:

\`\`\`bash
flutter run -d chrome
\`\`\`

## Testing the Authentication

1. **Sign Up Flow:**
   - Click "Sign Up" in the login screen
   - Enter full name, email, and password
   - Click "Create Account"
   - User should be created in Firebase

2. **Sign In Flow:**
   - Enter registered email and password
   - Click "Sign In"
   - Should navigate to home screen

3. **Google Sign-In:**
   - Click "Continue with Google" button
   - Browser/popup will open
   - Select Google account
   - Should navigate to home screen

4. **Forgot Password:**
   - Click "Forgot password?"
   - Enter email
   - Check email for reset link

## Troubleshooting

### Common Issues:

1. **"Network error" or "Connection failed":**
   - Check internet connection
   - Verify Firebase config values are correct
   - Ensure Authentication is enabled in Firebase Console

2. **"Invalid API key":**
   - Double-check API key in main.dart matches Firebase config
   - Regenerate API key if needed

3. **Google Sign-In not working:**
   - Verify Google provider is enabled in Firebase Console
   - Check authorized domains include localhost
   - For production, add your domain to authorized domains

4. **"Email already in use":**
   - This email is already registered
   - Use sign-in instead or use different email

5. **Linux-specific issues:**
   - Ensure web support is enabled: `flutter config --enable-web`
   - Google Sign-In uses web flow on Linux

## Security Best Practices

1. **Never commit Firebase config with real credentials** to public repositories
2. Use **environment variables** for production
3. Enable **App Check** in Firebase for additional security
4. Set up **Email verification** for new users
5. Implement **rate limiting** to prevent abuse

## Additional Features to Implement

1. **Email Verification:**
   \`\`\`dart
   await _authService.currentUser?.sendEmailVerification();
   \`\`\`

2. **User Profile Management:**
   \`\`\`dart
   await _authService.currentUser?.updateDisplayName("New Name");
   await _authService.currentUser?.updatePhotoURL("photo_url");
   \`\`\`

3. **Sign Out:**
   \`\`\`dart
   await _authService.signOut();
   Navigator.of(context).pushReplacementNamed('/login');
   \`\`\`

4. **Listen to Auth State:**
   \`\`\`dart
   _authService.authStateChanges.listen((User? user) {
     if (user == null) {
       // User signed out
       Navigator.of(context).pushReplacementNamed('/login');
     }
   });
   \`\`\`

## Support

For more information:
- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
- [Google Sign-In Plugin](https://pub.dev/packages/google_sign_in)
- [FlutterFire Documentation](https://firebase.flutter.dev/)

## License

This setup guide is part of the ProFabric project.

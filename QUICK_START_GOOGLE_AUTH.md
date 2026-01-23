# Quick Start: Setting Up Google Sign-In

## What You Need Right Now

To make Google Sign-In work, follow these steps:

### 1. Create Firebase Project (5 minutes)

1. Go to https://console.firebase.google.com/
2. Click "Add project"
3. Name it "ProFabric" (or any name)
4. Disable Google Analytics (optional)
5. Click "Create project"

### 2. Enable Authentication (2 minutes)

1. In Firebase Console sidebar, click **Authentication**
2. Click **Get Started**
3. Click **Sign-in method** tab
4. Enable **Email/Password**: Click it → Toggle ON → Save
5. Enable **Google**: Click it → Toggle ON → Enter support email → Save

### 3. Register Your App (3 minutes)

#### For Linux Desktop (uses Web config):

1. In Firebase Console, click the gear icon (⚙️) → **Project settings**
2. Scroll to "Your apps" section
3. Click the Web icon (`</>`)
4. Register app nickname: "FabricFlow Linux"
5. **DON'T check** "Also set up Firebase Hosting"
6. Click "Register app"
7. You'll see a config object like this:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSy...",
  authDomain: "profabric-abc123.firebaseapp.com",
  projectId: "profabric-abc123",
  storageBucket: "profabric-abc123.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abc123"
};
```

### 4. Update Your App Config (2 minutes)

Open `/home/hari/ProFabric/frontend/lib/main.dart`

Replace this section (around line 13):

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "AIzaSyDemoKey-REPLACE_WITH_YOUR_KEY",  // ← REPLACE THIS
    authDomain: "profabric-demo.firebaseapp.com",  // ← REPLACE THIS
    projectId: "profabric-demo",                    // ← REPLACE THIS
    storageBucket: "profabric-demo.appspot.com",   // ← REPLACE THIS
    messagingSenderId: "123456789",                 // ← REPLACE THIS
    appId: "1:123456789:web:abcdef123456",         // ← REPLACE THIS
  ),
);
```

With your actual values from step 3.

### 5. Add localhost to Authorized Domains (1 minute)

1. In Firebase Console → **Authentication** → **Settings** tab
2. Scroll to **Authorized domains**
3. Click **Add domain**
4. Type: `localhost`
5. Click **Add**

### 6. Run Your App

```bash
cd /home/hari/ProFabric/frontend
flutter run -d linux
```

## Testing Google Sign-In

1. Launch the app
2. You'll see the login screen
3. Click **"Continue with Google"** button
4. A browser window will open
5. Select your Google account
6. Grant permissions
7. You'll be redirected back to the app
8. Should navigate to home screen automatically

## Testing Email Sign-Up

1. Click **"Sign Up"** at the bottom
2. Enter:
   - Full Name
   - Email address
   - Password (min 8 characters)
   - Confirm password
3. Click **"Create Account"**
4. Should create account and navigate to home

## Testing Email Sign-In

1. Enter your registered email
2. Enter password
3. Click **"Sign In"**
4. Should navigate to home screen

## If Something Goes Wrong

### Error: "Network request failed"
- Check your internet connection
- Verify Firebase config values are correct

### Google Sign-In opens but shows error
- Make sure Google provider is enabled in Firebase
- Check `localhost` is in authorized domains

### "Invalid API key"
- Double-check you copied the API key correctly
- No extra spaces or quotes

### Build errors after adding packages
```bash
cd frontend
flutter clean
flutter pub get
flutter run -d linux
```

## Current File Structure

```
ProFabric/
├── frontend/
│   ├── lib/
│   │   ├── main.dart                           # ← Firebase initialized here
│   │   ├── core/
│   │   │   └── services/
│   │   │       └── auth_service.dart          # ← Authentication logic
│   │   └── features/
│   │       └── auth/
│   │           └── screens/
│   │               └── login_screen.dart      # ← Uses AuthService
│   └── pubspec.yaml                            # ← Dependencies added
└── GOOGLE_SIGNIN_SETUP.md                      # ← Full documentation
```

## What's Already Done

✅ All packages installed (firebase_core, firebase_auth, google_sign_in)
✅ AuthService created with all methods
✅ LoginScreen integrated with real authentication
✅ Error handling and user feedback
✅ Loading states during authentication
✅ Form validation

## What You Need to Do

🔧 Create Firebase project (5 min)
🔧 Get Firebase config values (2 min)  
🔧 Update main.dart with your config (2 min)
🔧 Add localhost to authorized domains (1 min)

**Total time: ~10 minutes**

Then it will work completely!

## Pro Tips

1. **Save your Firebase config** somewhere safe
2. **Don't commit real API keys** to public GitHub repos
3. For production, use environment variables
4. Test with a real Google account first
5. Check Firebase Console → Authentication → Users to see registered users

## Need Help?

Check the full guide: `GOOGLE_SIGNIN_SETUP.md`

Firebase docs: https://firebase.google.com/docs/auth/web/google-signin

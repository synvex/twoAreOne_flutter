# iOS Configuration Walkthrough

I have implemented several critical configurations to ensure the app is ready for iOS deployment.

## Changes Made

### 1. Permissions and Metadata (`Info.plist`)
Updated [Info.plist](file:///C:/Users/NG/app/twoAreOne_flutter/ios/Runner/Info.plist) to include:
- `NSLocationWhenInUseUsageDescription`: Required for location search features.
- `ITSAppUsesNonExemptEncryption`: Set to `false` to simplify App Store compliance.

### 2. Dependency Management (`Podfile`)
Created a [Podfile](file:///C:/Users/NG/app/twoAreOne_flutter/ios/Podfile) with standard Flutter settings and specific macros for the `permission_handler` plugin. This ensures that only the permissions you actually use (Camera, Photos, Location, Microphone) are compiled into the app, preventing App Store rejection.

### 3. UI Optimization for iOS
Modified [custom_nav_bar.dart](file:///C:/Users/NG/app/twoAreOne_flutter/lib/features/views/bottom_nav/custom_nav_bar.dart) to wrap the tab items in a `SafeArea`. This prevents the navigation icons from overlapping with the iOS Home Indicator on modern iPhones.

---

## CRITICAL: Next Steps for You

> [!IMPORTANT]
> **Firebase Setup (Manual Action Required):**
> 1. Go to the [Firebase Console](https://console.firebase.google.com/).
> 2. Open your project and go to **Project Settings** > **General**.
> 3. Download the `GoogleService-Info.plist` for your iOS app.
> 4. **Important:** Do NOT just copy the file into the folder. You MUST open the project in **Xcode** (`ios/Runner.xcworkspace`) and drag the `GoogleService-Info.plist` file into the `Runner` folder inside Xcode. Select "Copy items if needed".

> [!TIP]
> **First Build:**
> Once you have added the Firebase file, run the following commands in your terminal:
> ```bash
> flutter pub get
> cd ios
> pod install
> cd ..
> flutter run
> ```

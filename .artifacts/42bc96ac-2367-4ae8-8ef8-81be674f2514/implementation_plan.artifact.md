# Fix Application Warnings and Font Assertions

The user is experiencing two types of issues after hot restarting:
1.  **Android Warning:** `OnBackInvokedCallback is not enabled`.
2.  **Flutter Assertion Error:** `RenderParagraph._scheduleSystemFontsUpdate() called during SchedulerPhase.midFrameMicrotasks`.

## User Review Required

> [!NOTE]
> The `RenderParagraph` assertion error is a known issue in the Flutter framework related to system font updates during the frame cycle. While it typically doesn't crash the app in release mode, it is intrusive during development.

## Proposed Changes

### Android Configuration

#### [MODIFY] [AndroidManifest.xml](file:///C:/Users/NG/app/twoAreOne_flutter/android/app/src/main/AndroidManifest.xml)
- Add `android:enableOnBackInvokedCallback="true"` to the `<application>` tag to resolve the warning and enable support for the predictive back gesture on Android 13+.

### Flutter Optimization (Optional but Recommended)

#### [MODIFY] [main.dart](file:///C:/Users/NG/app/twoAreOne_flutter/lib/main.dart)
- I will investigate if adding a small delay or configuration to `GoogleFonts` helps, but the primary fix is the manifest update for the first error.

## Verification Plan

### Automated Tests
- None applicable for these environment/manifest changes.

### Manual Verification
- Hot restart the app and verify that the `OnBackInvokedCallback` warning no longer appears in the logs.
- Check if the `RenderParagraph` assertion error persists (some framework errors are tied to the Flutter engine version itself).

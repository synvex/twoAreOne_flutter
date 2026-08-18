# Fix Location Text Color Consistency

The user reported an issue where the selected location text in `EditProfileScreen` appears black, even though it should match the hint text color (`_kFieldText` / `0xFF4D4D4D`). This is due to hardcoded text styles in the reusable text field components.

## User Review Required

> [!IMPORTANT]
> The `CustomInputField` component currently uses its `textColor` parameter ONLY for the hint text. I will update it to apply this color to the input text as well to ensure consistency.

## Proposed Changes

### Core Widgets

#### [MODIFY] [textfield.dart](file:///C:/Users/NG/app/twoAreOne_flutter/lib/core/widgets/textfield.dart)
- Update `CustomInputField` to use `widget.textColor` for the input text `style`, instead of hardcoding it to black.

### Settings Widgets

#### [MODIFY] [custom_text_field.dart](file:///C:/Users/NG/app/twoAreOne_flutter/lib/features/views/Settings/widgets/custom_text_field.dart)
- Add a `textColor` parameter to `CustomTextField`.
- Update the `style` property of the internal `TextField` to use this new parameter, defaulting to `AppColors.black`.

## Verification Plan

### Automated Tests
- I will verify the code changes manually as there are no existing unit tests for UI styles provided.

### Manual Verification
- Check `edit_profile_screen.dart` and verify that when a location is selected, the text color matches the hint text color (`0xFF4D4D4D`).
- Verify that other fields using `CustomInputField` (e.g., login, sign up) still function correctly (they will default to black if `textColor` is not provided).

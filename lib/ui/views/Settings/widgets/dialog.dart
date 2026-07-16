// lib/ui/views/settings/widgets/change_confirmation_dialog.dart
//
// Flutter port of RN's `components/ConfirmationAlert/index.js`. Used by
// SettingsScreen for both the "change your Number?" and "change your
// email?" confirmations (RN mounts two `<ConfirmationAlert>` instances
// with a different `message`, same component — this mirrors that with
// one shared widget + a `message` param).
//
// RN's version renders a `BlurView` backdrop; `BackdropFilter` here is
// built into Flutter's `dart:ui` (no extra package needed) so the blurred
// look is preserved without adding a dependency.

import 'dart:ui';

import 'package:flutter/material.dart';

class ChangeConfirmationDialog extends StatelessWidget {
  final String message;
  final bool loading;
  final VoidCallback onCancel;
  final VoidCallback onContinue;

  const ChangeConfirmationDialog({
    super.key,
    required this.message,
    required this.loading,
    required this.onCancel,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blurred, semi-transparent backdrop (RN: BlurView + rgba(0,0,0,0.5)).
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(color: Colors.black.withOpacity(0.5)),
        ),
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDEEF3),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.help_outline,
                      color: Color(0xFF77153C), size: 30),
                ),
                const SizedBox(height: 18),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: loading ? null : onCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF969696)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: loading ? null : onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF77153C),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: loading
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFDAFFED),
                          ),
                        )
                            : const Text(
                          'Continue',
                          style: TextStyle(color: Color(0xFFDAFFED)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
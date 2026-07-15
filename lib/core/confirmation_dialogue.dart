// lib/core/confirmation_dialog.dart
//
// Flutter port of the RN modals `components/LogoutConfirmation.js` and
// `components/DeleteConfirmation.js`. Both RN modals share the same layout
// and even the same red "Yes" button color (ThemeColors.red2) — only the
// title/message differ — so they're implemented here as one shared
// `_ConfirmationDialogBody` with two thin public wrappers to keep the call
// sites in profile_screen.dart readable.

import 'package:flutter/material.dart';

const Color _kConfirmRed = Color(0xFFD00000); // RN ThemeColors.red2

class LogoutConfirmationDialog extends StatelessWidget {
  final bool loading;
  final VoidCallback onClose;
  final VoidCallback onConfirm;

  const LogoutConfirmationDialog({
    super.key,
    required this.loading,
    required this.onClose,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return _ConfirmationDialogBody(
      title: "Logout",
      message: "Are you sure you want to logout?",
      loading: loading,
      onClose: onClose,
      onConfirm: onConfirm,
    );
  }
}

class DeleteConfirmationDialog extends StatelessWidget {
  final bool loading;
  final VoidCallback onClose;
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.loading,
    required this.onClose,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return _ConfirmationDialogBody(
      title: "Delete Account?",
      message:
      "Are you sure you want to delete your account? This action is permanent and cannot be reversed.",
      loading: loading,
      onClose: onClose,
      onConfirm: onConfirm,
    );
  }
}

class _ConfirmationDialogBody extends StatelessWidget {
  final String title;
  final String message;
  final bool loading;
  final VoidCallback onClose;
  final VoidCallback onConfirm;

  const _ConfirmationDialogBody({
    required this.title,
    required this.message,
    required this.loading,
    required this.onClose,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: loading ? null : onClose,
                  child: Container(
                    height: 40,
                    width: 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: const Color(0xFF969696)),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: loading ? null : onConfirm,
                  child: Container(
                    height: 40,
                    width: 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _kConfirmRed,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: loading
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      "Yes",
                      style:
                      TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
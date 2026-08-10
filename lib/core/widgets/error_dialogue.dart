import 'package:flutter/material.dart';
import 'dart:ui';

class CustomErrorAlert extends StatelessWidget {
  final String? title;
  final String? message;
  final bool close;
  final bool action; // shows Try Again / Cancel
  final VoidCallback? onClosePress;
  final VoidCallback? onRetryPress;
  final VoidCallback? onCancelPress;

  const CustomErrorAlert({
    super.key,
    this.title,
    this.message,
    this.close = true,
    this.action = false,
    this.onClosePress,
    this.onRetryPress,
    this.onCancelPress,
  });

  static Future<void> show(
      BuildContext context, {
        String? title,
        String? message,
        bool action = false,
        VoidCallback? onRetry,
      }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: CustomErrorAlert(
          title: title,
          message: message,
          action: action,
          close: !action,
          onClosePress: () => Navigator.pop(ctx),
          onRetryPress: () {
            Navigator.pop(ctx);
            onRetry?.call();
          },
          onCancelPress: () => Navigator.pop(ctx),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFF77153C), size: 48),
            const SizedBox(height: 12),
            Text(title ?? "Oops, Failed!",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              message ?? "Please check your internet connection then try again.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            if (close)
              TextButton(onPressed: onClosePress, child: const Text("Close")),
            if (action) ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF77153C)),
                onPressed: onRetryPress,
                child: const Text("Try Again", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: onCancelPress, child: const Text("Cancel")),
            ],
          ],
        ),
      ),
    );
  }
}
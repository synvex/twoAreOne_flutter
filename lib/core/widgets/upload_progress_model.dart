import 'package:flutter/material.dart';

class UploadProgressModal extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  const UploadProgressModal({super.key, required this.progress});

  static void show(BuildContext context, ValueNotifier<double> progressNotifier) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ValueListenableBuilder<double>(
        valueListenable: progressNotifier,
        builder: (context, value, _) => UploadProgressModal(progress: value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              progress < 1
                  ? 'Uploading... ${(progress * 100).round()}%'
                  : 'Processing...',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation(Color(0xFF77153C)), // your mehroon
              ),
            ),
          ],
        ),
      ),
    );
  }
}
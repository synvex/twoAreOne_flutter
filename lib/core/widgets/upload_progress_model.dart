import 'dart:async';
import 'package:flutter/material.dart';

class UploadProgressModal extends StatelessWidget {
  final double progress;
  const UploadProgressModal({super.key, required this.progress});

  static void show(BuildContext context, ValueNotifier<double> progressNotifier) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
        },
        child:ValueListenableBuilder<double>(
        valueListenable: progressNotifier,
        builder: (context, value, _) =>  UploadProgressModal(progress: value),),
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
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: progress),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          builder: (context, animatedValue, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  animatedValue < 1
                      ? 'Uploading... ${(animatedValue * 100).round()}%'
                      : 'Done!',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: animatedValue,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF77153C)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
// class UploadProgressModal extends StatelessWidget {
//   final double progress; // 0.0 to 1.0
//   const UploadProgressModal({super.key, required this.progress});
//
//   static void show(BuildContext context, ValueNotifier<double> progressNotifier) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => ValueListenableBuilder<double>(
//         valueListenable: progressNotifier,
//         builder: (context, value, _) => UploadProgressModal(progress: value),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               progress < 1
//                   ? 'Uploading... ${(progress * 100).round()}%'
//                   : 'Processing...',
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 15),
//             ClipRRect(
//               borderRadius: BorderRadius.circular(6),
//               child: LinearProgressIndicator(
//                 value: progress,
//                 minHeight: 8,
//                 backgroundColor: Colors.grey[300],
//                 valueColor: const AlwaysStoppedAnimation(Color(0xFF77153C)), // your mehroon
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class SmoothUploadProgress {
  final ValueNotifier<double> notifier = ValueNotifier(0.0);
  Timer? _ticker;
  double _target = 0.0;   // best known real progress
  double _displayed = 0.0;
  bool _uploadFinished = false; // bytes sent, waiting on server now

  void start() {
    _ticker = Timer.periodic(const Duration(milliseconds: 120), (_) {
      final cap = _uploadFinished ? 0.97 : 0.9; // never auto-fill to 100%
      final target = _uploadFinished ? 0.97 : _target;

      if (_displayed < target) {
        final diff = target - _displayed;
        // ease-out: bigger jumps early, smaller as it nears target
        final step = (diff * 0.15).clamp(0.003, 0.04);
        _displayed = (_displayed + step).clamp(0.0, cap);
        notifier.value = _displayed;
      }
    });
  }

  /// Call this from Dio's onSendProgress
  void onRealProgress(int sent, int total) {
    if (total > 0) {
      _target = sent / total;
      if (sent >= total) _uploadFinished = true;
    } else {
      // total unknown (-1) — nudge target forward so the ticker
      // still has something to chase instead of sitting at 0
      _target = (_target + 0.04).clamp(0.0, 0.85);
    }
  }

  /// Call once the server actually responds (success or failure)
  void finish() {
    _ticker?.cancel();
    _displayed = 1.0;
    notifier.value = 1.0;
  }

  void dispose() {
    _ticker?.cancel();
    notifier.dispose();
  }
}
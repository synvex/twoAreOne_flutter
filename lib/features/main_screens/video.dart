import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewCard extends StatefulWidget {
  final File file;
  const VideoPreviewCard({super.key, required this.file});

  @override
  State<VideoPreviewCard> createState() => _VideoPreviewCardState();
}

class _VideoPreviewCardState extends State<VideoPreviewCard> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _initialized = false;
  bool _hasError = false;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    // Delay init slightly to ensure the plugin channel is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initController();
    });
  }

  Future<void> _initController() async {
    try {
      final file = widget.file;
      final path = file.path;

      debugPrint("Initializing video: $path");

      VideoPlayerController controller;

      // image_picker on Android returns cache paths like /data/user/0/.../cache/...
      // These must use VideoPlayerController.file()
      // content:// URIs must use VideoPlayerController.contentUri()
      if (path.startsWith('content://')) {
        controller = VideoPlayerController.contentUri(Uri.parse(path));
      } else {
        controller = VideoPlayerController.file(File(path));
      }

      await controller.initialize();

      if (!mounted) {
        controller.dispose();
        return;
      }

      controller.addListener(_onVideoListener);

      setState(() {
        _controller = controller;
        _initialized = true;
        _hasError = false;
      });

      // Show first frame as thumbnail
      await controller.seekTo(const Duration(milliseconds: 50));

    } catch (e) {
      debugPrint("Video init failed: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMsg = e.toString();
          _initialized = false;
        });
      }
    }
  }

  void _onVideoListener() {
    if (!mounted || _controller == null) return;
    final isPlaying = _controller!.value.isPlaying;
    if (isPlaying != _isPlaying) {
      setState(() => _isPlaying = isPlaying);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoListener);
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller == null || !_initialized) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      // Replay from start if ended
      if (_controller!.value.position >= _controller!.value.duration) {
        _controller!.seekTo(Duration.zero);
      }
      _controller!.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlay,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(15),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            alignment: Alignment.center,
            children: [

              // ── Video frame ──────────────────────────────────────────────
              if (_initialized && _controller != null)
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                )

              // ── Error state ───────────────────────────────────────────────
              else if (_hasError)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.white54, size: 40),
                    const SizedBox(height: 8),
                    const Text(
                      "Cannot play video",
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                )

              // ── Loading spinner ───────────────────────────────────────────
              else
                const CircularProgressIndicator(
                  color: Color(0xFF77153C),
                  strokeWidth: 2,
                ),

              // ── Play / Pause overlay (only when initialized) ─────────────
              if (_initialized)
                AnimatedOpacity(
                  opacity: _isPlaying ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),

              // ── Progress bar ─────────────────────────────────────────────
              if (_initialized && _controller != null)
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: VideoProgressIndicator(
                    _controller!,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: Color(0xFF77153C),
                      bufferedColor: Colors.white38,
                      backgroundColor: Colors.white24,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}



// class _VideoPreviewCardState extends State<VideoPreviewCard> {
//   late VideoPlayerController _controller;
//   bool _isPlaying = false;
//   bool _initialized = false;
//
//   @override
//   @override
//   @override
//   void initState() {
//     super.initState();
//
//     final path = widget.file.path;
//
//     // Cache paths need .file(), content:// URIs need .contentUri()
//     if (path.startsWith('/data') || path.startsWith('/storage')) {
//       _controller = VideoPlayerController.file(widget.file);
//     } else {
//       _controller = VideoPlayerController.contentUri(Uri.parse(path));
//     }
//
//     _controller.initialize().then((_) {
//       if (mounted) {
//         setState(() => _initialized = true);
//         _controller.seekTo(const Duration(milliseconds: 100));
//       }
//     }).catchError((e) {
//       debugPrint("Video init error: $e");
//     });
//
//     _controller.addListener(() {
//       if (mounted) setState(() => _isPlaying = _controller.value.isPlaying);
//     });
//   }
//
//   // void initState() {
//   //   super.initState();
//   //   _controller = VideoPlayerController.file(widget.file)
//   //     ..initialize().then((_) {
//   //       if (mounted) setState(() => _initialized = true);
//   //     });
//   //
//   //   _controller.addListener(() {
//   //     if (mounted) setState(() => _isPlaying = _controller.value.isPlaying);
//   //   });
//   // }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   void _togglePlay() {
//     if (_controller.value.isPlaying) {
//       _controller.pause();
//     } else {
//       if (_controller.value.position >= _controller.value.duration) {
//         _controller.seekTo(Duration.zero);
//       }
//       _controller.play();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: _togglePlay,
//       child: Container(
//         width: double.infinity,
//         height: 200,
//         decoration: BoxDecoration(
//           color: Colors.black,
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(15),
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               // Video frame
//               if (_initialized)
//                 SizedBox.expand(
//                   child: FittedBox(
//                     fit: BoxFit.cover,
//                     child: SizedBox(
//                       width: _controller.value.size.width,
//                       height: _controller.value.size.height,
//                       child: VideoPlayer(_controller),
//                     ),
//                   ),
//                 )
//               else
//                 const Center(
//                   child: CircularProgressIndicator(
//                     color: Colors.white,
//                     strokeWidth: 2,
//                   ),
//                 ),
//
//               // Play/Pause overlay — hide when playing, show on pause
//               AnimatedOpacity(
//                 opacity: _isPlaying ? 0.0 : 1.0,
//                 duration: const Duration(milliseconds: 200),
//                 child: Container(
//                   width: 56,
//                   height: 56,
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.55),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.play_arrow_rounded,
//                     color: Colors.white,
//                     size: 36,
//                   ),
//                 ),
//               ),
//
//               // Progress bar at bottom
//               if (_initialized)
//                 Positioned(
//                   bottom: 0, left: 0, right: 0,
//                   child: VideoProgressIndicator(
//                     _controller,
//                     allowScrubbing: true,
//                     colors: const VideoProgressColors(
//                       playedColor: Color(0xFF77153C),
//                       bufferedColor: Colors.white38,
//                       backgroundColor: Colors.white24,
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 4),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
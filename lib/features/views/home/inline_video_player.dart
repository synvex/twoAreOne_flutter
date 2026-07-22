import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'full_scre_video_page.dart';

class InlineVideoPlayer extends StatefulWidget {
  final String url;
  const InlineVideoPlayer({super.key, required this.url});

  @override
  State<InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}
class _InlineVideoPlayerState extends State<InlineVideoPlayer> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _started = false;
  bool _loading = false;
  bool _failed = false;
  bool _showControls = false;
  bool _isMuted = false;
  Timer? _hideTimer;

  final Color kMehroon = const Color(0xFF77153C);

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _startPlayback() async {
    if (_loading || _initialized) return;

    setState(() {
      _started = true;
      _loading = true;
      _failed = false;
      _showControls = true; // Controls button dabate hi show ho jayenge
    });

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      _controller = controller;

      await controller.initialize().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Timeout'),
      );

      if (!mounted) return;

      setState(() {
        _initialized = true;
        _loading = false;
      });

      controller.addListener(_onControllerUpdate);
      controller.setVolume(_isMuted ? 0 : 1);
      await controller.play();
      _autoHideControls();
    }
    catch (e) {
      if (mounted) {
        setState(() {
          _failed = true;
          _loading = false;
        });
      }
    }
  }

  void _autoHideControls() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && (_controller?.value.isPlaying ?? false)) {
        setState(() => _showControls = false);
      }
    });
  }

  void _togglePlay() {
    if (!_started) {
      _startPlayback();
      return;
    }
    final controller = _controller;
    if (controller == null || !_initialized) return;

    setState(() => _showControls = true);
    if (controller.value.isPlaying) {
      controller.pause();
      _hideTimer?.cancel();
    } else {
      if (controller.value.position >= controller.value.duration) {
        controller.seekTo(Duration.zero);
      }
      controller.play();
      _autoHideControls();
    }
  }

  void _toggleMute() {
    final controller = _controller;
    if (controller == null) return;
    setState(() {
      _isMuted = !_isMuted;
      controller.setVolume(_isMuted ? 0 : 1);
    });
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  Future<void> _openFullscreen() async {
    if (_controller == null || !_initialized) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullscreenVideoPage(controller: _controller!),
        fullscreenDialog: true,
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_failed) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _failed = false;
            _started = false;
            _initialized = false;
            _loading = false;
          });
        },
        // child: const Center(
        //   child: Column(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       Icon(Icons.error_outline, color: Colors.white54, size: 36),
        //       SizedBox(height: 6),
        //       Text('Tap to retry', style: TextStyle(color: Colors.white54, fontSize: 12)),
        //     ],
        //   ),
        // ),
      );
    }

    if (!_started) {
      return GestureDetector(
        onTap: _startPlayback,
        child: Container(
          color: Colors.black,
          child: Center(
            child: Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
            ),
          ),
        ),
      );
    }

    final controller = _controller;

    return GestureDetector(
      onTap: () {
        if (_initialized) {
          setState(() => _showControls = !_showControls);
          if (_showControls) _autoHideControls();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Video or Loading Spinner
          if (_initialized && controller != null)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF77153C), strokeWidth: 2),
            ),

          // 2. Center Play/Pause Overlay
          if (_showControls || (_initialized && !(_controller?.value.isPlaying ?? false)))
            Center(
              child: GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    (_initialized && (_controller?.value.isPlaying ?? false))
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white, size: 40,
                  ),
                ),
              ),
            ),

          // 3. Mute Button
          if (_showControls)
            Positioned(
              top: 10, right: 10,
              child: GestureDetector(
                onTap: _toggleMute,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white, size: 20),
                ),
              ),
            ),

          // 4. Bottom Controls Layer
          if (_showControls)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black54],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (controller != null)
                      VideoProgressIndicator(
                        controller,
                        allowScrubbing: _initialized,
                        colors: VideoProgressColors(
                          playedColor: kMehroon,
                          bufferedColor: Colors.white38,
                          backgroundColor: Colors.white24,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _initialized && controller != null
                                ? "${_formatDuration(controller.value.position)} / ${_formatDuration(controller.value.duration)}"
                                : "00:00 / 00:00",
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                          GestureDetector(
                            onTap: _openFullscreen,
                            child: const Icon(Icons.fullscreen, color: Colors.white, size: 24),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}


//
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'full_scre_video_page.dart';
//
// class InlineVideoPlayer extends StatefulWidget {
//   final String url;
//   const InlineVideoPlayer({super.key, required this.url});
//
//   @override
//   State<InlineVideoPlayer> createState() => _InlineVideoPlayerState();
// }
//
// class _InlineVideoPlayerState extends State<InlineVideoPlayer> {
//   VideoPlayerController? _controller;
//   bool _initialized = false;
//   bool _started = false; // Tracks if the user has clicked play
//   bool _loading = false; // Tracks initialization progress after click
//   bool _failed = false;
//   bool _showControls = false;
//   bool _isMuted = false;
//   Timer? _hideTimer;
//
//   final Color kMehroon = const Color(0xFF77153C);
//
//   @override
//   void dispose() {
//     _hideTimer?.cancel();
//     _controller?.removeListener(_onControllerUpdate);
//     _controller?.dispose();
//     super.dispose();
//   }
//
//   void _onControllerUpdate() {
//     if (mounted) setState(() {});
//   }
//
//   // Starts loading the video only when the user taps play
//   Future<void> _startPlayback() async {
//     if (_loading || _initialized) return;
//
//     setState(() {
//       _started = true;
//       _loading = true;
//       _failed = false;
//       _showControls = true;
//     });
//
//     try {
//       final controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
//       _controller = controller;
//       await controller.initialize().timeout(
//         const Duration(seconds: 15),
//         onTimeout: () {
//           throw Exception('Timeout');
//         },);
//       if (!mounted) return;
//
//       setState(() {
//         _initialized = true;
//         _loading = false;
//       });
//       controller.addListener(_onControllerUpdate);
//       controller.setVolume(_isMuted ? 0 : 1);
//       await controller.play();
//       _autoHideControls();
//     }
//     catch (e) {
//       if (mounted) {
//         setState(() {
//           _failed = true;
//           _loading = false;
//         });
//       }
//     }
//   }
//
//   void _autoHideControls() {
//     _hideTimer?.cancel();
//     _hideTimer = Timer(const Duration(seconds: 3), () {
//       if (mounted && (_controller?.value.isPlaying ?? false)) {
//         setState(() => _showControls = false);
//       }
//     });
//   }
//
//   void _togglePlay() {
//     if (!_started) {
//       _startPlayback();
//       return;
//     }
//     final controller = _controller;
//     if (controller == null || !_initialized) return;
//
//     setState(() => _showControls = true);
//     if (controller.value.isPlaying) {
//       controller.pause();
//       _hideTimer?.cancel();
//     } else {
//       if (controller.value.position >= controller.value.duration) {
//         controller.seekTo(Duration.zero);
//       }
//       controller.play();
//       _autoHideControls();
//     }
//   }
//
//   void _toggleMute() {
//     final controller = _controller;
//     if (controller == null || !_initialized) return;
//     setState(() {
//       _isMuted = !_isMuted;
//       controller.setVolume(_isMuted ? 0 : 1);
//     });
//   }
//
//   String _formatDuration(Duration d) {
//     final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
//     final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
//     return "$m:$s";
//   }
//
//   Future<void> _openFullscreen() async {
//     if (_controller == null || !_initialized) return;
//     await Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (_) => FullscreenVideoPage(controller: _controller!),
//         fullscreenDialog: true,
//       ),
//     );
//     if (mounted) setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 200,
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.black,
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(15),
//         child: _buildContent(),
//       ),
//     );
//   }
//
//   Widget _buildContent() {
//     if (_failed) {
//       return GestureDetector(
//         onTap: () {
//           setState(() {
//             _failed = false;
//             _started = false;
//             _initialized = false;
//             _loading = false;
//           });
//         },
//         child: const Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.error_outline, color: Colors.white54, size: 36),
//               SizedBox(height: 6),
//               Text('Tap to retry',
//                   style: TextStyle(color: Colors.white54, fontSize: 12)),
//             ],
//           ),
//         ),
//       );
//     }
//
//     // 1. DEFAULT STATE: Only show play button (No video loaded yet)
//     if (!_started) {
//       return GestureDetector(
//         onTap: _startPlayback,
//         child: Container(
//           color: Colors.black,
//           child: Center(
//             child: Container(
//               width: 56, height: 56,
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.5),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
//             ),
//           ),
//         ),
//       );
//     }
//     // 2. LOADING STATE: Circular progress runs after click, before video is ready
//     // if (_loading) {
//     //   return Center(
//     //     child: Column(
//     //       mainAxisSize: MainAxisSize.min,
//     //       children: [
//     //         CircularProgressIndicator(color: kMehroon, strokeWidth: 2),
//     //         const SizedBox(height: 10),
//     //         const Text('Loading video…',
//     //             style: TextStyle(color: Colors.white70, fontSize: 12)),
//     //       ],
//     //     ),
//     //   );
//     // }
//
//     final controller = _controller!;
//
//     // 3. PLAYING STATE: Video and all controls
//     return GestureDetector(
//       onTap: () {
//         if(_initialized){setState(() => _showControls = !_showControls);
//         if (_showControls) _autoHideControls();
//         }
//       },
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           if(_initialized && controller != null)
//             FittedBox(
//               fit: BoxFit.cover,
//               child: SizedBox(
//                 width: controller.value.size.width,
//                 height: controller.value.size.height,
//                 child: VideoPlayer(controller),
//               ),
//             ),
//     const Center(
//     child: CircularProgressIndicator(color: Color(0xFF77153C), strokeWidth: 2),
//     ),
//   }
//           // Center Play/Pause Overlay
//           if (_showControls || (_initialized && !controller.value.isPlaying))
//             Center(
//               child: GestureDetector(
//                 onTap: _togglePlay,
//                 child: Container(
//                   width: 56, height: 56,
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.5),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     controller.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
//                     color: Colors.white, size: 40,
//                   ),
//                 ),
//               ),
//             ),
//
//           // Mute Button (Top Right)
//           if (_showControls)
//             Positioned(
//               top: 10, right: 10,
//               child: GestureDetector(
//                 onTap: _toggleMute,
//                 child: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.5),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white, size: 20),
//                 ),
//               ),
//             ),
//
//           // Bottom Controls Layer (Progress, Time, Fullscreen)
//           if (_showControls)
//             Positioned(
//               bottom: 0, left: 0, right: 0,
//               child: Container(
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.transparent, Colors.black54],
//                     begin: Alignment.topCenter, end: Alignment.bottomCenter,
//                   ),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Video Progress Indicator (Exactly like video.dart)
//                     VideoProgressIndicator(
//                       controller,
//                       allowScrubbing: true,
//                       colors: VideoProgressColors(
//                         playedColor: kMehroon,
//                         bufferedColor: Colors.white38,
//                         backgroundColor: Colors.white24,
//                       ),
//                       padding: const EdgeInsets.symmetric(vertical: 4),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             "${_formatDuration(controller.value.position)} / ${_formatDuration(controller.value.duration)}",
//                             style: const TextStyle(color: Colors.white, fontSize: 11),
//                           ),
//                           GestureDetector(
//                             onTap: _openFullscreen,
//                             child: const Icon(Icons.fullscreen, color: Colors.white, size: 24),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

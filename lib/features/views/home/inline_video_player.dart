// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'full_scre_video_page.dart';
//
// class InlineVideoPlayer extends StatefulWidget {
//   final String url;
//   final String? thumbnailUrl; // thumbnail to show when `endWithThumbnail` is true
//   final bool showDuration; // matches RN `showDuration`
//   final bool endWithThumbnail; // matches RN `endWithThumbnail`
//   final bool showMuteButton; // RN examples do not show mute by default
//   final double height;
//   final BorderRadius? borderRadius;
//   final VoidCallback? onLoadStart;
//   final VoidCallback? onLoaded;
//   final Function(Object error)? onError;
//
//   const InlineVideoPlayer({
//     Key? key,
//     required this.url,
//     this.thumbnailUrl,
//     this.showDuration = false,
//     this.endWithThumbnail = false,
//     this.showMuteButton = false,
//     this.height = 150,
//     this.borderRadius,
//     this.onLoadStart,
//     this.onLoaded,
//     this.onError,
//   }) : super(key: key);
//
//   @override
//   State<InlineVideoPlayer> createState() => _InlineVideoPlayerState();
// }
//
// class _InlineVideoPlayerState extends State<InlineVideoPlayer> {
//   VideoPlayerController? _controller;
//   bool _initialized = false;
//   bool _started = false;
//   bool _loading = false;
//   bool _failed = false;
//   bool _showControls = false;
//   bool _isMuted = false;
//   bool _ended = false;
//   Timer? _hideTimer;
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
//     final c = _controller;
//     if (!mounted) return;
//     // detect end-of-playback
//     try {
//       if (c != null && c.value.isInitialized) {
//         final pos = c.value.position;
//         final dur = c.value.duration;
//         if (dur != null &&
//             dur.inMilliseconds > 0 &&
//             pos != null &&
//             pos >= dur &&
//             !c.value.isPlaying) {
//           if (!_ended) setState(() => _ended = true);
//         }
//       }
//     } catch (_) {}
//     if (mounted) setState(() {});
//   }
//
//   Future<void> _startPlayback() async {
//     if (_loading || _initialized) return;
//     final cleanUrl =
//     widget.url.trim().replaceAll(RegExp(r'(?<!:)/{2,}'), '/');
//
//     setState(() {
//       _started = true;
//       _loading = true;
//       _failed = false;
//       _showControls = true;
//       _ended = false;
//     });
//     widget.onLoadStart?.call();
//
//     int retry = 0;
//     const maxRetries = 2;
//     while (retry <= maxRetries) {
//       try {
//         final controller =
//         VideoPlayerController.networkUrl(Uri.parse(cleanUrl));
//         _controller = controller;
//         await controller.initialize().timeout(
//           const Duration(seconds: 20),
//           onTimeout: () => throw Exception('Timeout'),
//         );
//         if (!mounted) return;
//         controller.addListener(_onControllerUpdate);
//         controller.setVolume(_isMuted ? 0 : 1);
//         setState(() {
//           _initialized = true;
//           _loading = false;
//           _failed = false;
//         });
//         await controller.play();
//         _autoHideControls();
//         widget.onLoaded?.call();
//         return;
//       } catch (e) {
//         retry++;
//         if (retry > maxRetries) {
//           if (mounted) {
//             setState(() {
//               _failed = true;
//               _loading = false;
//             });
//             widget.onError?.call(e);
//           }
//         } else {
//           await Future.delayed(const Duration(seconds: 1));
//         }
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
//     setState(() => _showControls = true);
//
//     if (_ended) {
//       // replay when ended
//       controller.seekTo(Duration.zero);
//       _ended = false;
//       controller.play();
//       _autoHideControls();
//       return;
//     }
//
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
//   String _formatDuration(Duration? d) {
//     if (d == null) return "00:00";
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
//     final borderRadius = widget.borderRadius ?? BorderRadius.circular(12);
//     return Container(
//       height: widget.height,
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.black,
//         borderRadius: borderRadius,
//       ),
//       child: ClipRRect(
//         borderRadius: borderRadius,
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
//             _ended = false;
//           });
//         },
//         child: Container(
//           color: Colors.black,
//           child: Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: const [
//                 Icon(Icons.error_outline, color: Colors.white54, size: 36),
//                 SizedBox(height: 6),
//                 Text('Tap to retry',
//                     style: TextStyle(color: Colors.white54, fontSize: 12)),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//
//     // initial (not started) state
//     if (!_started) {
//       return GestureDetector(
//         onTap: _startPlayback,
//         child: Container(
//           color: Colors.black,
//           child: Center(
//             child: Container(
//               width: 56,
//               height: 56,
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.5),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.play_arrow_rounded,
//                 color: Colors.white,
//                 size: 40,
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//
//     // if ended and RN-like endWithThumbnail requested
//     if (_ended && widget.endWithThumbnail && widget.thumbnailUrl != null) {
//       return GestureDetector(
//         onTap: () {
//           // replay from thumbnail
//           _togglePlay();
//         },
//         child: Stack(
//           fit: StackFit.expand,
//           children: [
//             Image.network(
//               widget.thumbnailUrl!,
//               fit: BoxFit.cover,
//               errorBuilder: (_, __, ___) => Container(color: Colors.black),
//             ),
//             Center(
//               child: Container(
//                 width: 56,
//                 height: 56,
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.5),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(Icons.play_arrow_rounded,
//                     color: Colors.white, size: 40),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     final controller = _controller;
//
//     return GestureDetector(
//       onTap: () {
//         if (_initialized) {
//           setState(() => _showControls = !_showControls);
//           if (_showControls) _autoHideControls();
//         }
//       },
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           // Video or spinner
//           if (_initialized && controller != null)
//             FittedBox(
//               fit: BoxFit.cover,
//               child: SizedBox(
//                 width: controller.value.size.width,
//                 height: controller.value.size.height,
//                 child: VideoPlayer(controller),
//               ),
//             )
//           else
//             const Center(
//               child: CircularProgressIndicator(
//                 color: Color(0xFF77153C),
//                 strokeWidth: 2,
//               ),
//             ),
//
//           // Center Play/Pause Overlay
//           if (_showControls || (_initialized && !(controller?.value.isPlaying ?? false)))
//             Center(
//               child: GestureDetector(
//                 onTap: _togglePlay,
//                 child: Container(
//                   width: 56,
//                   height: 56,
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.5),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     (_initialized && (controller?.value.isPlaying ?? false))
//                         ? Icons.pause_rounded
//                         : Icons.play_arrow_rounded,
//                     color: Colors.white,
//                     size: 40,
//                   ),
//                 ),
//               ),
//             ),
//
//           // optional mute button (hidden by default to match RN)
//           if (_showControls && widget.showMuteButton)
//             Positioned(
//               top: 10,
//               right: 10,
//               child: GestureDetector(
//                 onTap: _toggleMute,
//                 child: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.5),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     _isMuted ? Icons.volume_off : Icons.volume_up,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                 ),
//               ),
//             ),
//
//           // Bottom Controls Layer
//           if (_showControls)
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.transparent, Colors.black54],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     if (controller != null)
//                       VideoProgressIndicator(
//                         controller,
//                         allowScrubbing: _initialized,
//                         colors: VideoProgressColors(
//                           playedColor: kMehroon,
//                           bufferedColor: Colors.white38,
//                           backgroundColor: Colors.white24,
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 4),
//                       ),
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           // time / total (matches RN showDuration behavior when enabled)
//                           if (widget.showDuration && controller != null)
//                             Text(
//                               _initialized
//                                   ? "${_formatDuration(controller.value.position)} / ${_formatDuration(controller.value.duration)}"
//                                   : "00:00 / 00:00",
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 11,
//                               ),
//                             )
//                           else
//                             const SizedBox.shrink(),
//                           Row(
//                             children: [
//                               GestureDetector(
//                                 onTap: _openFullscreen,
//                                 child: const Icon(
//                                   Icons.fullscreen,
//                                   color: Colors.white,
//                                   size: 24,
//                                 ),
//                               ),
//                             ],
//                           )
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


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'full_scre_video_page.dart';

class InlineVideoPlayer extends StatefulWidget {
  final String url;
  final String? thumbnailUrl; // thumbnail to show when `endWithThumbnail` is true
  final bool showDuration; // matches RN `showDuration`
  final bool endWithThumbnail; // matches RN `endWithThumbnail`
  final bool showMuteButton;
  final double height;
  final BorderRadius? borderRadius;
  final VoidCallback? onLoadStart;
  final VoidCallback? onLoaded;
  final Function(Object error)? onError;

  const InlineVideoPlayer({
    super.key,
    required this.url,
    this.thumbnailUrl,
    this.showDuration = true,
    this.endWithThumbnail = false,
    this.showMuteButton = true,
    this.height = 150,
    this.borderRadius,
    this.onLoadStart,
    this.onLoaded,
    this.onError,
  });

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
  bool _ended = false;
  Timer? _hideTimer;

  // Progress bar / bottom-bar accent color, matches the reference design.
  static const Color _kProgressColor = Colors.red;

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    final c = _controller;
    if (!mounted) return;
    try {
      if (c != null && c.value.isInitialized) {
        final pos = c.value.position;
        final dur = c.value.duration;
        if (dur.inMilliseconds > 0 && pos >= dur && !c.value.isPlaying) {
          if (!_ended) setState(() => _ended = true);
        }
      }
    } catch (_) {}
    if (mounted) setState(() {});
  }

  Future<void> _startPlayback() async {
    if (_loading || _initialized) return;
    final cleanUrl =
    widget.url.trim().replaceAll(RegExp(r'(?<!:)/{2,}'), '/');

    setState(() {
      _started = true;
      _loading = true;
      _failed = false;
      _showControls = true;
      _ended = false;
    });
    widget.onLoadStart?.call();

    int retry = 0;
    const maxRetries = 2;
    while (retry <= maxRetries) {
      try {
        final controller =
        VideoPlayerController.networkUrl(Uri.parse(cleanUrl));
        _controller = controller;
        await controller.initialize().timeout(
          const Duration(seconds: 20),
          onTimeout: () => throw Exception('Timeout'),
        );
        if (!mounted) return;
        controller.addListener(_onControllerUpdate);
        controller.setVolume(_isMuted ? 0 : 1);
        setState(() {
          _initialized = true;
          _loading = false;
          _failed = false;
        });
        await controller.play();
        // Once playback actually starts, the big center icon hides itself
        // (see build logic below) and the bottom bar auto-hides after 3s.
        _autoHideControls();
        widget.onLoaded?.call();
        return;
      } catch (e) {
        retry++;
        if (retry > maxRetries) {
          if (mounted) {
            setState(() {
              _failed = true;
              _loading = false;
            });
            widget.onError?.call(e);
          }
        } else {
          await Future.delayed(const Duration(seconds: 1));
        }
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

    if (_ended) {
      controller.seekTo(Duration.zero);
      _ended = false;
      controller.play();
      _autoHideControls();
      return;
    }

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
    if (controller == null || !_initialized) return;
    setState(() {
      _isMuted = !_isMuted;
      controller.setVolume(_isMuted ? 0 : 1);
    });
  }

  String _formatDuration(Duration? d) {
    if (d == null) return "00:00";
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
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(12);
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
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
            _ended = false;
          });
        },
        child: Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.error_outline, color: Colors.white54, size: 36),
                SizedBox(height: 6),
                Text('Tap to retry',
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ),
      );
    }

    // Initial (not started) state — plain black background with one
    // centered play button.
    if (!_started) {
      return GestureDetector(
        onTap: _startPlayback,
        child: Container(
          color: Colors.black,
          child: Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ),
      );
    }

    if (_ended && widget.endWithThumbnail && widget.thumbnailUrl != null) {
      return GestureDetector(
        onTap: _togglePlay,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.thumbnailUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.black),
            ),
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 40),
              ),
            ),
          ],
        ),
      );
    }

    final controller = _controller;
    final isPlaying = _initialized && (controller?.value.isPlaying ?? false);

    return GestureDetector(
      onTap: () {
        if (!_started) {
          _startPlayback();
          return;
        }
        if (_initialized) {
          setState(() => _showControls = !_showControls);
          if (_showControls) _autoHideControls();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video or loading spinner
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
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),

          // Center play/pause overlay — only while paused or ended, NOT
          // while actively playing. This makes it disappear the instant
          // playback starts, per your requirement.
          if (_initialized && controller != null && !isPlaying)
            Center(
              child: GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),

          // Bottom pill-shaped control bar — single row, auto-hides after
          // 3s, reappears on tap.
          if (_showControls && _initialized && controller != null)
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _togglePlay,
                      child: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: VideoProgressIndicator(
                        controller,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: _kProgressColor,
                          bufferedColor: Colors.white38,
                          backgroundColor: Colors.white24,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    if (widget.showDuration) ...[
                      const SizedBox(width: 8),
                      Text(
                        "${_formatDuration(controller.value.position)} / ${_formatDuration(controller.value.duration)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                    if (widget.showMuteButton) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _toggleMute,
                        child: Icon(
                          _isMuted ? Icons.volume_off : Icons.volume_up,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _openFullscreen,
                      child: const Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                        size: 20,
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
//   bool _started = false;
//   bool _loading = false;
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
//   Future<void> _startPlayback() async {
//     if (_loading || _initialized) return;
//
//     // 1. Sanitize the URL (Common cause of inconsistency)
//     // Removes extra spaces and ensures no double slashes like "love/uploads//file.mp4"
//     String cleanUrl = widget.url.trim().replaceAll(RegExp(r'(?<!:)/{2,}'), '/');
//
//     debugPrint("--- Attempting Video Playback ---");
//     debugPrint("Original URL: ${widget.url}");
//     debugPrint("Cleaned URL: $cleanUrl");
//
//     setState(() {
//       _started = true;
//       _loading = true;
//       _failed = false;
//       _showControls = true;
//     });
//
//     int retryCount = 0;
//     const int maxRetries = 2; // Will try 3 times total
//
//     while (retryCount <= maxRetries) {
//       try {
//         final controller = VideoPlayerController.networkUrl(Uri.parse(cleanUrl));
//         _controller = controller;
//
//         // Use a shorter timeout per attempt (e.g., 20s) so retries happen faster
//         await controller.initialize().timeout(
//           const Duration(seconds: 20),
//           onTimeout: () => throw Exception('Timeout'),
//         );
//
//         if (!mounted) return;
//
//         setState(() {
//           _initialized = true;
//           _loading = false;
//         });
//
//         controller.addListener(_onControllerUpdate);
//         controller.setVolume(_isMuted ? 0 : 1);
//         await controller.play();
//         _autoHideControls();
//
//         debugPrint("Video initialized successfully on attempt ${retryCount + 1}");
//         return; // Success! Exit the function.
//
//       } catch (e) {
//         retryCount++;
//         debugPrint("Video attempt $retryCount failed: $e");
//
//         if (retryCount > maxRetries) {
//           if (mounted) {
//             setState(() {
//               _failed = true;
//               _loading = false;
//             });
//           }
//         } else {
//           // Wait a second before retrying
//           await Future.delayed(const Duration(seconds: 1));
//         }
//       }
//     }
//   }
//   // Future<void> _startPlayback() async {
//   //   if (_loading || _initialized) return;
//   //   setState(() {
//   //     _started = true;
//   //     _loading = true;
//   //     _failed = false;
//   //     _showControls = true; // Controls button dabate hi show ho jayenge
//   //   });
//   //
//   //   try {
//   //     final controller = VideoPlayerController.networkUrl(
//   //       Uri.parse(widget.url),
//   //     );
//   //     _controller = controller;
//   //
//   //     await controller.initialize().timeout(
//   //       const Duration(seconds: 40),
//   //       onTimeout: () => throw Exception('Timeout'),
//   //     );
//   //
//   //     if (!mounted) return;
//   //
//   //     setState(() {
//   //       _initialized = true;
//   //       _loading = false;
//   //     });
//   //
//   //     controller.addListener(_onControllerUpdate);
//   //     controller.setVolume(_isMuted ? 0 : 1);
//   //     await controller.play();
//   //     _autoHideControls();
//   //   } catch (e) {
//   //     if (mounted) {
//   //       setState(() {
//   //         _failed = true;
//   //         _loading = false;
//   //       });
//   //     }
//   //   }
//   // }
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
//     if (controller == null) return;
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
//         // child: const Center(
//         //   child: Column(
//         //     mainAxisSize: MainAxisSize.min,
//         //     children: [
//         //       Icon(Icons.error_outline, color: Colors.white54, size: 36),
//         //       SizedBox(height: 6),
//         //       Text('Tap to retry', style: TextStyle(color: Colors.white54, fontSize: 12)),
//         //     ],
//         //   ),
//         // ),
//       );
//     }
//
//     if (!_started) {
//       return GestureDetector(
//         onTap: _startPlayback,
//         child: Container(
//           color: Colors.black,
//           child: Center(
//             child: Container(
//               width: 56,
//               height: 56,
//               decoration: BoxDecoration(
//                 color: Colors.black.withValues(alpha: 0.5),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.play_arrow_rounded,
//                 color: Colors.white,
//                 size: 40,
//               ),
//             ),
//           ),
//         ),
//       );
//     }
//
//     final controller = _controller;
//
//     return GestureDetector(
//       onTap: () {
//         if (_initialized) {
//           setState(() => _showControls = !_showControls);
//           if (_showControls) _autoHideControls();
//         }
//       },
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           // 1. Video or Loading Spinner
//           if (_initialized && controller != null)
//             FittedBox(
//               fit: BoxFit.cover,
//               child: SizedBox(
//                 width: controller.value.size.width,
//                 height: controller.value.size.height,
//                 child: VideoPlayer(controller),
//               ),
//             )
//           else
//             const Center(
//               child: CircularProgressIndicator(
//                 color: Color(0xFF77153C),
//                 strokeWidth: 2,
//               ),
//             ),
//
//           // 2. Center Play/Pause Overlay
//           if (_showControls ||
//               (_initialized && !(_controller?.value.isPlaying ?? false)))
//             Center(
//               child: GestureDetector(
//                 onTap: _togglePlay,
//                 child: Container(
//                   width: 56,
//                   height: 56,
//                   decoration: BoxDecoration(
//                     color: Colors.black.withValues(alpha: 0.5),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     (_initialized && (_controller?.value.isPlaying ?? false))
//                         ? Icons.pause_rounded
//                         : Icons.play_arrow_rounded,
//                     color: Colors.white,
//                     size: 40,
//                   ),
//                 ),
//               ),
//             ),
//
//           // 3. Mute Button
//           if (_showControls)
//             Positioned(
//               bottom: 10,
//               right: 10,
//               child: GestureDetector(
//                 onTap: _toggleMute,
//                 child: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withValues(alpha: 0.5),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     _isMuted ? Icons.volume_off : Icons.volume_up,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                 ),
//               ),
//             ),
//
//           // 4. Bottom Controls Layer
//           if (_showControls)
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.transparent, Colors.black54],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     if (controller != null)
//                       VideoProgressIndicator(
//                         controller,
//                         allowScrubbing: _initialized,
//                         colors: VideoProgressColors(
//                           playedColor: kMehroon,
//                           bufferedColor: Colors.white38,
//                           backgroundColor: Colors.white24,
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 4),
//                       ),
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             _initialized && controller != null
//                                 ? "${_formatDuration(controller.value.position)} / ${_formatDuration(controller.value.duration)}"
//                                 : "00:00 / 00:00",
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 11,
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap: _openFullscreen,
//                             child: const Icon(
//                               Icons.fullscreen,
//                               color: Colors.white,
//                               size: 24,
//                             ),
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
//
//

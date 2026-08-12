import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:two_are_one/core/constants/app_colors.dart';
import 'package:two_are_one/core/widgets/containers.dart';
import 'package:two_are_one/core/widgets/my_icons.dart';
import 'package:two_are_one/features//views/main/question_screen.dart';
import 'package:two_are_one/features//views/main/video.dart';
import 'package:two_are_one/core/widgets/main_button_widget.dart';
import 'package:two_are_one/core/widgets/drop_down_field.dart';
import 'package:two_are_one/core/widgets/image.dart';
import 'package:two_are_one/core/widgets/texts.dart';
import 'package:two_are_one/data/models/user_profile_model.dart';
import 'package:two_are_one/data/services/Api_Helper/api_manager.dart';
import 'package:two_are_one/data/services/auth_service.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../../core/widgets/error_dialogue.dart';

class _PickedImage {
  final File file;
  final AssetEntity? asset; // null when it came from the camera
  const _PickedImage({required this.file, this.asset});
}

class ProfileSetupScreen extends StatefulWidget {
  final String? gender;
  final String? lookingFor;
  final UserProfileModel profileModel;

  const ProfileSetupScreen({
    super.key,
    this.gender,
    this.lookingFor,
    required this.profileModel,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _workController = TextEditingController();

  // ── Media ─────────────────────────────────────────────────────────────────
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  final List<File> _additionalVideos = [];
  String? _selectedHeight;
  String? _selectedWeight;
  bool _isLoading = false;
  bool _heightError = false;
  bool _weightError = false;
  bool _workError = false;
  bool _bioError = false;
  final AuthService _authService = AuthService();

  List<String> get _heightOptions => List.generate(33, (i) {
    final totalInches = 58 + i;
    final feet = totalInches ~/ 12;
    final inches = totalInches % 12;
    return "$feet'$inches";
  });
  List<String> get _weightOptions => List.generate(374, (i) => "${66 + i} lbs");
  // REMOVE these two:
  // final List<File> _additionalImages = [];
  // List<AssetEntity> _selectedAssets = [];

  // ADD this one:
  final List<_PickedImage> _additionalPicked = [];
  static const int _minBioLength = 5;

  // Convenience getters so the rest of your code barely changes:
  List<File> get _additionalImages =>
      _additionalPicked.map((e) => e.file).toList();

  List<AssetEntity> get _selectedAssets => _additionalPicked
      .where((e) => e.asset != null)
      .map((e) => e.asset!)
      .toList();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _syncToken();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _workController.dispose();
    super.dispose();
  }

  Future<void> _syncToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      // Force ApiManager to have the token before any request is made
      ApiManager.setUpRequestToken(token);
      debugPrint("Token synced in ProfileSetup: $token");
    } else {
      debugPrint("WARNING: No token found in ProfileSetup initState");
    }
  }

  Future<void> _onNextTapped() async {
    // 1. Validation
    setState(() {
      _heightError = _selectedHeight == null;
      _weightError = _selectedWeight == null;
      _workError = _workController.text.trim().isEmpty;
      _bioError = _bioController.text.trim().length < _minBioLength;
    });

    if (_heightError || _weightError || _workError || _bioError) return;

    setState(() => _isLoading = true);

    // 2. Call the Unified Upload Method
    final result = await _authService.uploadFullProfile(
      height: _selectedHeight!,
      weight: _selectedWeight!,
      work: _workController.text.trim(),
      bio: _bioController.text.trim(),
      gender: widget.profileModel.gender ?? '',
      sexuality: widget.profileModel.sexuality ?? '',
      profileImage: _profileImage,
      extraImages: _additionalImages,
      extraVideos: _additionalVideos,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      // 3. Save locally for the HomeScreen Banner
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'cached_screen_type',
        '2',
      ); // Move to Questionnaire stage
      await prefs.setString('profile_height', _selectedHeight!);
      await prefs.setString('profile_work', _workController.text.trim());
      await prefs.setString('profile_bio', _bioController.text.trim());

      // Note: The server will return the new image path in result['data']
      // We update our model with the file paths we have
      final updatedModel = widget.profileModel.copyWith(
        profileImage: _profileImage,
        additionalImages: List<File>.from(_additionalImages),
        additionalVideos: List<File>.from(_additionalVideos),
        height: _selectedHeight,
        weight: _selectedWeight,
        work: _workController.text.trim(),
        bio: _bioController.text.trim(),
      );

      // 4. Move to Questions
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuestionnaireScreen(profileModel: updatedModel),
        ),
      );
    } else {
      _showError(result['error'] ?? "Failed to upload profile info.");
    }
  }

  void _showError(String message, {String? title, bool allowRetry = false}) {
    CustomErrorAlert.show(
      context,
      title: title,
      message: message,
      action: allowRetry,
      onRetry: allowRetry ? _onNextTapped : null,
    );
  }

  Future<void> _pickMedia(int type) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            MainButtonWidget(
              text: type == 2 ? "Record Video" : "Take Photo",
              onTap: () async {
                Navigator.pop(context);
                // Wait for bottom sheet to fully close before opening camera
                await Future.delayed(const Duration(milliseconds: 300));
                if (mounted) _handleMediaSelection(type, ImageSource.camera);
              },
              gradient: const LinearGradient(
                colors: [Color(0xFF77153C), Color(0xFFDD276F)],
              ),
            ),
            const SizedBox(height: 15),

            MainButtonWidget(
              text: type == 2 ? "Upload Video" : "Upload from Gallery",
              onTap: () async {
                Navigator.pop(context);
                // Wait for bottom sheet to fully close before opening gallery
                await Future.delayed(const Duration(milliseconds: 300));
                if (mounted) _handleMediaSelection(type, ImageSource.gallery);
              },
              gradient: const LinearGradient(
                colors: [Color(0xFF77153C), Color(0xFFDD276F)],
              ),
            ),
            const SizedBox(height: 15),

            MainButtonWidget(
              text: "Cancel",
              onTap: () => Navigator.pop(context),
              gradient: const LinearGradient(
                colors: [Color(0xFF77153C), Color(0xFFDD226F)],
              ),
            ),
            const SizedBox(height: 65),
          ],
        ),
      ),
    );
  }

  Future<bool> _checkCameraPermission({required bool isVideo}) async {
    try {
      final cameraStatus = await Permission.camera.status;
      debugPrint("Camera status: $cameraStatus");

      if (cameraStatus == PermissionStatus.granted) {
        if (!isVideo) return true;
        // Also check microphone for video
        final micStatus = await Permission.microphone.status;
        if (micStatus == PermissionStatus.granted) return true;
        final micRequest = await Permission.microphone.request();
        if (micRequest == PermissionStatus.granted) return true;
        if (micRequest == PermissionStatus.permanentlyDenied) {
          _showPermissionDialog(
            "Microphone access is required to record videos.",
          );
          return false;
        }
        _showError("Microphone access is required for video recording.");
        return false;
      }

      final cameraRequest = await Permission.camera.request();
      if (cameraRequest == PermissionStatus.granted) {
        if (!isVideo) return true;
        final micRequest = await Permission.microphone.request();
        if (micRequest == PermissionStatus.granted) return true;
        if (micRequest == PermissionStatus.permanentlyDenied) {
          _showPermissionDialog(
            "Microphone access is required to record videos.",
          );
          return false;
        }
        _showError("Microphone access is required.");
        return false;
      }

      if (cameraRequest == PermissionStatus.permanentlyDenied) {
        _showPermissionDialog(
          "Camera access is required. Please enable it in settings.",
        );
        return false;
      }

      _showError("Camera access is required.");
      return false;
    } catch (e) {
      debugPrint("Camera permission error: $e");
      return true; // let picker try anyway
    }
  }

  // ── Permission dialog ─────────────────────────────────────────────────────
  void _showPermissionDialog(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Permission Required",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF77153C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await openAppSettings();
              },
              child: const Text(
                "Open Settings",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _handleMediaSelection(int type, ImageSource source) async {
    try {
      final isCamera = source == ImageSource.camera;
      final isVideo = type == 2;

      // Camera needs explicit permission check
      // Gallery + video gallery — image_picker handles it internally, skip check
      if (isCamera) {
        final granted = await _checkCameraPermission(isVideo: isVideo);
        if (!granted) return;
      }

      switch (type) {
        case 0: // Profile picture
          final XFile? picked = await _picker.pickImage(
            source: source,
            imageQuality: 85,
            maxWidth: 800,
          );
          if (picked != null && mounted) {
            setState(() => _profileImage = File(picked.path));
          }
          break;

        case 1: // Additional images
          if (isCamera) {
            if (_additionalPicked.length >= 5) {
              _showImageLimitDialog();
              return;
            }

            final XFile? picked = await _picker.pickImage(
              source: ImageSource.camera,
              imageQuality: 85,
              maxWidth: 800,
            );

            if (picked != null && mounted) {
              setState(() {
                _additionalPicked.add(_PickedImage(file: File(picked.path)));
              });
            }
          } else {
            if (_additionalPicked.length >= 5) {
              _showImageLimitDialog();
              return;
            }

            // How many slots gallery selection can use, given camera shots
            // already take some of the 5.
            final cameraCount = _additionalPicked
                .where((e) => e.asset == null)
                .length;
            final maxForGallery = 5 - cameraCount;

            final List<AssetEntity>? assets = await AssetPicker.pickAssets(
              context,
              pickerConfig: AssetPickerConfig(
                maxAssets: maxForGallery,
                selectedAssets:
                    _selectedAssets, // pre-checked, in sync with removals now
                requestType: RequestType.image,
              ),
            );

            if (assets != null && mounted) {
              final List<_PickedImage> galleryPicked = [];
              for (final asset in assets) {
                final file = await asset.file;
                if (file != null) {
                  galleryPicked.add(_PickedImage(file: file, asset: asset));
                }
              }

              setState(() {
                // Keep camera shots, replace gallery-sourced items with fresh selection
                _additionalPicked
                  ..removeWhere((e) => e.asset != null)
                  ..addAll(galleryPicked);
              });
            }
          }
          break;

        case 2: // Video
          // Both camera recording and gallery video —
          // camera already checked above, gallery handled by image_picker
          final XFile? picked = await _picker.pickVideo(
            source: source,
            maxDuration: const Duration(minutes: 5),
          );
          debugPrint("Video path: ${picked?.path}");
          if (picked != null && mounted) {
            setState(() => _additionalVideos.add(File(picked.path)));
          }
          break;
      }
    } catch (e) {
      debugPrint("Picker Error: $e");
      if (mounted) _showError("Something went wrong. Please try again.");
    }
  }

  void _showImageLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Limit Reached"),
        content: const Text("You can upload a maximum of 5 images."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _mediaActionButton(String title, String icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Containers(
        wWidth: 165,
        wHeight: 110,
        hexValue: 0xFFECECEC,
        radius: BorderRadius.circular(20),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Images(height: 40, width: 40, imageStr: icon),
            const SizedBox(height: 8),
            Texts(text: title, size: 14),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevents back navigation
      onPopInvoked: (didPop) {
        if (didPop) return;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
            child: Column(
              children: [
                // Header -------------------------------------------------------
                Images(
                  imageStr: 'assets/images/two_are_one.png',
                  height: 55,
                  width: 218,
                ),
                const Texts(
                  text:
                      "Increase Your Matches By Uploading\nYour Photos And Videos",
                  textAlign: TextAlign.center,
                  size: 12,
                  fontWeight: FontWeight.w400,
                ),
                const SizedBox(height: 25),
                Center(
                  child: Stack(
                    children: [
                      Containers(
                        wHeight: 120,
                        wWidth: 120,
                        padding: const EdgeInsets.all(2),
                        border: Border.all(
                          color: const Color(0xFFB0778E),
                          width: 2,
                        ),
                        hexValue: 0xFFFFFFFF,
                        opacityValue: 0,
                        radius: BorderRadius.circular(100),
                        alignment: Alignment.center,
                        child: ClipOval(
                          child: _profileImage != null
                              ? Image.file(
                                  _profileImage!,
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                )
                              : const Icon(
                                  Icons.person_outline_sharp,
                                  size: 80,
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 11,
                        right: 9,
                        child: GestureDetector(
                          onTap: () => _pickMedia(0),
                          child: Containers(
                            hexValue: 0xFFFFFFFF,
                            radius: BorderRadius.circular(17),
                            child: MyIcons(
                              iconData: Icons.add,
                              size: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Texts(
                  text: "Profile Picture",
                  size: 20,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 15),
                CustomDropdownField(
                  label: "Height",
                  imageStr: "assets/svg_images/height.svg",
                  value: _selectedHeight,
                  errorText: _heightError ? "Height is required" : null,
                  items: _heightOptions,
                  bgColor: AppColors.mehroon,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedHeight = value;
                      _heightError = false;
                    });
                  },
                ),
                // Weight dropdown ---------------------------------------------
                CustomDropdownField(
                  label: "Weight",
                  value: _selectedWeight,
                  imageStr: "assets/svg_images/weight.svg",
                  items: _weightOptions,
                  bgColor: AppColors.blue,
                  errorText: _weightError ? "Weight is required" : null,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedWeight = value;
                      _weightError = false;
                    });
                  },
                ),
                // Work field ---------------------------------------------------
                Align(
                  alignment: Alignment.centerLeft,
                  child: Texts(
                    edgeInsets: const EdgeInsets.only(bottom: 10),
                    text: "Work",
                    size: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextField(
                  controller: _workController, // FIX: wired controller
                  onChanged: (_) {
                    setState(() => _workError = false);
                  },
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 10,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF3F3F3),
                    hintText: "Write about your work",
                    hintStyle: const TextStyle(fontSize: 12),
                  ),
                ),
                if (_workError)
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Work is required",
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ),
                // Bio field ----------------------------------------------------
                Align(
                  alignment: Alignment.centerLeft,
                  child: Texts(
                    edgeInsets: const EdgeInsets.only(top: 5, bottom: 10),
                    text: "Bio",
                    size: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Containers(
                  wHeight: 150,
                  hexValue: 0xFFF3F3F3,
                  radius: BorderRadius.circular(20),
                  alignment: Alignment.topCenter,
                  child: TextField(
                    controller: _bioController, // FIX: wired controller
                    maxLength: 250,
                    maxLines: 4,
                    onChanged: (value) => setState(
                      () => _bioError = value.trim().length < _minBioLength,
                    ), // clear on type
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF484848),
                    ),
                    decoration: const InputDecoration(
                      counterStyle: TextStyle(color: Color(0xFF77153C)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                      hintText:
                          "Tell us something about yourself in 250 characters or less",
                      hintStyle: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                if (_bioError)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _bioController.text.trim().isEmpty
                            ? "Bio is required"
                            : "Bio must be at least $_minBioLength characters",
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _mediaActionButton(
                      "Add Photos",
                      "assets/svg_images/add_photo.svg",
                      () => _pickMedia(1),
                    ),
                    Spacer(),
                    _mediaActionButton(
                      "Add Videos",
                      "assets/svg_images/add_video.svg",
                      () => _pickMedia(2),
                    ),
                  ],
                ),
                if (_additionalImages.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Texts(
                      text: "Selected Images",
                      fontWeight: FontWeight.bold,
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _additionalPicked.asMap().entries.map((entry) {
                      return _buildMediaPreview(
                        entry.value.file,
                        () => setState(
                          () => _additionalPicked.removeAt(entry.key),
                        ),
                        isVideo: false,
                      );
                    }).toList(),
                  ),
                ],
                // Video previews -----------------------------------------------
                if (_additionalVideos.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Texts(
                      text: "Selected Videos",
                      fontWeight: FontWeight.bold,
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: _additionalVideos.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildMediaPreview(
                          entry.value,
                          () => setState(
                            () => _additionalVideos.removeAt(entry.key),
                          ),
                          isVideo: true,
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 40),
                // Next button --------------------------------------------------
                MainButtonWidget(
                  text: "Next",
                  isLoading: _isLoading,
                  onTap: _isLoading ? null : _onNextTapped,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF77153C), Color(0xFFDD276F)],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaPreview(
    File file,
    VoidCallback onRemove, {
    required bool isVideo,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        isVideo
            ? VideoPreviewCard(file: file)
            : Containers(
                wWidth: 100,
                wHeight: 100,
                radius: BorderRadius.circular(15),
                hexValue: 0xFFECECEC,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(file, fit: BoxFit.cover),
                ),
              ),
        Positioned(
          top: -5,
          right: -5,
          child: GestureDetector(
            onTap: onRemove,
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 12,
              child: Icon(Icons.cancel, color: Colors.red, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}

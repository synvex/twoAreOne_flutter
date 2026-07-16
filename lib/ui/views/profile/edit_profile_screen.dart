// lib/features/Screens/edit_profile_screen.dart
//
// Flutter port of the React Native `EditProfileScreen` (index.js).
//
// State-management choice: plain StatefulWidget + setState, matching the
// rest of this codebase's screens (see ProfileScreen, CategoryQuestionsScreen,
// SignUpPage) rather than introducing Provider/Riverpod/Bloc just for this
// one screen.
//
// Notes on things that are intentionally NOT a 1:1 port because RN's
// original code has quirks that don't make sense to reproduce literally:
//  - RN's height/weight/age/gender <DropdownComponent> is *uncontrolled*
//    (its own local `value` state, unrelated to the `value` prop); it only
//    fakes "already selected" by formatting the prop into `placeholder`.
//    Flutter's DropdownButtonFormField is properly controlled, so we just
//    set `value:` directly — no formatHeight() placeholder hack needed.
//  - RN's `removingIndex` is a single int (not a set), so only the most
//    recently-tapped image gets the fading "Removing…" animation even if
//    multiple removals were in flight. Reproduced as-is below for fidelity.
//  - RN's bottom sheet always passes `multiple: mode === false` to the
//    picker, which is *always* false (mode is the string "image"/"video",
//    never the boolean `false`), so multi-select never actually engages —
//    reproduced as always-single-select.
//  - react-native-image-crop-picker's `cropping` step has no equivalent in
//    `image_picker` (would need `image_cropper`), so photo/video picking
//    below skips the crop step. Everything else (compression quality 0.7,
//    max 1000x1000, camera/gallery/cancel sheet, permission prompt copy) is
//    reproduced exactly.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:two_are_one/core/image.dart';
import 'package:two_are_one/ui/views/bottom_nav/profile_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:two_are_one/core/back_button.dart';
import 'package:two_are_one/core/buttons.dart';
import 'package:two_are_one/core/texts.dart';
import 'package:two_are_one/core/top_toast.dart';
import 'package:two_are_one/data/models/location_data.dart';
import 'package:two_are_one/data/models/user_full_profile.dart';
import 'package:two_are_one/data/services/profiles_services.dart';
import 'package:two_are_one/ui/views/home/category_questions_screen.dart';
import 'package:two_are_one/ui/views/home/inline_video_player.dart';
import 'package:two_are_one/ui/views/main/location_selector.dart';

const String kEditProfileUploadBase = "https://www.twoareone.love/uploads/";
const Color _kGradientStart = Color(0xFFB06A82);
const Color _kGradientEnd = Color(0xFF84A2D4);
const Color _kMehroon = Color(0xFF77153C);

const Color _kCardBorder = Color(0xFFE3E3E3);
const Color _kFieldBorder = Color(0xFFDCDCDC);
const Color _kFieldText = Color(0xFF9B9B9B);
const Color _kIconCircleBg = Color(0xFFD9D9D9);

class _DropdownOption {
  final String label;
  final String value;
  const _DropdownOption(this.label, this.value);
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _ImageEntry {
  final int? id;
  final String? networkUrl;
  final File? localFile;
  final bool uploading;

  _ImageEntry({this.id, this.networkUrl, this.localFile, this.uploading = false});
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  final ProfileService _profileService = ProfileService();
  final ImagePicker _picker = ImagePicker();

  bool _loadingUser = true;
  UserFullProfile? _user;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _workController = TextEditingController();

  String? _selectedGender;
  String? _selectedAge;
  String? _selectedHeight;
  String? _selectedWeight;

  LocationData? _pickedLocation;

  File? _pickedAvatarFile;
  bool _avatarUploading = false;

  final List<_ImageEntry> _imageEntries = [];
  // RN: `removingIndex` — a single index, not a set (see file header note).
  int? _removingIndex;
  late final AnimationController _fadeController;

  ProfileMediaVideo? _existingVideo;
  File? _pickedVideoFile;
  bool _videoUploading = false;
  bool _removingVideo = false;

  bool _saving = false;

  String _nameError = '';
  String _workError = '';
  String _bioError = '';
  // ── dropdown option lists — mirrors RN's global/constants.js exactly ────
  static const List<_DropdownOption> _genderOptions = [
    _DropdownOption('Male', 'male'),
    _DropdownOption('Female', 'female'),
  ];

  static List<_DropdownOption> get _ageOptions => List.generate(88, (i) {
    final age = '${i + 13}';
    return _DropdownOption(age, age);
  });

  static const List<_DropdownOption> _heightOptions = [
    _DropdownOption("4'10", '4.10'),
    _DropdownOption("4'11", '4.11'),
    _DropdownOption("5'0", '5.0'),
    _DropdownOption("5'1", '5.1'),
    _DropdownOption("5'2", '5.2'),
    _DropdownOption("5'3", '5.3'),
    _DropdownOption("5'4", '5.4'),
    _DropdownOption("5'5", '5.5'),
    _DropdownOption("5'6", '5.6'),
    _DropdownOption("5'7", '5.7'),
    _DropdownOption("5'8", '5.8'),
    _DropdownOption("5'9", '5.9'),
    _DropdownOption("5'10", '5.10'),
    _DropdownOption("5'11", '5.11'),
    _DropdownOption("6'0", '6.0'),
    _DropdownOption("6'1", '6.1'),
    _DropdownOption("6'2", '6.2'),
    _DropdownOption("6'3", '6.3'),
    _DropdownOption("6'4", '6.4'),
    _DropdownOption("6'5", '6.5'),
    _DropdownOption("6'6", '6.6'),
    _DropdownOption("6'7", '6.7'),
    _DropdownOption("6'8", '6.8'),
    _DropdownOption("6'9", '6.9'),
    _DropdownOption("6'10", '6.10'),
    _DropdownOption("6'11", '6.11'),
    _DropdownOption("7'0", '7.0'),
    _DropdownOption("7'1", '7.1'),
    _DropdownOption("7'2", '7.2'),
    _DropdownOption("7'3", '7.3'),
    _DropdownOption("7'4", '7.4'),
    _DropdownOption("7'5", '7.5'),
    _DropdownOption("7'6", '7.6'),
  ];

  static List<_DropdownOption> get _weightOptions =>
      List.generate(440 - 66 + 1, (i) {
        final weight = 66 + i;
        return _DropdownOption('$weight lbs', '$weight');
      });

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _workController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final res = await _profileService.getUserInfo();
    if (!mounted) return;

    if (res['success'] == true && res['data'] is Map) {
      final user =
      UserFullProfile.fromJson((res['data'] as Map).cast<String, dynamic>());
      setState(() {
        _user = user;
        _nameController.text = user.fullName;
        _bioController.text = user.bio;
        _workController.text = user.work;
        _selectedGender = user.gender.isNotEmpty ? user.gender.toLowerCase() : null;
        _selectedAge = user.age.isNotEmpty ? user.age : null;
        _selectedHeight = user.height.isNotEmpty ? user.height : null;
        _selectedWeight = user.weight.isNotEmpty ? user.weight : null;
        _existingVideo = user.userVideo;
        _imageEntries
          ..clear()
          ..addAll(user.allImages.map((img) => _ImageEntry(
            id: img.id,
            networkUrl: _fullUrl(img.url),
          )));
        _loadingUser = false;
      });
    } else {
      setState(() => _loadingUser = false);
      TopToast.show(
        context,
        title: "Couldn't load profile",
        message: "Please check your connection.",
        type: ToastType.error,
      );
    }
  }

  String _fullUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return path.startsWith('http') ? path : '$kEditProfileUploadBase$path';
  }
  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;

    if (status.isDenied || status.isPermanentlyDenied) {
      // RN shows an Alert with Cancel / Grant Access before re-requesting.
      final proceed = await _showPermissionAlert();
      if (!proceed) return false;
      final result = await Permission.camera.request();
      return result.isGranted;
    }

    final result = await Permission.camera.request();
    return result.isGranted;
  }

  Future<bool> _showPermissionAlert() async {
    if (!mounted) return false;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text("Camera access is required to take photos."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Grant Access"),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ── profile picture (RN: handleProfileImage / uploadUserProfilePicture) ─

  Future<void> _uploadAvatar(File file) async {
    setState(() {
      _pickedAvatarFile = file; // optimistic preview, same as RN
      _avatarUploading = true;
    });
    final res = await _profileService.uploadProfilePicture(file);
    if (!mounted) return;
    setState(() => _avatarUploading = false);
    if (res['success'] != true) {
      TopToast.show(
        context,
        title: "Error",
        message: res['error']?.toString() ??
            "Something went wrong while uploading",
        type: ToastType.error,
      );
    }
  }

  void _pickAvatar() {
    // RN's edit screen reuses the single generic photo/video bottom sheet
    // for the avatar too (mode:"image", type:"profile"), so labels are the
    // generic "Camera"/"Upload Image".
    _openMediaSheet(
      isVideo: false,
      onCamera: () async {
        if (!await _requestCameraPermission()) return;
        final shot = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 70,
          maxWidth: 1000,
          maxHeight: 1000,
        );
        if (shot != null) _uploadAvatar(File(shot.path));
      },
      onGallery: () async {
        final picked = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
          maxWidth: 1000,
          maxHeight: 1000,
        );
        if (picked != null) _uploadAvatar(File(picked.path));
      },
    );
  }

  Future<void> _addImage(File file) async {
    setState(() => _imageEntries.add(
      _ImageEntry(localFile: file, uploading: true),
    ));

    final res = await _profileService.addUserPhoto(file);
    if (!mounted) return;

    if (res['success'] == true) {
      // RN: `dispatch(setRefreshProfile(!refresh))` — re-fetch so the new
      // photo gets its real server id/url.
      await _loadUser();
    } else {
      setState(() {
        _imageEntries.removeWhere((e) => e.uploading);
      });
      TopToast.show(
        context,
        title: "Error",
        message: res['error']?.toString() ?? "Something went wrong",
        type: ToastType.error,
      );
    }
  }

  Future<void> _removeImage(_ImageEntry entry, int index) async {
    if (entry.id == null) return;
    setState(() => _removingIndex = index);

    final success = await _profileService.removeUserPhoto(entry.id!);
    if (!mounted) return;

    setState(() => _removingIndex = null);
    if (success) {
      setState(() => _imageEntries.removeWhere((e) => e.id == entry.id));
    } else {
      TopToast.show(context, title: "Error", type: ToastType.error);
    }
  }

  void _pickAdditionalImage() {
    if (_imageEntries.length == 6) {
      // RN: Alert.alert("You can only attach 6 pictures")
      TopToast.show(
        context,
        title: "You can only attach 6 pictures",
        type: ToastType.info,
      );
      return;
    }
    _openMediaSheet(
      isVideo: false,
      onCamera: () async {
        if (!await _requestCameraPermission()) return;
        final shot = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 70,
          maxWidth: 1000,
          maxHeight: 1000,
        );
        if (shot != null) _addImage(File(shot.path));
      },
      onGallery: () async {
        final picked = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
          maxWidth: 1000,
          maxHeight: 1000,
        );
        if (picked != null) _addImage(File(picked.path));
      },
    );
  }

  Future<void> _addVideo(File file) async {
    setState(() {
      _pickedVideoFile = file;
      _videoUploading = true;
    });

    final res = await _profileService.addUserVideo(file);
    if (!mounted) return;

    if (res['success'] == true) {
      await _loadUser(); // re-syncs `_existingVideo`
      if (!mounted) return;
      setState(() {
        _pickedVideoFile = null;
        _videoUploading = false;
      });
    } else {
      setState(() {
        _pickedVideoFile = null;
        _videoUploading = false;
      });
      TopToast.show(
        context,
        title: "Error",
        message: res['error']?.toString() ?? "Something went wrong",
        type: ToastType.error,
      );
    }
  }

  Future<void> _removeVideo() async {
    final video = _existingVideo;
    if (video == null) return;
    setState(() => _removingVideo = true);

    final success = await _profileService.removeUserVideo(video.id);
    if (!mounted) return;

    setState(() => _removingVideo = false);
    if (success) {
      setState(() => _existingVideo = null);
    } else {
      TopToast.show(context, title: "Error", type: ToastType.error);
    }
  }

  void _pickVideo() {
    if (_existingVideo != null || _pickedVideoFile != null) {
      // RN: Alert.alert("You can attach only one video")
      TopToast.show(
        context,
        title: "You can attach only one video",
        type: ToastType.info,
      );
      return;
    }
    _openMediaSheet(
      isVideo: true,
      onCamera: () async {
        if (!await _requestCameraPermission()) return;
        final shot = await _picker.pickVideo(source: ImageSource.camera);
        if (shot != null) _addVideo(File(shot.path));
      },
      onGallery: () async {
        final picked = await _picker.pickVideo(source: ImageSource.gallery);
        if (picked != null) _addVideo(File(picked.path));
      },
    );
  }
  void _openMediaSheet({
    required bool isVideo,
    required Future<void> Function() onCamera,
    required Future<void> Function() onGallery,
  })
  {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(48)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Buttons(
                text: isVideo ? "Record Video" : "Camera",
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await Future.delayed(const Duration(milliseconds: 250));
                  if (mounted) await onCamera();
                },
                gradient:
                const LinearGradient(colors: [_kMehroon, Color(0xFFDD276F)]),
              ),
              const SizedBox(height: 15),
              Buttons(
                text: isVideo ? "Upload Video" : "Upload Image",
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await Future.delayed(const Duration(milliseconds: 250));
                  if (mounted) await onGallery();
                },
                gradient:
                const LinearGradient(colors: [_kMehroon, Color(0xFFDD276F)]),
              ),
              const SizedBox(height: 15),
              Buttons(
                text: "Cancel",
                onTap: () => Navigator.pop(sheetContext),
                gradient:
                const LinearGradient(colors: [_kMehroon, Color(0xFFDD226F)]),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  bool _validate() {
    final nameOk = RegExp(r'^[A-Za-z\s]+$').hasMatch(_nameController.text.trim());
    final workOk =
    RegExp(

        // r'^[\s\S]*$'
        r"^[a-zA-Z0-9\s,.'-]+$"
    ).hasMatch(_workController.text);
    if ((_pickedLocation?.state ?? _user?.state ?? '').isEmpty) {
      TopToast.show(context, title: "Error", message: "Please select a location with a valid state");
      return false;
    }
    final bioOk = RegExp(r"^[a-zA-Z0-9\s,.'-]+$").hasMatch(_bioController.text);
    // final bioOk = RegExp(r'^[\s\S]*$').hasMatch(_bioController.text);

    setState(() {
      _nameError = nameOk ? '' : "Name can only contain letters and spaces";
      _workError = workOk ? '' : "Work must not contain special characters";
      _bioError = bioOk ? '' : "Bio must not contain special characters";
    });
    debugPrint("nameOk: $nameOk, workOk: $workOk, bioOk: $bioOk");
    return nameOk && workOk && bioOk;

  }
  Future<void> _onUpdate() async {
    if (!_validate()) return;

    setState(() => _saving = true);

    final payload = {
      "bio": _bioController.text,
      "full_name": _nameController.text,
      "country": _pickedLocation?.country ?? _user?.country ?? '',
      "state": _pickedLocation?.state ?? _user?.state ?? '',
      "city": _pickedLocation?.city ?? _user?.city ?? '',
      "gender": _selectedGender,
      "height": _selectedHeight,
      "age": _selectedAge,
      "weight": _selectedWeight,
      "work": _workController.text,
    };

    print("Payload: $payload");
    final res = await _profileService.updateUserProfile(payload);
    debugPrint("Response: $res");
    if (!mounted) return;

    if (res['success'] == true) {
      await _loadUser();
      if (!mounted) return;

      setState(() => _saving = false);
      TopToast.show(
        context,
        title: "Success",
        message: "User Information Updated Successfully",
        type: ToastType.success,
      );
    } else {
      setState(() => _saving = false);
      TopToast.show(
        context,
        title: "Error",
        message: res['error']?.toString() ??
            "Something went wrong while uploading",
        type: ToastType.error,
      );
    }
  }
  //
  // Future<void> _onUpdate() async {
  //   if (!_validate()) return;
  //
  //   setState(() => _saving = true);
  //   final payload = {
  //     "bio": _bioController.text,
  //     "full_name": _nameController.text,
  //     "country": _pickedLocation?.country ?? _user?.country ?? '',
  //     "state": _pickedLocation?.state ?? _user?.state ?? '',
  //     "city": _pickedLocation?.city ?? _user?.city ?? '',
  //     "gender": _selectedGender,
  //     "height": _selectedHeight,
  //     "age": _selectedAge,
  //     "weight": _selectedWeight,
  //     "work": _workController.text,
  //   };
  //   print("Payload: $payload");
  //   final res = await _profileService.updateUserProfile(
  //       payload);
  //   debugPrint("Response: $res");
  //   if (!mounted) return;
  //   setState(() => _saving = false);
  //   if (res['success'] == true) {
  //     TopToast.show(
  //       context,
  //       title: "Success",
  //       message: "User Information Updated Successfully",
  //       type: ToastType.success,
  //     );
  //   } else {
  //     TopToast.show(
  //       context,
  //       title: "Error",
  //       message:
  //       res['error']?.toString() ?? "Something went wrong while uploading",
  //       type: ToastType.error,
  //     );
  //   }
  // }

  void _onPressCategory(dynamic category) {
    final userId = _user?.id ?? 0;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CategoryQuestionsScreen(
        categoryId: category.categoryId,
        categoryName: category.categoryName,
        userId: userId,
        editable: true, // RN: navigate params `{ isEdit: true, cat: category }`
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingUser) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: _kMehroon)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildAvatarSection(),
                    const SizedBox(height: 35),

                    // ── "About Me" card ──────────────────────────────────
                    _sectionCard(
                      title: "About Me",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _bioController,
                            maxLength: 250,
                            maxLines: 5,
                            textAlignVertical: TextAlignVertical.top,
                            onChanged: (_) => setState(() => _bioError = ''),
                            style: const TextStyle(fontSize: 14, color: _kFieldText),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              counterText: '',
                              hintText: "Tell us something about yourself",
                              hintStyle: TextStyle(fontSize: 14, color: _kFieldText),
                            ),
                          ),
                          if (_bioError.isNotEmpty) _errorText(_bioError),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    _fieldLabel("Full Name"),
                    _outlinedField(
                      controller: _nameController,
                      icon: 'assets/svg_images/Profile/profile_circular.svg',
                      maxLength: 50,
                      keyboardType: TextInputType.name,
                      onChanged: (_) => setState(() => _nameError = ''),
                    ),
                    if (_nameError.isNotEmpty) _errorText(_nameError),

                    const SizedBox(height: 20),
                    _fieldLabel("Location"),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: _kFieldBorder),
                      ),
                      child: LocationSelectorField(
                        labels: (_user?.city.isNotEmpty == true &&
                            _user?.country.isNotEmpty == true)
                            ? "${_user?.city},${_user?.country}"
                            : "Search location",
                        fillColor: 0xFFFFFFFF,
                        // initialText: (_user?.city.isNotEmpty == true &&
                        //     _user?.country.isNotEmpty == true)
                        //     ? "${_user?.city},${_user?.country}"
                        //     : null,
                        onLocationSelected: (loc) =>
                            setState(() => _pickedLocation = loc),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── "Personal Info" card ─────────────────────────────
                    _sectionCard(
                      title: "Personal Info",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _fieldLabel("Gender", padBottom: 6),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _fieldLabel("Age", padBottom: 6),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown(
                                  hint: "Gender",
                                  value: _selectedGender,
                                  items: _genderOptions,
                                  onChanged: (v) =>
                                      setState(() => _selectedGender = v),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildDropdown(
                                  hint: "Age",
                                  value: _selectedAge,
                                  items: _ageOptions,
                                  onChanged: (v) =>
                                      setState(() => _selectedAge = v),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _fieldLabel("Height", padBottom: 6),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _fieldLabel("Weight", padBottom: 6),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown(
                                  hint: "Height",
                                  value: _selectedHeight,
                                  items: _heightOptions,
                                  onChanged: (v) =>
                                      setState(() => _selectedHeight = v),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildDropdown(
                                  hint: "Weight",
                                  value: _selectedWeight,
                                  items: _weightOptions,
                                  onChanged: (v) =>
                                      setState(() => _selectedWeight = v),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _fieldLabel("Work"),
                          Container(
                            width: double.infinity,

                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _kFieldBorder),
                            ),
                            child: TextField(
                              controller: _workController,
                              maxLength: 100,
                              maxLines: 3,
                              onChanged: (_) => setState(() => _workError = ''),
                              style: const TextStyle(fontSize: 15, color: _kFieldText),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                counterText: '',
                                hintText: "Enter your work",
                                hintStyle:
                                TextStyle(fontSize: 14, color: _kFieldText),
                              ),
                            ),
                          ),
                          if (_workError.isNotEmpty) _errorText(_workError),
                          SizedBox(height: 8,)
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    _buildUpdateButton(),

                    const SizedBox(height: 24),
                    _buildMediaSection(),

                    const SizedBox(height: 24),
                    _buildQuestionsSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Back_Button(onTap: () { Navigator.push(context,
              MaterialPageRoute(builder: (
                  context) => ProfileScreen(),)); }),
          SizedBox(width: 110,),
          const Text(
            "Edit Profile",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
          ),
          Divider(height: 1, thickness: 1, color: _kCardBorder),
          Padding(
            padding: const EdgeInsets.all(8),
            child: child,
          ),
        ],
      ),
    );
  }
  /// Plain (non-card) label used above outlined fields, e.g. "Full Name".
  Widget _fieldLabel(String text, {double padBottom = 8}) => Padding(
    padding: EdgeInsets.only(bottom: padBottom, top: 4),
    child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
  );
  Widget _errorText(String message) => Padding(
    padding: const EdgeInsets.only(left: 16, top: 4),
    child: Text(message, style: const TextStyle(color: Colors.red, fontSize: 12)),
  );
  Widget _outlinedField({
    required TextEditingController controller,
    // required String hint,
    required String icon,
    int? maxLength,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  })
  {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: _kFieldText),
      decoration: InputDecoration(
        counterText: '',
        hintStyle: const TextStyle(fontSize: 14, color: _kFieldText),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        prefixIconConstraints: const BoxConstraints(minWidth: 46),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: CircleAvatar(
            radius: 12,
            backgroundColor: Colors.white,
            child:Images(imageStr: icon, height: 30, width: 30, ),
          ),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: _kFieldBorder),
          borderRadius: BorderRadius.circular(30),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: _kFieldBorder),
          borderRadius: BorderRadius.circular(30),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: _kFieldBorder),
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
  Widget _buildAvatarSection() {
    final avatarUrl = _fullUrl(_user?.profilePicture);
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 120,
            height: 120,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.withOpacity(0.3), width: 4),
            ),
            child: ClipOval(
              child: _avatarUploading
                  ? const Center(child: CircularProgressIndicator(color: _kMehroon))
                  : _pickedAvatarFile != null
                  ? Image.file(_pickedAvatarFile!, fit: BoxFit.cover)
                  : (avatarUrl.isNotEmpty
                  ? Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, e, s) =>
                const Icon(Icons.person_outline_sharp, size: 80),
              )
                  : const Icon(Icons.person_outline_sharp, size: 80)),
            ),
          ),
          Positioned(
            bottom: -4,
            right: 8,
            child: GestureDetector(
              onTap: _pickAvatar,
              child: Container(
                  height: 43,
                  width: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Images(
                      imageStr: "assets/svg_images/Profile/addImageCamera.svg")
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<_DropdownOption> items,
    required ValueChanged<String?> onChanged,
  })
  {
    final safeValue =
    (value != null && items.any((o) => o.value == value)) ? value : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _kFieldBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          value: safeValue,
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(fontSize: 14, color: _kFieldText)),
          icon: const Icon(Icons.arrow_drop_down, color: _kFieldText),
          menuMaxHeight: 300,
          style: const TextStyle(fontSize: 14, color: _kFieldText),
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
          items: items
              .map((opt) => DropdownMenuItem(
            value: opt.value,
            child: Text(opt.label, style: const TextStyle(fontSize: 14, color: _kFieldText)),
          ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
  Widget _buildUpdateButton() {
    return Buttons(
      text: "Update",
      isLoading: _saving,
      onTap: _onUpdate,
      gradient: const LinearGradient(colors: [_kGradientStart, _kGradientEnd]),
      width: 160,
      height: 47,

    );
  }
  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _mediaActionButton(
                  'assets/svg_images/add_photo.svg', "Add Photos", _pickAdditionalImage),
            ),
            const SizedBox(width: 35),
            Expanded(
              child: _mediaActionButton(
                  "assets/svg_images/add_video.svg", "Add Videos", _pickVideo),
            ),
          ],
        ),
        if (_imageEntries.isNotEmpty) ...[
          const SizedBox(height: 15),
          const Text("Selected Images",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _imageEntries.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final entry = _imageEntries[index];
                final removing = _removingIndex == index;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: entry.localFile != null
                          ? Image.file(entry.localFile!,
                          width: 100, height: 100, fit: BoxFit.cover)
                          : Image.network(
                        entry.networkUrl ?? '',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                            width: 100, height: 100, color: const Color(0xFFECECEC)),
                      ),
                    ),
                    if (entry.uploading)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              ),
                              SizedBox(height: 4),
                              Text("Uploading...",
                                  style: TextStyle(color: Colors.white, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    if (removing)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: FadeTransition(
                            opacity: _fadeController,
                            child: const Text(
                              "Removing...",
                              style: TextStyle(color: Colors.white, fontSize: 11),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    if (!entry.uploading && !removing)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: () => _removeImage(entry, index),
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.close, size: 16, color: Colors.red),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
        if (_existingVideo != null || _pickedVideoFile != null) ...[
          const SizedBox(height: 20),
          const Text("Selected Video",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: 300,
                height: 180,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _pickedVideoFile != null
                      ? _LocalVideoPreview(file: _pickedVideoFile!)
                      : InlineVideoPlayer(
                    url: _fullUrl(_existingVideo?.url),
                  ),
                ),
              ),
              if (_videoUploading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 8),
                        Text("Uploading video...", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              if (!_videoUploading)
                Positioned(
                  top: -6,
                  right: -6,
                  child: GestureDetector(
                    onTap: _removingVideo ? null : _removeVideo,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.white,
                      child: _removingVideo
                          ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.close, size: 16, color: Colors.red),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
  Widget _mediaActionButton(String icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,

        decoration: BoxDecoration(
          color: const Color(0xFFECECEC),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Images(imageStr: icon, height: 42, width: 42),
            // Icon(icon, size: 32, color: _kMehroon),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
  Widget _buildQuestionsSection() {
    final categories = _user?.categories ?? [];
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("Manage Questions",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        const SizedBox(height: 20),
        ...categories.map((category) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              Texts(text: category.categoryName,size: 18,
                  textAlign: TextAlign.center),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => _onPressCategory(category),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kMehroon,
                    shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: const Text("View Answers",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        )),
      ],
    );
  }
}

class _LocalVideoPreview extends StatefulWidget {
  final File file;
  const _LocalVideoPreview({required this.file});

  @override
  State<_LocalVideoPreview> createState() => _LocalVideoPreviewState();
}

class _LocalVideoPreviewState extends State<_LocalVideoPreview> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    final controller = VideoPlayerController.file(widget.file);
    _controller = controller;
    controller.initialize().then((_) {
      if (mounted) setState(() {});
    }).catchError((_) {
      // Ignored — the uploading overlay covers this preview regardless.
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return Container(color: Colors.black);
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }
}


// // lib/features/Screens/edit_profile_screen.dart
// //
// // Flutter port of the React Native `EditProfileScreen` (index.js).
// //
// // State-management choice: plain StatefulWidget + setState, matching the
// // rest of this codebase's screens (see ProfileScreen, CategoryQuestionsScreen,
// // SignUpPage) rather than introducing Provider/Riverpod/Bloc just for this
// // one screen.
// //
// // Notes on things that are intentionally NOT a 1:1 port because RN's
// // original code has quirks that don't make sense to reproduce literally:
// //  - RN's height/weight/age/gender <DropdownComponent> is *uncontrolled*
// //    (its own local `value` state, unrelated to the `value` prop); it only
// //    fakes "already selected" by formatting the prop into `placeholder`.
// //    Flutter's DropdownButtonFormField is properly controlled, so we just
// //    set `value:` directly — no formatHeight() placeholder hack needed.
// //  - RN's `removingIndex` is a single int (not a set), so only the most
// //    recently-tapped image gets the fading "Removing…" animation even if
// //    multiple removals were in flight. Reproduced as-is below for fidelity.
// //  - RN's bottom sheet always passes `multiple: mode === false` to the
// //    picker, which is *always* false (mode is the string "image"/"video",
// //    never the boolean `false`), so multi-select never actually engages —
// //    reproduced as always-single-select.
// //  - react-native-image-crop-picker's `cropping` step has no equivalent in
// //    `image_picker` (would need `image_cropper`), so photo/video picking
// //    below skips the crop step. Everything else (compression quality 0.7,
// //    max 1000x1000, camera/gallery/cancel sheet, permission prompt copy) is
// //    reproduced exactly.
//
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:two_are_one/core/image.dart';
// import 'package:two_are_one/core/my_icons.dart';
// import 'package:two_are_one/core/texts.dart';
// import 'package:two_are_one/features/Bottom_Nav_Bar_Screens/profile_screen.dart';
// import 'package:video_player/video_player.dart';
//
// import '../../core/back_button.dart';
// import '../../core/buttons.dart';
// import '../../core/containers.dart';
// import '../../core/top_toast.dart';
// import '../../models/location_data.dart';
// import '../../models/user_full_profile.dart';
// import '../../services/profiles_services.dart';
// import '../home/category_questions_screen.dart';
// import '../home/inline_video_player.dart';
// import '../main_screens/location_selector.dart';
//
// /// RN: global/constants.js `Upload_Images`.
// const String kEditProfileUploadBase = "https://www.twoareone.love/uploads/";
// const Color _kGradientStart = Color(0xFFB06A82);
// const Color _kGradientEnd = Color(0xFF84A2D4);
// const Color _kMehroon = Color(0xFF77153C);
//
// class _DropdownOption {
//   final String label;
//   final String value;
//   const _DropdownOption(this.label, this.value);
// }
//
// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});
//
//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }
//
// class _ImageEntry {
//   final int? id;
//   final String? networkUrl;
//   final File? localFile;
//   final bool uploading;
//
//   _ImageEntry({this.id, this.networkUrl, this.localFile, this.uploading = false});
// }
//
// class _EditProfileScreenState extends State<EditProfileScreen>
//     with SingleTickerProviderStateMixin {
//   final ProfileService _profileService = ProfileService();
//   final ImagePicker _picker = ImagePicker();
//
//   bool _loadingUser = true;
//   UserFullProfile? _user;
//
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _bioController = TextEditingController();
//   final TextEditingController _workController = TextEditingController();
//
//   String? _selectedGender;
//   String? _selectedAge;
//   String? _selectedHeight;
//   String? _selectedWeight;
//
//   LocationData? _pickedLocation;
//
//   File? _pickedAvatarFile;
//   bool _avatarUploading = false;
//
//   final List<_ImageEntry> _imageEntries = [];
//   // RN: `removingIndex` — a single index, not a set (see file header note).
//   int? _removingIndex;
//   late final AnimationController _fadeController;
//
//   ProfileMediaVideo? _existingVideo;
//   File? _pickedVideoFile;
//   bool _videoUploading = false;
//   bool _removingVideo = false;
//
//   bool _saving = false;
//
//   String _nameError = '';
//   String _workError = '';
//   String _bioError = '';
//
//   // ── dropdown option lists — mirrors RN's global/constants.js exactly ────
//
//   static const List<_DropdownOption> _genderOptions = [
//     _DropdownOption('Male', 'male'),
//     _DropdownOption('Female', 'female'),
//   ];
//
//   static List<_DropdownOption> get _ageOptions => List.generate(88, (i) {
//     final age = '${i + 13}';
//     return _DropdownOption(age, age);
//   });
//
//   static const List<_DropdownOption> _heightOptions = [
//     _DropdownOption("4'10", '4.10'),
//     _DropdownOption("4'11", '4.11'),
//     _DropdownOption("5'0", '5.0'),
//     _DropdownOption("5'1", '5.1'),
//     _DropdownOption("5'2", '5.2'),
//     _DropdownOption("5'3", '5.3'),
//     _DropdownOption("5'4", '5.4'),
//     _DropdownOption("5'5", '5.5'),
//     _DropdownOption("5'6", '5.6'),
//     _DropdownOption("5'7", '5.7'),
//     _DropdownOption("5'8", '5.8'),
//     _DropdownOption("5'9", '5.9'),
//     _DropdownOption("5'10", '5.10'),
//     _DropdownOption("5'11", '5.11'),
//     _DropdownOption("6'0", '6.0'),
//     _DropdownOption("6'1", '6.1'),
//     _DropdownOption("6'2", '6.2'),
//     _DropdownOption("6'3", '6.3'),
//     _DropdownOption("6'4", '6.4'),
//     _DropdownOption("6'5", '6.5'),
//     _DropdownOption("6'6", '6.6'),
//     _DropdownOption("6'7", '6.7'),
//     _DropdownOption("6'8", '6.8'),
//     _DropdownOption("6'9", '6.9'),
//     _DropdownOption("6'10", '6.10'),
//     _DropdownOption("6'11", '6.11'),
//     _DropdownOption("7'0", '7.0'),
//     _DropdownOption("7'1", '7.1'),
//     _DropdownOption("7'2", '7.2'),
//     _DropdownOption("7'3", '7.3'),
//     _DropdownOption("7'4", '7.4'),
//     _DropdownOption("7'5", '7.5'),
//     _DropdownOption("7'6", '7.6'),
//   ];
//
//   static List<_DropdownOption> get _weightOptions =>
//       List.generate(440 - 66 + 1, (i) {
//         final weight = 66 + i;
//         return _DropdownOption('$weight lbs', '$weight');
//       });
//
//   @override
//   void initState() {
//     super.initState();
//     _fadeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     )..repeat(reverse: true);
//     _loadUser();
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _bioController.dispose();
//     _workController.dispose();
//     _fadeController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadUser() async {
//     final res = await _profileService.getUserInfo();
//     if (!mounted) return;
//
//     if (res['success'] == true && res['data'] is Map) {
//       final user =
//       UserFullProfile.fromJson((res['data'] as Map).cast<String, dynamic>());
//       setState(() {
//         _user = user;
//         _nameController.text = user.fullName;
//         _bioController.text = user.bio;
//         _workController.text = user.work;
//         _selectedGender = user.gender.isNotEmpty ? user.gender : null;
//         _selectedAge = user.age.isNotEmpty ? user.age : null;
//         _selectedHeight = user.height.isNotEmpty ? user.height : null;
//         _selectedWeight = user.weight.isNotEmpty ? user.weight : null;
//         _existingVideo = user.userVideo;
//         _imageEntries
//           ..clear()
//           ..addAll(user.allImages.map((img) => _ImageEntry(
//             id: img.id,
//             networkUrl: _fullUrl(img.url),
//           )));
//         _loadingUser = false;
//       });
//     } else {
//       setState(() => _loadingUser = false);
//       TopToast.show(
//         context,
//         title: "Couldn't load profile",
//         message: "Please check your connection.",
//         type: ToastType.error,
//       );
//     }
//   }
//
//   String _fullUrl(String? path) {
//     if (path == null || path.isEmpty) return '';
//     return path.startsWith('http') ? path : '$kEditProfileUploadBase$path';
//   }
//
//   // ── permissions (RN: requestCameraPermission) ───────────────────────────
//
//   Future<bool> _requestCameraPermission() async {
//     final status = await Permission.camera.status;
//     if (status.isGranted) return true;
//
//     if (status.isDenied || status.isPermanentlyDenied) {
//       // RN shows an Alert with Cancel / Grant Access before re-requesting.
//       final proceed = await _showPermissionAlert();
//       if (!proceed) return false;
//       final result = await Permission.camera.request();
//       return result.isGranted;
//     }
//
//     final result = await Permission.camera.request();
//     return result.isGranted;
//   }
//
//   Future<bool> _showPermissionAlert() async {
//     if (!mounted) return false;
//     final result = await showDialog<bool>(
//       context: context,
//       barrierDismissible: false,
//       builder: (ctx) => AlertDialog(
//         title: const Text("Permission Required"),
//         content: const Text("Camera access is required to take photos."),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text("Cancel"),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             child: const Text("Grant Access"),
//           ),
//         ],
//       ),
//     );
//     return result ?? false;
//   }
//
//   // ── profile picture (RN: handleProfileImage / uploadUserProfilePicture) ─
//
//   Future<void> _uploadAvatar(File file) async {
//     setState(() {
//       _pickedAvatarFile = file; // optimistic preview, same as RN
//       _avatarUploading = true;
//     });
//     final res = await _profileService.uploadProfilePicture(file);
//     if (!mounted) return;
//     setState(() => _avatarUploading = false);
//     if (res['success'] != true) {
//       TopToast.show(
//         context,
//         title: "Error",
//         message: res['error']?.toString() ??
//             "Something went wrong while uploading",
//         type: ToastType.error,
//       );
//     }
//   }
//
//   void _pickAvatar() {
//     // RN's edit screen reuses the single generic photo/video bottom sheet
//     // for the avatar too (mode:"image", type:"profile"), so labels are the
//     // generic "Camera"/"Upload Image".
//     _openMediaSheet(
//       isVideo: false,
//       onCamera: () async {
//         if (!await _requestCameraPermission()) return;
//         final shot = await _picker.pickImage(
//           source: ImageSource.camera,
//           imageQuality: 70,
//           maxWidth: 1000,
//           maxHeight: 1000,
//         );
//         if (shot != null) _uploadAvatar(File(shot.path));
//       },
//       onGallery: () async {
//         final picked = await _picker.pickImage(
//           source: ImageSource.gallery,
//           imageQuality: 70,
//           maxWidth: 1000,
//           maxHeight: 1000,
//         );
//         if (picked != null) _uploadAvatar(File(picked.path));
//       },
//     );
//   }
//
//   // ── additional images (RN: handleAddImages / handleUpdateImage / ───────
//   // handleRemoveImage) ─────────────────────────────────────────────────────
//
//   Future<void> _addImage(File file) async {
//     setState(() => _imageEntries.add(
//       _ImageEntry(localFile: file, uploading: true),
//     ));
//
//     final res = await _profileService.addUserPhoto(file);
//     if (!mounted) return;
//
//     if (res['success'] == true) {
//       // RN: `dispatch(setRefreshProfile(!refresh))` — re-fetch so the new
//       // photo gets its real server id/url.
//       await _loadUser();
//     } else {
//       setState(() {
//         _imageEntries.removeWhere((e) => e.uploading);
//       });
//       TopToast.show(
//         context,
//         title: "Error",
//         message: res['error']?.toString() ?? "Something went wrong",
//         type: ToastType.error,
//       );
//     }
//   }
//
//   Future<void> _removeImage(_ImageEntry entry, int index) async {
//     if (entry.id == null) return;
//     setState(() => _removingIndex = index);
//
//     final success = await _profileService.removeUserPhoto(entry.id!);
//     if (!mounted) return;
//
//     setState(() => _removingIndex = null);
//     if (success) {
//       setState(() => _imageEntries.removeWhere((e) => e.id == entry.id));
//     } else {
//       TopToast.show(context, title: "Error", type: ToastType.error);
//     }
//   }
//
//   void _pickAdditionalImage() {
//     if (_imageEntries.length == 6) {
//       // RN: Alert.alert("You can only attach 6 pictures")
//       TopToast.show(
//         context,
//         title: "You can only attach 6 pictures",
//         type: ToastType.info,
//       );
//       return;
//     }
//     _openMediaSheet(
//       isVideo: false,
//       onCamera: () async {
//         if (!await _requestCameraPermission()) return;
//         final shot = await _picker.pickImage(
//           source: ImageSource.camera,
//           imageQuality: 70,
//           maxWidth: 1000,
//           maxHeight: 1000,
//         );
//         if (shot != null) _addImage(File(shot.path));
//       },
//       onGallery: () async {
//         final picked = await _picker.pickImage(
//           source: ImageSource.gallery,
//           imageQuality: 70,
//           maxWidth: 1000,
//           maxHeight: 1000,
//         );
//         if (picked != null) _addImage(File(picked.path));
//       },
//     );
//   }
//
//   // ── video (RN: handleAddVideo / handleUpdateVideo / handleRemoveVideo) ──
//
//   Future<void> _addVideo(File file) async {
//     setState(() {
//       _pickedVideoFile = file;
//       _videoUploading = true;
//     });
//
//     final res = await _profileService.addUserVideo(file);
//     if (!mounted) return;
//
//     if (res['success'] == true) {
//       await _loadUser(); // re-syncs `_existingVideo`
//       if (!mounted) return;
//       setState(() {
//         _pickedVideoFile = null;
//         _videoUploading = false;
//       });
//     } else {
//       setState(() {
//         _pickedVideoFile = null;
//         _videoUploading = false;
//       });
//       TopToast.show(
//         context,
//         title: "Error",
//         message: res['error']?.toString() ?? "Something went wrong",
//         type: ToastType.error,
//       );
//     }
//   }
//
//   Future<void> _removeVideo() async {
//     final video = _existingVideo;
//     if (video == null) return;
//     setState(() => _removingVideo = true);
//
//     final success = await _profileService.removeUserVideo(video.id);
//     if (!mounted) return;
//
//     setState(() => _removingVideo = false);
//     if (success) {
//       setState(() => _existingVideo = null);
//     } else {
//       TopToast.show(context, title: "Error", type: ToastType.error);
//     }
//   }
//
//   void _pickVideo() {
//     if (_existingVideo != null || _pickedVideoFile != null) {
//       // RN: Alert.alert("You can attach only one video")
//       TopToast.show(
//         context,
//         title: "You can attach only one video",
//         type: ToastType.info,
//       );
//       return;
//     }
//     _openMediaSheet(
//       isVideo: true,
//       onCamera: () async {
//         if (!await _requestCameraPermission()) return;
//         final shot = await _picker.pickVideo(source: ImageSource.camera);
//         if (shot != null) _addVideo(File(shot.path));
//       },
//       onGallery: () async {
//         final picked = await _picker.pickVideo(source: ImageSource.gallery);
//         if (picked != null) _addVideo(File(picked.path));
//       },
//     );
//   }
//   void _openMediaSheet({
//     required bool isVideo,
//     required Future<void> Function() onCamera,
//     required Future<void> Function() onGallery,
//   }) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(48)),
//       ),
//       builder: (sheetContext) => SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Buttons(
//                 text: isVideo ? "Record Video" : "Camera",
//                 onTap: () async {
//                   Navigator.pop(sheetContext);
//                   await Future.delayed(const Duration(milliseconds: 250));
//                   if (mounted) await onCamera();
//                 },
//                 gradient:
//                 const LinearGradient(colors: [_kMehroon, Color(0xFFDD276F)]),
//               ),
//               const SizedBox(height: 15),
//               Buttons(
//                 text: isVideo ? "Upload Video" : "Upload Image",
//                 onTap: () async {
//                   Navigator.pop(sheetContext);
//                   await Future.delayed(const Duration(milliseconds: 250));
//                   if (mounted) await onGallery();
//                 },
//                 gradient:
//                 const LinearGradient(colors: [_kMehroon, Color(0xFFDD276F)]),
//               ),
//               const SizedBox(height: 15),
//               Buttons(
//                 text: "Cancel",
//                 onTap: () => Navigator.pop(sheetContext),
//                 gradient:
//                 const LinearGradient(colors: [_kMehroon, Color(0xFFDD226F)]),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ── validation + save (RN: UploadProfileButton.validateInput / onPress) ─
//
//   bool _validate() {
//     final nameOk = RegExp(r'^[A-Za-z\s]+$').hasMatch(_nameController.text.trim());
//     final workOk =
//     RegExp(r"^[a-zA-Z0-9\s,.'-]+$").hasMatch(_workController.text);
//     final bioOk = RegExp(r"^[a-zA-Z0-9\s,.'-]+$").hasMatch(_bioController.text);
//
//     setState(() {
//       _nameError = nameOk ? '' : "Name can only contain letters and spaces";
//       _workError = workOk ? '' : "Work must not contain special characters";
//       _bioError = bioOk ? '' : "Bio must not contain special characters";
//     });
//     return nameOk && workOk && bioOk;
//   }
//
//   Future<void> _onUpdate() async {
//     if (!_validate()) return;
//
//     setState(() => _saving = true);
//     final payload = {
//       "bio": _bioController.text,
//       "full_name": _nameController.text,
//       "country": _pickedLocation?.country ?? _user?.country ?? '',
//       "state": _pickedLocation?.state ?? _user?.state ?? '',
//       "city": _pickedLocation?.city ?? _user?.city ?? '',
//       "gender": _selectedGender,
//       "height": _selectedHeight,
//       "age": _selectedAge,
//       "weight": _selectedWeight,
//       "work": _workController.text,
//     };
//
//     final res = await _profileService.updateUserProfile(payload);
//     if (!mounted) return;
//     setState(() => _saving = false);
//
//     if (res['success'] == true) {
//       TopToast.show(
//         context,
//         title: "Success",
//         message: "User Information Updated Successfully",
//         type: ToastType.success,
//       );
//     } else {
//       TopToast.show(
//         context,
//         title: "Error",
//         message:
//         res['error']?.toString() ?? "Something went wrong while uploading",
//         type: ToastType.error,
//       );
//     }
//   }
//
//   void _onPressCategory(dynamic category) {
//     final userId = _user?.id ?? 0;
//     Navigator.of(context).push(MaterialPageRoute(
//       builder: (_) => CategoryQuestionsScreen(
//         categoryId: category.categoryId,
//         categoryName: category.categoryName,
//         userId: userId,
//         editable: true, // RN: navigate params `{ isEdit: true, cat: category }`
//       ),
//     ));
//   }
//
//   // ── UI ───────────────────────────────────────────────────────────────────
//
//   @override
//   Widget build(BuildContext context) {
//     if (_loadingUser) {
//       return const Scaffold(
//         backgroundColor: Colors.white,
//         body: Center(child: CircularProgressIndicator(color: _kMehroon)),
//       );
//     }
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//           padding: const EdgeInsets.only(bottom: 150),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildHeader(),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 10),
//                     _buildAvatarSection(),
//                     const SizedBox(height: 20),
//
//                     _sectionLabel("About Me"),
//                     Containers(
//                       wHeight: 120,
//                       hexValue: 0xFFF3F3F3,
//                       radius: BorderRadius.circular(20),
//                       alignment: Alignment.topCenter,
//                       child: TextField(
//                         controller: _bioController,
//                         maxLength: 250,
//                         maxLines: 4,
//                         textAlignVertical: TextAlignVertical.top,
//                         onChanged: (_) => setState(() => _bioError = ''),
//                         style: const TextStyle(fontSize: 15, color: Color(0xFF484848)),
//                         decoration: const InputDecoration(
//                           border: InputBorder.none,
//                           contentPadding:
//                           EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//                           hintText: "Tell us something about yourself",
//                           hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
//                         ),
//                       ),
//                     ),
//                     if (_bioError.isNotEmpty) _errorText(_bioError),
//
//                     const SizedBox(height: 16),
//                     _sectionLabel("Full Name"),
//                     TextField(
//                       controller: _nameController,
//                       maxLength: 50,
//                       keyboardType: TextInputType.name,
//                       onChanged: (_) => setState(() => _nameError = ''),
//                       decoration: InputDecoration(
//                         counterText: '',
//                         hintText: "Enter your full name",
//                         filled: true,
//                         fillColor: const Color(0xFFF3F3F3),
//                         contentPadding:
//                         const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
//                         border: OutlineInputBorder(
//                           borderSide: BorderSide.none,
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                       ),
//                     ),
//                     if (_nameError.isNotEmpty) _errorText(_nameError),
//
//                     const SizedBox(height: 16),
//                     _sectionLabel("Location"),
//                     LocationSelectorField(
//                       labels: "Search location",
//                       // initialText: (_user?.city.isNotEmpty == true &&
//                       //     _user?.country.isNotEmpty == true)
//                       //     ? "${_user?.city},${_user?.country}"
//                       //     : null,
//                       onLocationSelected: (loc) =>
//                           setState(() => _pickedLocation = loc),
//                     ),
//
//                     const SizedBox(height: 20),
//                     _sectionLabel("Personal Info"),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _buildDropdown(
//                             icon: Icons.wc,
//                             hint: "Gender",
//                             value: _selectedGender,
//                             items: _genderOptions,
//                             onChanged: (v) => setState(() => _selectedGender = v),
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: _buildDropdown(
//                             icon: Icons.cake_outlined,
//                             hint: "Age",
//                             value: _selectedAge,
//                             items: _ageOptions,
//                             onChanged: (v) => setState(() => _selectedAge = v),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _buildDropdown(
//                             icon: Icons.height,
//                             hint: "Height",
//                             value: _selectedHeight,
//                             items: _heightOptions,
//                             onChanged: (v) => setState(() => _selectedHeight = v),
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: _buildDropdown(
//                             icon: Icons.monitor_weight_outlined,
//                             hint: "Weight",
//                             value: _selectedWeight,
//                             items: _weightOptions,
//                             onChanged: (v) => setState(() => _selectedWeight = v),
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     const SizedBox(height: 16),
//                     _sectionLabel("Work"),
//                     TextField(
//                       controller: _workController,
//                       maxLength: 100,
//                       maxLines: 2,
//                       onChanged: (_) => setState(() => _workError = ''),
//                       decoration: InputDecoration(
//                         hintText: "Enter your work",
//                         hintStyle: const TextStyle(color: Color(0xFF999999)),
//                         filled: true,
//                         fillColor: const Color(0xFFF3F3F3),
//                         contentPadding:
//                         const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
//                         border: OutlineInputBorder(
//                           borderSide: BorderSide.none,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                       ),
//                     ),
//                     if (_workError.isNotEmpty) _errorText(_workError),
//
//                     const SizedBox(height: 24),
//                     _buildUpdateButton(),
//
//                     const SizedBox(height: 24),
//                     _buildMediaSection(),
//
//                     const SizedBox(height: 24),
//                     _buildQuestionsSection(),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       child: Row(
//         children: [
//           Back_Button(onTap: () { Navigator.push(context,
//                MaterialPageRoute(builder: (
//                    context) => ProfileScreen(),)); }),
//           SizedBox(width: 110,),
//           const Text(
//             "Edit Profile",
//             style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _sectionLabel(String text) => Padding(
//     padding: const EdgeInsets.only(bottom: 8, top: 4),
//     child:
//     Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//   );
//
//   Widget _errorText(String message) => Padding(
//     padding: const EdgeInsets.only(left: 16, top: 4),
//     child: Text(message, style: const TextStyle(color: Colors.red, fontSize: 12)),
//   );
//
//   Widget _buildAvatarSection() {
//     final avatarUrl = _fullUrl(_user?.profilePicture);
//     return Center(
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           Container(
//             width: 120,
//             height: 120,
//             padding: const EdgeInsets.all(2),
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.grey.withOpacity(0.3), width: 4),
//             ),
//             child: ClipOval(
//               child: _avatarUploading
//                   ? const Center(child: CircularProgressIndicator(color: _kMehroon))
//                   : _pickedAvatarFile != null
//                   ? Image.file(_pickedAvatarFile!, fit: BoxFit.cover)
//                   : (avatarUrl.isNotEmpty
//                   ? Image.network(
//                 avatarUrl,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, e, s) =>
//                 const Icon(Icons.person_outline_sharp, size: 80),
//               )
//                   : const Icon(Icons.person_outline_sharp, size: 80)),
//             ),
//           ),
//           Positioned(
//             bottom: -4,
//             right: 8,
//             child: GestureDetector(
//               onTap: _pickAvatar,
//               child: Container(
//                 height: 43,
//                 width: 42,
//                   alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                 ),
//                 child: Images(
//                     imageStr: "assets/svg_images/Profile/addImageCamera.svg")
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDropdown({
//     required IconData icon,
//     required String hint,
//     required String? value,
//     required List<_DropdownOption> items,
//     required ValueChanged<String?> onChanged,
//   })
//   {
//     final safeValue =
//     (value != null && items.any((o) => o.value == value)) ? value : null;
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF0EFEF),
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButtonFormField<String>(
//           value: safeValue,
//           isExpanded: true,
//           hint: Text(hint, style: const TextStyle(fontSize: 13)),
//           icon: const Icon(Icons.arrow_drop_down),
//           menuMaxHeight: 300,
//           decoration: InputDecoration(
//             border: InputBorder.none,
//             prefixIconConstraints: const BoxConstraints(minWidth: 40),
//             prefixIcon: Container(
//               margin: const EdgeInsets.only(right: 6),
//               width: 30,
//               height: 30,
//               decoration: const BoxDecoration(color: _kMehroon, shape: BoxShape.circle),
//               child: Icon(icon, color: Colors.white, size: 16),
//             ),
//           ),
//           items: items
//               .map((opt) => DropdownMenuItem(
//             value: opt.value,
//             child: Text(opt.label, style: const TextStyle(fontSize: 13)),
//           ))
//               .toList(),
//           onChanged: onChanged,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildUpdateButton() {
//     return Buttons(
//       text: "Update",
//       letterSpacing: 1.4,
//       isLoading: _saving,
//       onTap: _onUpdate,
//       gradient: const LinearGradient(colors: [_kGradientStart, _kGradientEnd]),
//       width: 185,
//       height: 48,
//     );
//   }
//
//   Widget _buildMediaSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: _mediaActionButton(
//                   "assets/svg_images/add_photo.svg", "Add Photos", _pickAdditionalImage),
//             ),
//             const SizedBox(width: 35),
//             Expanded(
//               child: _mediaActionButton(
//                   "assets/svg_images/add_video.svg", "Add Videos", _pickVideo),
//             ),
//           ],
//         ),
//         if (_imageEntries.isNotEmpty) ...[
//           const SizedBox(height: 15),
//           const Text("Selected Images",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//           const SizedBox(height: 10),
//           SizedBox(
//             height: 100,
//             child: ListView.separated(
//               scrollDirection: Axis.horizontal,
//               itemCount: _imageEntries.length,
//               separatorBuilder: (_, __) => const SizedBox(width: 10),
//               itemBuilder: (context, index) {
//                 final entry = _imageEntries[index];
//                 final removing = _removingIndex == index;
//                 return Stack(
//                   clipBehavior: Clip.none,
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: entry.localFile != null
//                           ? Image.file(entry.localFile!,
//                           width: 100, height: 100, fit: BoxFit.cover)
//                           : Image.network(
//                         entry.networkUrl ?? '',
//                         width: 100,
//                         height: 100,
//                         fit: BoxFit.cover,
//                         errorBuilder: (c, e, s) => Container(
//                             width: 100, height: 100, color: const Color(0xFFECECEC)),
//                       ),
//                     ),
//                     if (entry.uploading)
//                       Positioned.fill(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.black45,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           alignment: Alignment.center,
//                           child: const Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               SizedBox(
//                                 width: 18,
//                                 height: 18,
//                                 child: CircularProgressIndicator(
//                                     strokeWidth: 2, color: Colors.white),
//                               ),
//                               SizedBox(height: 4),
//                               Text("Uploading...",
//                                   style: TextStyle(color: Colors.white, fontSize: 11)),
//                             ],
//                           ),
//                         ),
//                       ),
//                     if (removing)
//                       Positioned.fill(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.black45,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           alignment: Alignment.center,
//                           child: FadeTransition(
//                             opacity: _fadeController,
//                             child: const Text(
//                               "Removing...",
//                               style: TextStyle(color: Colors.white, fontSize: 11),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ),
//                       ),
//                     if (!entry.uploading && !removing)
//                       Positioned(
//                         top: -6,
//                         right: -6,
//                         child: GestureDetector(
//                           onTap: () => _removeImage(entry, index),
//                           child: const CircleAvatar(
//                             radius: 12,
//                             backgroundColor: Colors.white,
//                             child: Icon(Icons.close, size: 16, color: Colors.red),
//                           ),
//                         ),
//                       ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ],
//         if (_existingVideo != null || _pickedVideoFile != null) ...[
//           const SizedBox(height: 20),
//           const Text("Selected Video",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//           const SizedBox(height: 10),
//           Stack(
//             clipBehavior: Clip.none,
//             children: [
//               SizedBox(
//                 width: 300,
//                 height: 180,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: _pickedVideoFile != null
//                       ? _LocalVideoPreview(file: _pickedVideoFile!)
//                       : InlineVideoPlayer(
//                     url: _fullUrl(_existingVideo?.url),
//                   ),
//                 ),
//               ),
//               if (_videoUploading)
//                 Positioned.fill(
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.black54,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     alignment: Alignment.center,
//                     child: const Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         CircularProgressIndicator(color: Colors.white),
//                         SizedBox(height: 8),
//                         Text("Uploading video...", style: TextStyle(color: Colors.white)),
//                       ],
//                     ),
//                   ),
//                 ),
//               if (!_videoUploading)
//                 Positioned(
//                   top: -6,
//                   right: -6,
//                   child: GestureDetector(
//                     onTap: _removingVideo ? null : _removeVideo,
//                     child: CircleAvatar(
//                       radius: 12,
//                       backgroundColor: Colors.white,
//                       child: _removingVideo
//                           ? const SizedBox(
//                           width: 12,
//                           height: 12,
//                           child: CircularProgressIndicator(strokeWidth: 2))
//                           : const Icon(Icons.close, size: 16, color: Colors.red),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ],
//     );
//   }
//
//   Widget _mediaActionButton(String iconImg, String label, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Containers(
//         wWidth: 135, wHeight: 110,
//        hexValue: 0xFFECECEC,
//           radius: BorderRadius.circular(20),
//         alignment: Alignment.center,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Images( height: 40, width: 40, imageStr: iconImg),
//             const SizedBox(height: 8),
//             Texts(text: label, size: 14,colorHexValue: 0xFF000000,),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildQuestionsSection() {
//     final categories = _user?.categories ?? [];
//     if (categories.isEmpty) return const SizedBox.shrink();
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         const Text("Manage Questions",
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//         const SizedBox(height: 10),
//         ...categories.map((category) => Padding(
//           padding: const EdgeInsets.only(bottom: 12),
//           child: Column(
//             children: [
//               Text(category.categoryName, textAlign: TextAlign.center),
//               const SizedBox(height: 6),
//               SizedBox(
//                 width: double.infinity,
//                 height: 46,
//                 child: ElevatedButton(
//                   onPressed: () => _onPressCategory(category),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _kMehroon,
//                     shape:
//                     RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
//                   ),
//                   child: const Text("View Answers",
//                       style: TextStyle(color: Colors.white)),
//                 ),
//               ),
//             ],
//           ),
//         )),
//       ],
//     );
//   }
// }
//
//
// class _LocalVideoPreview extends StatefulWidget {
//   final File file;
//   const _LocalVideoPreview({required this.file});
//
//   @override
//   State<_LocalVideoPreview> createState() => _LocalVideoPreviewState();
// }
//
// class _LocalVideoPreviewState extends State<_LocalVideoPreview> {
//   VideoPlayerController? _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     final controller = VideoPlayerController.file(widget.file);
//     _controller = controller;
//     controller.initialize().then((_) {
//       if (mounted) setState(() {});
//     }).catchError((_) {
//       // Ignored — the uploading overlay covers this preview regardless.
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = _controller;
//     if (controller == null || !controller.value.isInitialized) {
//       return Container(color: Colors.black);
//     }
//     return FittedBox(
//       fit: BoxFit.cover,
//       child: SizedBox(
//         width: controller.value.size.width,
//         height: controller.value.size.height,
//         child: VideoPlayer(controller),
//       ),
//     );
//   }
// }
//
//

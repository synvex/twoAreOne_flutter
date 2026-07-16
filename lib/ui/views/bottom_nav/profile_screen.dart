import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:two_are_one/core/containers.dart';
import 'package:two_are_one/core/divider.dart';
import 'package:two_are_one/core/image.dart';
import 'package:two_are_one/core/my_icons.dart';
import 'package:two_are_one/core/texts.dart';
import 'package:two_are_one/core/buttons.dart';
import 'package:two_are_one/core/confirmation_dialogue.dart';
import 'package:two_are_one/core/profile_bottom_sheet.dart';
import 'package:two_are_one/core/top_toast.dart';
import 'package:two_are_one/data/models/user_full_profile.dart';
import 'package:two_are_one/data/services/Api_Helper/api_manager.dart';
import 'package:two_are_one/data/services/profiles_services.dart';
import 'favourite_screen.dart';

const String kProfileScreenUploadBase = "https://www.twoareone.love/uploads/";
const Color kProfileMehroon = Color(0xFF77153C);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final ImagePicker _picker = ImagePicker();

  bool _loadingUserInfo = true;
  UserFullProfile? _profile;
  String? _avatarOverrideUrl; // optimistic avatar preview right after upload
  bool _imageLoader = false;

  String _appVersion = "";
  bool _logoutLoading = false;
  bool _deleteLoading = false;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _appVersion = "v${info.version}");
    } catch (_) {
// Non-critical — leave blank if the platform channel isn't available.
    }
  }

  Future<void> _getUserInfo() async {
    final res = await _profileService.getUserInfo();
    if (!mounted) return;

    if (res['success'] == true && res['data'] is Map) {
      setState(() {
        _profile = UserFullProfile.fromJson((res['data'] as Map).cast<String, dynamic>());
        _loadingUserInfo = false;
      });
    } else
    {
      setState(() => _loadingUserInfo = false);
      TopToast.show(context,
          title: "Couldn't load profile",
          message: "Please check your connection.",
          type: ToastType.error);
    }
  }

  String _capitalize(String? text) {
    if (text == null || text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

  String _fullUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return path.startsWith('http') ? path : '$kProfileScreenUploadBase$path';
  }

  Future<void> _uploadAvatar(File file) async {
    setState(() => _imageLoader = true);
    final res = await _profileService.uploadProfilePicture(file);
    if (!mounted) return;

    if (res['success'] == true) {
      final newPath = (res['data'] is Map)
          ? (res['data']['profile_picture']?.toString() ?? '')
          : '';
      setState(() {
        _avatarOverrideUrl = _fullUrl(newPath.isNotEmpty ? newPath : null);
        _imageLoader = false;
      });
    } else {
      setState(() => _imageLoader = false);
      TopToast.show(context,
          title: "Upload failed",
          message: res['error']?.toString() ?? "Something went wrong.",
          type: ToastType.error);
    }
  }

  Future<bool> _ensureCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) return true;
    final result = await Permission.camera.request();
    if (result.isGranted) return true;
    if (result.isPermanentlyDenied && mounted) {
      TopToast.show(context,
          title: "Permission required",
          message: "Enable camera access from Settings.",
          type: ToastType.error);
    }
    return false;
  }

  void _openAvatarSheet() {
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
              Buttons(
                text: "Take Photo",
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await Future.delayed(const Duration(milliseconds: 250));
                  if (!await _ensureCameraPermission()) return;
                  final XFile? shot = await _picker.pickImage(
                      source: ImageSource.camera, imageQuality: 85, maxWidth: 1000);
                  if (shot != null) _uploadAvatar(File(shot.path));
                },
                gradient: const LinearGradient(
                  colors: [kProfileMehroon, Color(0xFFDD276F)],
                ),
              ),
              const SizedBox(height: 15),
              Buttons(
                text: "Upload from Gallery",
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await Future.delayed(const Duration(milliseconds: 250));
                  final XFile? picked = await _picker.pickImage(
                      source: ImageSource.gallery, imageQuality: 85, maxWidth: 1000);
                  if (picked != null) _uploadAvatar(File(picked.path));
                },
                gradient: const LinearGradient(
                  colors: [kProfileMehroon, Color(0xFFDD276F)],
                ),
              ),
              const SizedBox(height: 15),
              Buttons(
                text: "Cancel",
                onTap: () => Navigator.pop(sheetContext),
                gradient: const LinearGradient(
                  colors: [kProfileMehroon, Color(0xFFDD276F)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _openOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(48)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetItem(
                icon: Icons.edit_outlined,
                label: "Edit Profile",
                onTap: () async {
                  Navigator.pop(sheetContext);
// RN refreshes profile/stats every time this screen regains
// focus (useFocusEffect + redux `refreshProfile` flag). Editing
// the profile is the one navigation that can change that data,
// so re-fetch as soon as we're back from it.
                  await Navigator.pushNamed(context, '/edit_profile');
                  if (mounted) _getUserInfo();
                },
              ),
              const SizedBox(height: 10),
              _sheetItem(
                icon: Icons.delete_outline,
                label: "Delete account",
                labelColor: const Color(0xFFD00000),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted) _showDeleteDialog();
                  });
                },
              ),
              const SizedBox(height: 10),
              _sheetItem(
                icon: Icons.logout,
                label: "Logout",
                onTap: () {
                  Navigator.pop(sheetContext);
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted) _showLogoutDialog();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _sheetItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? labelColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: const Color(0x80B9B9B9)),
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: const BoxDecoration(
                color: Color(0xFFD9D9D9),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: labelColor ?? Colors.black87),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: labelColor ?? Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _openMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Background transparent lazmi hai
      builder: (context) => MenuBottomSheet(
        onSettings: () {
          Navigator.pushNamed(
              context, '/edit_profile');          // Navigate to settings
        },
        onLogout: () {
          Navigator.pop(context);
          _showLogoutDialog(); // Aapka purana logout dialog function
        },
        onDelete: () {
          Navigator.pop(context);
          _showDeleteDialog(); // Aapka purana delete dialog function
      },
      ),
    );
  }
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: !_logoutLoading,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => LogoutConfirmationDialog(
          loading: _logoutLoading,
          onClose: () => Navigator.of(dialogContext).pop(),
          onConfirm: () async {
            setDialogState(() => _logoutLoading = true);
            await _profileService.logout();
            await ApiManager.logout();
            if (!mounted) return;
            Navigator.of(dialogContext).pop();
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/login', (route) => false);
          },
        ),
      ),
    );
  }
  void _showDeleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: !_deleteLoading,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => DeleteConfirmationDialog(
          loading: _deleteLoading,
          onClose: () => Navigator.of(dialogContext).pop(),
          onConfirm: () async {
            setDialogState(() => _deleteLoading = true);
            final success = await _profileService.deleteAccount();
            if (!mounted) return;
            setDialogState(() => _deleteLoading = false);
            if (success) {
              await ApiManager.logout();
              if (!mounted) return;
              Navigator.of(dialogContext).pop();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            } else {
              Navigator.of(dialogContext).pop();
              TopToast.show(context,
                  title: "Account deletion failed",
                  type: ToastType.error);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
// ── Header ─────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Texts(
                    text: "Profile",
                    fontWeight: FontWeight.w600,
                    size: 24, colorHexValue: 0xFF000000,
                  ),
                  GestureDetector(
                    onTap: _openMenu,
                    child: Containers(
                      wHeight: 50,
                      wWidth: 50,
                      hexValue: 0xFFFFFFFF,
                      alignment: Alignment.center,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0x666C6C6C)),
                      child: const Icon(Icons.more_vert),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 20),
                    _buildProfileCard(),
                    const SizedBox(height: 20),
                    _menuItem(
                      hexValue: 0x00000000,
                      iconImg: "assets/svg_images/Profile/accountSetting.svg",
                      label: "Account settings",
                      onTap: () => Navigator.pushNamed(
                          context, '/settings_screen'),
                    ),
                    _menuItem(
                      iconImg: "assets/svg_images/Profile/settingHeart.svg",
                      label: "Interested User",
                      onTap: () => TopToast.show(context,
                          title: "Coming soon", type: ToastType.info),
                    ),
                    _menuItem(
                      iconImg: "assets/svg_images/Profile/settingStar.svg",
                      label: "Favorite",
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const FavouriteScreen())),
                    ),
                    _menuItem(
                      iconImg: "assets/svg_images/Profile/settingBlock.svg",
                      label: "Blocked User",
                      onTap: () => TopToast.show(context,
                          title: "Coming soon", type: ToastType.info),
                    ),
                    _menuItem(
                      iconImg: "assets/svg_images/Profile/visitor.svg",
                      label: "Visited User",
                      onTap: () => TopToast.show(context,
                          title: "Coming soon", type: ToastType.info),
                    ),
                    _menuItem(
                      iconImg: "assets/svg_images/Profile/settingNotification.svg",
                      label: "Notification",
                      onTap: () => TopToast.show(context,
                          title: "Coming soon", type: ToastType.info),
                    ),
                    const SizedBox(height: 10),
                    if (_appVersion.isNotEmpty)
                      Text(
                        "App Version $_appVersion",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF424242),
                            fontWeight: FontWeight.w600),
                      ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      height: 215,
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: const LinearGradient(
          colors: [Color(0xE5477CB6), Color(0xCCDD276F)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: _loadingUserInfo ? _buildCardSkeleton() : _buildCardContent(),
    );
  }

  Widget _buildCardSkeleton() {
    Widget bar(double w, double h) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(4),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                bar(120, 18),
                const SizedBox(height: 8),
                bar(160, 14),
              ],
            ),
          ],
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [bar(30, 18), bar(30, 18), bar(30, 18)],
        ),
      ],
    );
  }

  Widget _buildCardContent() {
    final profile = _profile;
    final avatarUrl = _avatarOverrideUrl ?? _fullUrl(profile?.profilePicture);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 75, height: 75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    color: Colors.white.withOpacity(0.5),
                  ),
                  child: _imageLoader
                      ? const Center(
                    child: SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    ),
                  )
                      : ClipOval(
                    child: avatarUrl.isNotEmpty
                        ? Image.network(
                      avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => ColoredBox(
                          color: Colors.blueGrey.shade500.withValues(alpha: .5)),
                    )
                        : ColoredBox(color: Colors.blueGrey.shade300.withValues(alpha: .4)),
                  ),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: GestureDetector(
                    onTap: _openAvatarSheet,
                    child: Container(
                      height: 38, width: 38,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const MyIcons(
                          iconData: Icons.camera_alt_outlined,
                          size: 20, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _capitalize(profile?.fullName),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    profile?.email ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Container(
          height: 75,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statBox(profile?.totalFavorites ?? 0, "Favorites"),
              CustomDivider(color: Colors.white,),
              _statBox(profile?.totalInterested ?? 0, "Interested"),
              CustomDivider(color: Colors.white,),
              _statBox(profile?.totalBlocks ?? 0, "Blocks"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statBox(int count, String label) {
    return Column(
      children: [
        Text("$count",
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
      ],
    );
  }

  Widget _menuItem({
    int? hexValue,
    required String iconImg,
    required String label,
    required VoidCallback onTap,
  }) {
    bool isPressed = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: GestureDetector(
            // Tap Start: Opacity kam hogi aur shadow thori badlegi
            onTapDown: (_) => setState(() => isPressed = true),
            // Tap End: Wapis normal ho jayega
            onTapUp: (_) => setState(() => isPressed = false),
            onTapCancel: () => setState(() => isPressed = false),
            onTap: onTap,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 100),
              opacity: isPressed ? 0.6 : 1.0, // React Native ki tarah content light ho jayega
              child: Container(
                padding: const EdgeInsets.only(left: 8, right: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFDFD),
                  borderRadius: BorderRadius.circular(100),
                  // "Elevated" look ke liye depth shadow
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.09),
                      blurRadius: 1, // Zyada blur se elevation badhti hai
                      spreadRadius: .2,
                      offset: const Offset(1, 2), // Niche ki taraf shadow
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon Circle
                    Container(
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8D8D8),
                        shape: BoxShape.circle,
                        // Icon ke piche bhi halki si inner shadow (optional)
                        border: Border.all(color: Colors.black.withOpacity(0.03)),
                      ),
                      alignment: Alignment.center,
                      child:Images(imageStr: iconImg,
                        height: hexValue == 0x00000000 ? 55 : 25,
                        width: hexValue == 0x00000000 ? 55 :25,
                        color: hexValue == 0x00000000 ? null : Color( 0xFF000000),)
                    ),
                    const SizedBox(width: 15),
                    // Text Label
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.black.withOpacity(0.8),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    Images(imageStr: "assets/svg_images/Profile/chevron-right.svg",height: 20,
                        color: Colors.black.withOpacity(0.8)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}


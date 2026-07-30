import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:two_are_one/features//views/main/main_screen_card.dart';
import 'package:two_are_one/features//views/main/profile_setup_screen.dart';
import 'package:two_are_one/core/widgets/main_button_widget.dart';
import 'package:two_are_one/core/widgets/selection_card.dart';
import 'package:two_are_one/core/widgets/texts.dart';
import 'package:two_are_one/data/models/user_profile_model.dart';
import 'package:two_are_one/data/services/auth_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = -1;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  final List<UserPreference> _preferences = const [
    UserPreference(gender: "male", lookingFor: "female"),
    UserPreference(gender: "female", lookingFor: "male"),
    UserPreference(gender: "male", lookingFor: "male"),
    UserPreference(gender: "female", lookingFor: "female"),
  ];

  final List<Map<String, dynamic>> _options = const [
    {
      'label': 'Male seeking female',
      'leftIcon': 'assets/svg_images/user2.svg',
      'rightIcon': 'assets/svg_images/Frame.svg',
      'leftColor': 0xFF1B63B1,
      'rightColor': 0xFF77153C,
    },
    {
      'label': 'Female seeking male',
      'leftIcon': 'assets/svg_images/Frame.svg',
      'rightIcon': 'assets/svg_images/user2.svg',
      'leftColor': 0xFF77153C,
      'rightColor': 0xFF1B63B1,
    },
    {
      'label': 'Male seeking male',
      'leftIcon': 'assets/svg_images/user2.svg',
      'rightIcon': 'assets/svg_images/user2.svg',
      'leftColor': 0xFF1B63B1,
      'rightColor': 0xFF1B63B1,
    },
    {
      'label': 'Female seeking female',
      'leftIcon': 'assets/svg_images/Frame.svg',
      'rightIcon': 'assets/svg_images/Frame.svg',
      'leftColor': 0xFF77153C,
      'rightColor': 0xFF77153C,
    },
  ];
  Future<void> _onNextTapped() async {
    if (_selectedIndex == -1 || _isLoading) return;

    setState(() => _isLoading = true);

    final pref = _preferences[_selectedIndex];

    final result = await _authService.updateIntroduce(
      genderId: pref.gender,
      sexualityId: pref.lookingFor,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_screen_type', '1');
      await prefs.setString('cached_gender', pref.gender);
      await prefs.setString('cached_sexuality', pref.lookingFor);

      // Build the profile model and carry it forward to the next screen.
      final profileModel = UserProfileModel(
        gender: pref.gender,
        sexuality: pref.lookingFor,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileSetupScreen(profileModel: profileModel),
        ),
      );
    } else {
      _showError(result['error'] ?? "Something went wrong. Please try again.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF77153C),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return PopScope(
canPop: false, // Prevents back navigation
onPopInvoked: (didPop) {
if (didPop) return;},
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          physics: isLandscape
              ? const ScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 55),
              const StackedUserCards(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Texts(
                      text: "Preferences",
                      size: 24,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 15),
                    const Texts(
                      text:
                          "Share your preferences so we can connect\nyou with the right people",
                      size: 12,
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.w300,
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Texts(
                        text: "I am a",
                        size: 16,
                        fontWeight: FontWeight.w700,
                        edgeInsets: EdgeInsets.only(left: 8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_options.length, (index) {
                      final option = _options[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SelectionCard(
                          label: option['label'],
                          isSelected: _selectedIndex == index,
                          onTap: () => setState(() => _selectedIndex = index),
                          activeColor: 0xFF77153C,
                          leftCircleColor: option['leftColor'],
                          rightCircleColor: option['rightColor'],
                          leftIcon: option['leftIcon'],
                          rightIcon: option['rightIcon'],
                        ),
                      );
                    }),
                    const SizedBox(height: 30),
                    MainButtonWidget(
                      text: "Next",
                      isLoading: _isLoading,
                      onTap: (_selectedIndex == -1 || _isLoading)
                          ? null
                          : _onNextTapped,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF77153C), Color(0xFFDD276F)],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserPreference {
  final String gender;
  final String lookingFor;
  const UserPreference({required this.gender, required this.lookingFor});
}

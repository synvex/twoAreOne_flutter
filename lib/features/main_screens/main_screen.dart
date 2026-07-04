// import 'package:flutter/material.dart';
// import 'package:two_are_one/features/main_screens/main_screen_card.dart';
// import 'package:two_are_one/features/main_screens/profile_setup_screen.dart';
// import '../../core/buttons.dart';
// import '../../core/selection_card.dart';
// import '../../core/texts.dart';
// import '../../models/introduce_option.dart';
// import '../../services/auth_service.dart';
//
// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});
//
//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> {
//   int _selectedIndex = -1;
//   final bool _isLoading = false;
//   final List<UserPreference> _preferences = const [
//     UserPreference(gender: "Male",   lookingFor: "Female"),
//     UserPreference(gender: "Female", lookingFor: "Male"),
//     UserPreference(gender: "Male",   lookingFor: "Male"),
//     UserPreference(gender: "Female", lookingFor: "Female"),
//   ];
//   final List<Map<String, dynamic>> _options = const [
//     {
//       'label': 'Male seeking female',
//       'leftIcon': 'assets/svg_images/user2.svg',
//       'rightIcon': 'assets/svg_images/Frame.svg',
//       'leftColor': 0xFF1B63B1,
//       'rightColor': 0xFF77153C,
//       'activeColor': 0xFF77153C,
//     },
//     {
//       'label': 'Female seeking male',
//       'leftIcon': 'assets/svg_images/Frame.svg',
//       'rightIcon': 'assets/svg_images/user2.svg',
//       'leftColor': 0xFF77153C,
//       'rightColor': 0xFF1B63B1,
//       'activeColor': 0xFF77153C,
//     },
//     {
//       'label': 'Male seeking male',
//       'leftIcon': 'assets/svg_images/user2.svg',
//       'rightIcon': 'assets/svg_images/user2.svg',
//       'leftColor': 0xFF1B63B1,
//       'rightColor': 0xFF5A8FC4,
//       'activeColor': 0xFF77153C,
//     },
//     {
//       'label': 'Female seeking female',
//       'leftIcon': 'assets/svg_images/Frame.svg',
//       'rightIcon': 'assets/svg_images/Frame.svg',
//       'leftColor': 0xFF77153C,
//       'rightColor': 0xFFA96E86,
//       'activeColor': 0xFF77153C,
//     },
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     bool isSelected = false;
//     bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         physics: isLandscape ? ScrollPhysics():const NeverScrollableScrollPhysics(),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const SizedBox(height: 55),
//             const StackedUserCards(),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//               child: Column(
//                     children: [
//                       SizedBox(height: 10,),
//                       const Texts(
//                         text: "Preferences",
//                         size: 24,
//                         fontWeight: FontWeight.w600,
//                       ),
//                       const SizedBox(height: 15),
//                       const Texts(text: "Share your preferences so we can connect\nyou with the right people",
//                         size: 12,
//                         textAlign: TextAlign.center,
//                         fontWeight: FontWeight.w300,
//                       ),
//                       const SizedBox(height: 20),
//                       const Align(
//                         alignment: Alignment.centerLeft,
//                         child: Texts(
//                           text: "I am a",
//                           size: 16,
//                           fontWeight: FontWeight.w700,
//                           edgeInsets: EdgeInsets.only(left: 8),
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       // Build all 4 option cards
//                       ...List.generate(
//                           _options.length, (index) {
//                         final option = _options[index];
//                         return Padding(
//                           padding: const EdgeInsets.only(bottom: 10,),
//                           child: SelectionCard(
//                             label: option['label'],
//                             isSelected: _selectedIndex == index,
//                             onTap: () => setState(() => _selectedIndex = index),
//                             activeColor: 0xFF77153C,
//                             leftCircleColor: option['leftColor'],
//                             rightCircleColor: option['rightColor'],
//                             leftIcon: option['leftIcon'],
//                             rightIcon: option['rightIcon'],
//                           ),
//                         );
//                       }),
//                       const SizedBox(height: 30),
//                       Buttons(
//                           text: "Next",
//                           isLoading: _isLoading,
//                           onTap: (_selectedIndex == -1 || _isLoading)
//                               ? null
//                           : () {
//                             setState(() {
//                               _isLoading: true ;
//                             });
//                             final pref = _preferences[_selectedIndex];
//                             Navigator.push(context,
//                                 MaterialPageRoute(
//                             builder: (c) => ProfileSetupScreen(
//                               gender: pref.gender,
//                               lookingFor: pref.lookingFor,)));
//                       },
//                           gradient: const LinearGradient(colors: [
//                             Color(0xFF77153C),
//                             Color(0xFFDD276F)])
//                       ),
//                       SizedBox(
//                         height: 20,)
//                     ],
//                   ),
//             ),
//
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class UserPreference {
//   final String gender;       // "Male" or "Female"
//   final String lookingFor;   // "Male" or "Female"
//
//   const UserPreference({required this.gender, required this.lookingFor});
// }

// features/main_screens/main_screen.dart
// Changes vs. original:
//  • "Next" button calls AuthService.updateIntroduce() before navigating.
//  • Creates a UserProfileModel with gender + sexuality and passes it to
//    ProfileSetupScreen so the data flows forward without extra fetches.
//  • Loading state is now correctly mutable (removed `final`).

import 'package:flutter/material.dart';
import 'package:two_are_one/features/main_screens/main_screen_card.dart';
import 'package:two_are_one/features/main_screens/profile_setup_screen.dart';
import '../../core/buttons.dart';
import '../../core/selection_card.dart';
import '../../core/texts.dart';
import '../../models/introduce_option.dart';
import '../../models/user_profile_model.dart';
import '../../services/auth_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = -1;

  // ── FIX: was `final bool`, which made setState a no-op ──────────────────
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  // Parallel lists: index matches _options list below.
  final List<UserPreference> _preferences = const [
    UserPreference(gender: "male",   lookingFor: "female"),
    UserPreference(gender: "female", lookingFor: "male"),
    UserPreference(gender: "male",   lookingFor: "male"),
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
      'rightColor': 0xFF5A8FC4,
    },
    {
      'label': 'Female seeking female',
      'leftIcon': 'assets/svg_images/Frame.svg',
      'rightIcon': 'assets/svg_images/Frame.svg',
      'leftColor': 0xFF77153C,
      'rightColor': 0xFFA96E86,
    },
  ];

  // ── API call + navigation ────────────────────────────────────────────────
  Future<void> _onNextTapped() async {
    if (_selectedIndex == -1 || _isLoading) return;

    setState(() => _isLoading = true);

    final pref = _preferences[_selectedIndex];

    final result = await _authService.updateIntroduce(
      genderId:    pref.gender,
      sexualityId: pref.lookingFor,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      // Build the profile model and carry it forward to the next screen.
      final profileModel = UserProfileModel(
        gender:    pref.gender,
        sexuality: pref.lookingFor,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileSetupScreen(
            // Keep original named params for any callers that still use them.
            // gender:     pref.gender,
            // lookingFor: pref.lookingFor,
            // NEW: pass the full model so ProfileSetupScreen can extend it.
            profileModel: profileModel,
          ),
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

    return Scaffold(
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
                  Buttons(
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
    );
  }
}

class UserPreference {
  final String gender;
  final String lookingFor;
  const UserPreference({required this.gender, required this.lookingFor});
}



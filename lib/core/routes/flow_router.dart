import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/services/home_service.dart';
import '../../features/views/bottom_nav/custom_nav_bar.dart';
import '../../features/views/main/main_screen.dart';
import '../../features/views/main/profile_setup_screen.dart';
import '../../features/views/main/question_screen.dart';

class OnboardingFlowRouter {
  static Future<Widget> resolveResumeScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final homeService = HomeService();

    // 1. Fetch latest state from server
    final res = await homeService.getUserInfo();

    if (res['success'] == true) {
      final data = res['data'] as Map<String, dynamic>;

      // 2. Persist to cache (so we have it for offline/cold boot fallbacks)
      await _writeCachedUserInfo(prefs, data);

      // 3. Determine screen
      return _getScreenFromData(data);
    }

    // 4. Fallback to cache if server is unreachable
    final cached = _readCachedUserInfo(prefs);
    if (cached['screen_type'] != null) {
      return _getScreenFromData(cached);
    }

    // Default fallback
    return const MainScreen();
  }

  static Widget _getScreenFromData(Map<String, dynamic> data) {
    final complete = data['complete_question'].toString() == "true" || data['complete_question'] == 1;
    final screenType = data['screen_type']?.toString();

    final skeletonModel = UserProfileModel(
      gender: data['gender']?.toString() ?? "",
      sexuality: data['sexuality']?.toString() ?? "",
    );

    if (complete) return const CustomNavBar();

    switch (screenType) {
      case "1":
        return ProfileSetupScreen(profileModel: skeletonModel);
      case "2":
        return QuestionnaireScreen(profileModel: skeletonModel);
      case "0":
      default:
        return const MainScreen();
    }
  }

  static Map<String, String?> _readCachedUserInfo(SharedPreferences prefs) {
    return {
      'complete_question': prefs.getString('cached_complete_question'),
      'screen_type': prefs.getString('cached_screen_type'),
      'gender': prefs.getString('cached_gender'),
      'sexuality': prefs.getString('cached_sexuality'),
    };
  }

  static Future<void> _writeCachedUserInfo(SharedPreferences prefs, Map<String, dynamic> data) async {
    await prefs.setString('cached_complete_question', data['complete_question']?.toString() ?? "");
    await prefs.setString('cached_screen_type', data['screen_type']?.toString() ?? "0");
    await prefs.setString('cached_gender', data['gender']?.toString() ?? "");
    await prefs.setString('cached_sexuality', data['sexuality']?.toString() ?? "");
  }
}
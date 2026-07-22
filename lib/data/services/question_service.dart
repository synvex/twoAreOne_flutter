import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Api_Helper/api_manager.dart';

class QuestionService {
  final ApiManager _api = ApiManager();

  /// Fetches questions for the questionnaire.
  Future<Map<String, dynamic>> getQuestions({int page = 1}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? "0";

      return await _api.fetch(
        Api(url: "questions/listing.php", method: "GET"),
        {
          'page': page.toString(),
          'user_id': userId,
        },
      );
    } catch (e) {
      debugPrint('getQuestions error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Saves the user's answer to a specific question.
  /// REFACTORED: Now uses ApiManager (Dio) instead of raw http to fix ClientException.
  Future<Map<String, dynamic>> saveUserAnswer({
    required int categoryId,
    required int questionId,
    required int answerId,
  }) async {
    try {
      return await _api.fetch(
        Api(
          url: "questions/save-user-question-answer.php",
          method: "POST",
        ),
        {
          'category_id': categoryId.toString(),
          'question_id': questionId.toString(),
          'answer_id': answerId.toString(),
        },
      );
    } catch (e) {
      debugPrint('saveUserAnswer error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Fetches questions already answered by the user in a specific category.
  Future<Map<String, dynamic>> getUserQuestionsByCategory({
    required int categoryId,
    required int userId,
  }) async {
    try {
      final cacheBust = DateTime.now().millisecondsSinceEpoch.toString();
      return await _api.fetch(
        Api(
          url: "questions/get-user-questions-by-category.php",
          method: "GET",
          headers: const {
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            'Pragma': 'no-cache',
          },
        ),
        {
          'category_id': categoryId.toString(),
          'user_id': userId.toString(),
          '_': cacheBust,
        },
      );
    } catch (e) {
      debugPrint('getUserQuestionsByCategory error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Fetches the question + all answer options for ONE question.
  Future<Map<String, dynamic>> getQuestionAnswersById(int questionId) async {
    try {
      return await _api.fetch(
        Api(
          url: "questions/get-question-answers.php",
          method: "GET",
        ),
        {'question_id': questionId.toString()},
      );
    } catch (e) {
      debugPrint('getQuestionAnswersById error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Updates an existing answer.
  Future<Map<String, dynamic>> updateUserQuestionAnswer({
    required int categoryId,
    required int questionId,
    required int answerId,
  }) async {
    try {
      return await _api.fetch(
        Api(
          url: "questions/update-user-question-answer.php",
          method: "POST",
        ),
        {
          'category_id': categoryId.toString(),
          'question_id': questionId.toString(),
          'answer_id': answerId.toString(),
        },
      );
    } catch (e) {
      debugPrint('updateUserQuestionAnswer error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}






// class QuestionService {
//   static const String baseUrl = 'https://www.twoareone.love/api';
//   final ApiManager _api = ApiManager();
//   Future<Map<String, dynamic>> getQuestions({int page = 1}) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userId = prefs.getString('user_id') ?? "0"; // Get the stored user_id
//
//       return await _api.fetch(
//         Api(url: "questions/listing.php?page=$page",
//             method: "GET"),
//         {
//           'page': page.toString(),
//           'user_id': userId,
//         },
//       );
//     } catch (e) {
//       debugPrint('getQuestions error: $e');
//       return {'success': false, 'error': e.toString()};
//     }
//   }
//
//   Future<Map<String, dynamic>> saveUserAnswer({
//     required int categoryId,
//     required int questionId,
//     required int answerId,
//   }) async
//   {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('auth_token') ?? '';
//
//       final url = Uri.parse('$baseUrl/questions/save-user-question-answer.php');
//
//       final body = json.encode({
//         'category_id': categoryId.toString(),
//         'question_id': questionId.toString(),
//         'answer_id': answerId.toString(),
//       });
//
//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $token',
//           'x-api-key': token,
//         },
//         body: body,
//       ).timeout(const Duration(seconds: 25));
//
//       return _handleResponse(response);
//     } catch (e) {
//       debugPrint('saveUserAnswer error: $e');
//       return {'success': false, 'error': e.toString()};
//     }
//   }
//
//   Future<Map<String, dynamic>> getUserQuestionsByCategory({
//     required int categoryId,
//     required int userId,
//   }) async
//   {
//     try {
//       // FIX: this call is always used to read the answer list back right
//       // after saveUserAnswer/updateUserQuestionAnswer, so it must never be
//       // served from a stale cache (browser/proxy/CDN GET caching). The
//       // "_" param busts any cache keyed purely on the URL; no-cache headers
//       // cover any layer that respects them.
//       final cacheBust = DateTime.now().millisecondsSinceEpoch.toString();
//       final res = await _api.fetch(
//         Api(
//           url: "questions/get-user-questions-by-category.php",
//           method: "GET",
//           headers: const {
//             'Cache-Control': 'no-cache, no-store, must-revalidate',
//             'Pragma': 'no-cache',
//           },
//         ),
//         {
//           'category_id': categoryId.toString(),
//           'user_id': userId.toString(),
//           '_': cacheBust,
//         },
//       );
//       debugPrint('getUserQuestionsByCategory (category=$categoryId, user=$userId) -> $res');
//       return res;
//     } catch (e) {
//       debugPrint('getUserQuestionsByCategory error: $e');
//       return {'success': false, 'error': e.toString()};
//     }
//   }
//   /// Fetches the question + all answer options for ONE question (used by
//   /// the "Change" / edit-answer screen). Mirrors RN's
//   /// GetUserQuestionAnswerByIdService.
//   Future<Map<String, dynamic>> getQuestionAnswersById(int questionId) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('auth_token') ?? '';
//
//       final url = Uri.parse(
//           '$baseUrl/questions/get-question-answers.php?question_id=$questionId');
//
//       final response = await http.get(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//           'x-api-key': token,
//         },
//       ).timeout(const Duration(seconds: 15));
//
//       return _handleListResponse(response);
//     } catch (e) {
//       debugPrint('getQuestionAnswersById error: $e');
//       return {'success': false, 'error': e.toString()};
//     }
//   }
//   /// Saves a changed answer for an already-answered question. Mirrors RN's
//   /// updateQuestionService.
//   Future<Map<String, dynamic>> updateUserQuestionAnswer({
//     required int categoryId,
//     required int questionId,
//     required int answerId,
//   }) async
//   {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('auth_token') ?? '';
//
//       final url = Uri.parse('$baseUrl/questions/update-user-question-answer.php');
//
//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $token',
//           'x-api-key': token,
//         },
//         body: json.encode({
//           'category_id': categoryId.toString(),
//           'question_id': questionId.toString(),
//           'answer_id': answerId.toString(),
//         }),
//       ).timeout(const Duration(seconds: 15));
//
//       return _handleResponse(response);
//     } catch (e) {
//       debugPrint('updateUserQuestionAnswer error: $e');
//       return {'success': false, 'error': e.toString()};
//     }
//   }
//
//   /// Shared parser for the two "list" endpoints above. RN's version doesn't
//   /// check any success flag for these — it just trusts a normal HTTP
//   /// response and reads `.data.data` (falling back to `.data`). This mirrors
//   /// that exactly, while still using the app's unified 401 handling.
//   Map<String, dynamic> _handleListResponse(http.Response response) {
//     debugPrint('Question service (list) status: ${response.statusCode}');
//     debugPrint('Question service (list) body: ${response.body}');
//
//     if (response.statusCode == 401) {
//       ApiManager.handleUnauthorized();
//       return {
//         'success': false,
//         'error': 'Session expired. Please login again.',
//         'isSessionExpired': true,
//       };
//     }
//
//     dynamic decoded;
//     try {
//       decoded = json.decode(response.body);
//     } catch (e) {
//       return {'success': false, 'error': 'Invalid server response format.'};
//     }
//
//     if (response.statusCode >= 200 && response.statusCode < 300) {
//       final extracted =
//       (decoded is Map && decoded['data'] != null) ? decoded['data'] : decoded;
//       return {'success': true, 'data': extracted};
//     }
//
//     final message = decoded is Map ? decoded['message'] : null;
//     return {'success': false, 'error': message ?? 'Failed to fetch questions.'};
//   }
//   /// FIX: now handles HTTP 401 the same way as the rest of the app — shows
//   /// the session-expired dialog and logs the user out via
//   /// `ApiManager.handleUnauthorized()`. Previously an expired token here
//   /// just returned a plain error string with no dialog, no logout, and no
//   /// redirect, leaving the user stuck on the Questions screen.
//   Map<String, dynamic> _handleResponse(http.Response response) {
//     debugPrint('Question service status: ${response.statusCode}');
//     debugPrint('Question service body: ${response.body}');
//
//     dynamic decoded;
//     try {
//       decoded = json.decode(response.body);
//     } catch (e) {
//       return {'success': false, 'error': 'Invalid server response format.'};
//     }
//
//     if (response.statusCode == 401) {
//       ApiManager.handleUnauthorized();
//       return {
//         'success': false,
//         'error': 'Session expired. Please login again.',
//         'isSessionExpired': true,
//       };
//     }
//
//     if (response.statusCode == 200 &&
//         decoded is Map &&
//         decoded['error'] == false) {
//       return {'success': true, 'data': decoded['data'],
//         'message': decoded['message']};
//     }
//
//     final message = decoded is Map ? decoded['message'] : null;
//     return {'success': false, 'error': message ?? 'Failed'};
//   }
// }

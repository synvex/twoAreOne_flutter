
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class QuestionService {
  static const String baseUrl = 'https://twoareone.love/api';

  Future<Map<String, dynamic>> getQuestions({int page = 1}) async
  {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final url = Uri.parse('$baseUrl/questions/listing.php?page=$page');
      debugPrint('Fetching questions: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'x-api-key': token,
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint('Questions Status: ${response.statusCode}');
      debugPrint('Questions Body: ${response.body}');

      final decoded = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && decoded['error'] == false) {
        return {'success': true, 'data': decoded['data']};
      }
      return {'success': false, 'error': decoded['message'] ?? 'Failed'};
    } catch (e) {
      debugPrint('getQuestions error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> saveUserAnswer({
    required int categoryId,
    required int questionId,
    required int answerId,
  }) async
  {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final url = Uri.parse('$baseUrl/questions/save-user-question-answer.php');

      final body = json.encode({
        'category_id': categoryId.toString(),
        'question_id': questionId.toString(),
        'answer_id': answerId.toString(),
      });

      debugPrint('Saving answer: $body');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'x-api-key': token,
        },
        body: body,
      ).timeout(const Duration(seconds: 15));

      debugPrint('Save answer Status: ${response.statusCode}');
      debugPrint('Save answer Body: ${response.body}');

      final decoded = json.decode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && decoded['error'] == false) {
        return {'success': true};
      }
      return {'success': false, 'error': decoded['message'] ?? 'Failed'};
    } catch (e) {
      debugPrint('saveUserAnswer error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}



//
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// class QuestionService {
//   final String baseUrl = 'https://twoareone.love/api';
//
//   // Get all questions with pagination
//   Future<Map<String, dynamic>> getQuestions({
//     int page = 1,
//     int perPage = 10,
//   }) async {
//     try {
//       final token = await _getToken();
//       final url = Uri.parse(
//           '$baseUrl/questions/listing.php?page=$page&per_page=$perPage');
//       final response = await http.get(
//         url,
//         headers: {
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $token',
//           'X-API-KEY': token ?? '',
//           'X-Requested-With': 'XMLHttpRequest',
//         },
//       ).timeout(const Duration(seconds: 60));
//
//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'error': "Connection error: $e"};
//     }
//   }
//
//   // Get questions by category
//   Future<Map<String, dynamic>> getQuestionsByCategory({
//     required int categoryId,
//     int page = 1,
//     int perPage = 10,
//   }) async {
//     try {
//       final token = await _getToken();
//       final url = Uri.parse(
//           '$baseUrl/questions/get-questions-by-category.php?category_id=$categoryId&page=$page&per_page=$perPage'
//       );
//
//       final response = await http.get(
//         url,
//         headers: {
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $token',
//           'X-Requested-With': 'XMLHttpRequest',
//         },
//       ).timeout(const Duration(seconds: 30));
//
//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'error': "Connection error: $e"};
//     }
//   }
//
//   // Save user's answer to a question
//   Future<Map<String, dynamic>> saveUserAnswer({
//     required int categoryId,
//     required int questionId,
//     required int answerId,
//   }) async {
//     try {
//       final token = await _getToken();
//       final url = Uri.parse('$baseUrl/questions/save-user-question-answer.php');
//
//       final response = await http.post(
//         url,
//         headers: {
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//           'X-API-KEY': token ?? '',
//           'X-Requested-With': 'XMLHttpRequest',
//         },
//         body: jsonEncode({
//           'category_id': categoryId.toString(),
//           'question_id': questionId.toString(),
//           'answer_id': answerId.toString(),
//         }),
//       ).timeout(const Duration(seconds: 30));
//
//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'error': "Connection error: $e"};
//     }
//   }
//
//   // Update user's answer to a question
//   Future<Map<String, dynamic>> updateUserAnswer({
//     required int categoryId,
//     required int questionId,
//     required int answerId,
//   }) async {
//     try {
//       final token = await _getToken();
//       final url = Uri.parse('$baseUrl/questions/update-user-question-answer.php');
//
//       final response = await http.post(
//         url,
//         headers: {
//           'Accept': 'application/json',
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//           'X-API-KEY': token ?? '',
//           'X-Requested-With': 'XMLHttpRequest',
//         },
//         body: jsonEncode({
//           'category_id': categoryId.toString(),
//           'question_id': questionId.toString(),
//           'answer_id': answerId.toString(),
//         }),
//       ).timeout(const Duration(seconds: 30));
//
//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'error': "Connection error: $e"};
//     }
//   }
//
//   // Get user's answers
//   Future<Map<String, dynamic>> getUserAnswers({
//     int page = 1,
//     int perPage = 10,
//   }) async {
//     try {
//       final token = await _getToken();
//       final url = Uri.parse(
//           '$baseUrl/questions/get-user-answer.php?page=$page&per_page=$perPage'
//       );
//
//       final response = await http.get(
//         url,
//         headers: {
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $token',
//           'X-Requested-With': 'XMLHttpRequest',
//         },
//       ).timeout(const Duration(seconds: 30));
//
//       return _handleResponse(response);
//     } catch (e) {
//       return {'success': false, 'error': "Connection error: $e"};
//     }
//   }
//
//   Map<String, dynamic> _handleResponse(http.Response response) {
//     print("Status: ${response.statusCode}");
//     print("Body: ${response.body}");
//
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       try {
//         final data = jsonDecode(response.body);
//         return {'success': true, 'data': data};
//       } catch (e) {
//         return {'success': true, 'data': response.body};
//       }
//     } else {
//       return {
//         'success': false,
//         'error': 'Error ${response.statusCode}: ${response.body}'
//       };
//     }
//   }
//
//   Future<String?> _getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('auth_token');
//   }
// }
// lib/features/home/edit_single_question_screen.dart
//
// Flutter port of React Native's `EditQuestionsScreen`
// (src/Screens/AppScreens/EditQuestionScreen/index.js).
//
// Reached by tapping "Change" on CategoryQuestionsScreen. Lets the CURRENT
// user pick a different answer for one already-answered question, then
// saves it and pops back (returning `true` so the list screen refreshes).

import 'package:flutter/material.dart';
import 'package:two_are_one/core/widgets/back_button.dart';
import 'package:two_are_one/data/services/question_service.dart';

const Color _kMehroon = Color(0xFF77153C);

class EditSingleQuestionScreen extends StatefulWidget {
  /// The question item as returned by CategoryQuestionsScreen's list
  /// (expects: question_id, question, user_answer_id, category_name).
  final Map<String, dynamic> item;
  final int categoryId;

  const EditSingleQuestionScreen({
    super.key,
    required this.item,
    required this.categoryId,
  });

  @override
  State<EditSingleQuestionScreen> createState() =>
      _EditSingleQuestionScreenState();
}

class _EditSingleQuestionScreenState extends State<EditSingleQuestionScreen> {
  final QuestionService _service = QuestionService();

  bool _loading = false; // fetching answer options
  bool _saving = false; // "Update" button loading
  String? _answerError;
  List<Map<String, dynamic>> _answers = [];
  int? _selectedAnswerId;

  int get _questionId =>
      int.tryParse(widget.item['question_id'].toString()) ?? 0;

  @override
  void initState() {
    super.initState();
    _selectedAnswerId =
        int.tryParse(widget.item['user_answer_id']?.toString() ?? '');
    _getData();
  }

  Future<void> _getData() async {
    setState(() => _loading = true);
    final res = await _service.getQuestionAnswersById(_questionId);
    if (!mounted) return;

    if (res['success'] == true && res['data'] is List) {
      setState(() {
        _answers = (res['data'] as List)
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList();
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
            Text(res['error']?.toString() ?? 'Failed to load answers.')),
      );
    }
  }

  Future<void> _handleUpdate() async {
    if (_selectedAnswerId == null) {
      setState(() => _answerError = "Select answer first to move to the next question");
      return;
    }
    setState(() {
      _saving = true;
      _answerError = null;
    });
    final res = await _service.updateUserQuestionAnswer(
      categoryId: widget.categoryId,
      questionId: _questionId,
      answerId: _selectedAnswerId!,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (res['success'] == true) {
      _showResultDialog(

          res['message']?.toString() ?? 'Question Updated Successfully',
          success: true);
    } else {
      _showResultDialog(res['error']?.toString() ?? 'Failed to update answer.',
          success: false);
    }
  }

  // void _showResultDialog(String message, {required bool success}) {
  //   showDialog(
  //     context: context,
  //     builder: (dialogContext) => AlertDialog(
  //       backgroundColor: Colors.white,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //       title: Text(success ? "Success" : "Oops, Failed!"),
  //       content: Text(message),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             Navigator.of(dialogContext).pop(); // close dialog
  //             if (success) {
  //               Navigator.of(context).pop(true); // pop screen, ask list to refresh
  //             }
  //           },
  //           child: const Text("OK",
  //               style: TextStyle(
  //                   color: _kMehroon, fontWeight: FontWeight.bold)),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  void _showResultDialog(String message, {required bool success}) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing by tapping outside
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(success ? "Success" : "Oops, Failed!"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (success) {
                if (!mounted) return;
                Navigator.of(context).pop(true);
              }
            },
            child: const Text("OK",
                style: TextStyle(
                    color: _kMehroon, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _capitalizeWords(String? text) {
    if (text == null || text.isEmpty) return '';
    return text
        .split(' ')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final categoryName = widget.item['category_name']?.toString() ?? '';
    final questionText = widget.item['question']?.toString() ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Back_Button(onTap: () => Navigator.of(context).maybePop()),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _capitalizeWords(categoryName),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _loading
                        ? const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child:
                        CircularProgressIndicator(color: _kMehroon),
                      ),
                    )
                        : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border:
                        Border.all(color: const Color(0x80969696)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            questionText,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 14),
                          ..._answers.map((ans) {
                            final answerId = int.tryParse(
                                ans['answer_id']?.toString() ??
                                    ans['id']?.toString() ??
                                    '');
                            final isSelected =
                                _selectedAnswerId == answerId;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedAnswerId = answerId;
                                  _answerError = null;
                                });
                              },
                              child: Container(
                                width: double.infinity,
                                margin:
                                const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? _kMehroon
                                      : Colors.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? _kMehroon
                                        : const Color(0x80969696),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  ans['answer']?.toString() ?? '',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    if (_answerError != null) ...[
                      const SizedBox(height: 8),
                      Text(_answerError!,
                          style: const TextStyle(color: Colors.red, fontSize: 12)),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _handleUpdate,

                  // {
                  //   _saving ? null : _handleUpdate;
                  //   _handleUpdate();
                  // },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kMehroon,
                    shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: _saving
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                      : const Text("Update",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
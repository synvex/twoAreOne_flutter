// lib/features/home/category_questions_screen.dart
//
// Flutter port of React Native's `QuestionListScreen`
// (src/Screens/AppScreens/UserQuestionList/index.js).
//
// Reached from ProfileDetailsScreen's "View Answers" button — shows every
// question a given user has answered inside one category.

import 'package:flutter/material.dart';
import 'package:two_are_one/core/texts.dart';
import 'package:two_are_one/core/back_button.dart';
import 'package:two_are_one/data/services/question_service.dart';
import 'edit_single_question_screen.dart';

const Color _kMehroon = Color(0xFF77153C);

class CategoryQuestionsScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final int userId;
  final bool editable;

  const CategoryQuestionsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.userId,
    this.editable = false,
  });

  @override
  State<CategoryQuestionsScreen> createState() =>
      _CategoryQuestionsScreenState();
}

class _CategoryQuestionsScreenState extends State<CategoryQuestionsScreen> {
  final QuestionService _service = QuestionService();
  List<Map<String, dynamic>> _questions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    setState(() => _loading = true);

    final res = await _service.getUserQuestionsByCategory(
      categoryId: widget.categoryId,
      userId: widget.userId,
    );

    if (!mounted) return;

    if (res['success'] == true && res['data'] is List) {
      setState(() {
        _questions = (res['data'] as List)
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList();
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
            Text('Failed to fetch questions. Please try again later.')),
      );
    }
  }

  Future<void> _onChangePress(Map<String, dynamic> item) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditSingleQuestionScreen(
          item: item,
          categoryId: widget.categoryId,
        ),
      ),
    );
    // Mirrors RN's redux `refresh` trigger — re-fetch the list after a
    // successful edit so the shown answer text stays in sync.
    if (changed == true) _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Back_Button(onTap: () => Navigator.of(context).maybePop()),
                  const SizedBox(width: 82,height: 100,),
                  Expanded(
                    child: Texts(
                      text: widget.categoryName,
                        maxLines: 1,
                        size: 20,
                        fontWeight: FontWeight.w600,
                        colorHexValue: 0xFF000000,
                      // overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: _loading
                    ? const Center(
                    child: CircularProgressIndicator(color: Colors.black))
                    : ListView.builder(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 8, bottom: 48),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final item = _questions[index];
                    final answerText =
                        item['user_answer_text']?.toString() ?? '';
                    return _QuestionCard(
                      question: item['question']?.toString() ?? '',
                      answer:
                      answerText.isNotEmpty ? answerText : 'N/A',
                      editable: widget.editable,
                      onChange: () => _onChangePress(item),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final String question;
  final String answer;
  final bool editable;
  final VoidCallback onChange;

  const _QuestionCard({
    required this.question,
    required this.answer,
    required this.editable,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0x80969696)),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: _kMehroon,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
                if (editable) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onChange,
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Change",
                        style: TextStyle(
                          color: _kMehroon,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 16),
            child: Text(
              answer,
              style: const TextStyle(color: Colors.black, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
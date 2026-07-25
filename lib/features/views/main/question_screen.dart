import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:two_are_one/core/widgets/main_button_widget.dart';
import 'package:two_are_one/core/widgets/failed.dart';
import 'package:two_are_one/data/models/question_model.dart';
import 'package:two_are_one/data/models/user_profile_model.dart';
import 'package:two_are_one/data/services/question_service.dart';
import 'package:two_are_one/features/views/bottom_nav/custom_nav_bar.dart';
import 'package:two_are_one/core/widgets/containers.dart';
import 'package:two_are_one/core/widgets/texts.dart';

class QuestionnaireScreen extends StatefulWidget {
  final UserProfileModel profileModel;
  const QuestionnaireScreen({super.key, required this.profileModel});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen>
    with TickerProviderStateMixin {
  final QuestionService _service = QuestionService();
  late AnimationController _lottieController;
  bool _loading = false; // Initial loading
  bool _hasError = false;
  bool _btnLoader = false; // "Next" button loading
  final List<Question> _questions = [];
  int _currentIndex = 0;
  int? _selectedAnswerId;
  String? _answerError;
  double _serverPercent = 0;
  int _orderNo = 0;
  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _fetchPage();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  // Logic to calculate Lottie frame based on order_no (Matching RN useMemo)
  double get _progressValue {
    if (_orderNo == 0) return 0;
    const totalFrames = 11;
    int step = _orderNo % totalFrames;
    int frame = (step == 0) ? totalFrames - 1 : step - 1;
    return (frame / totalFrames).clamp(0.0, 1.0);
  }

  Future<void> _fetchPage() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    final result = await _service.getQuestions(
      page: 1,
    ); // RN always sends 1 or uses reloadKey

    if (!mounted) return;

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>;

      // Check for completion flag (Matching RN onApiResponse)
      if (data['completeQuestion'] == true ||
          data['completeQuestion'] == "true") {
        _navigateToCompletion();
        return;
      }

      final qMap = data['question'] as Map<String, dynamic>?;
      final answersRaw = data['answers'] as List<dynamic>?;

      if (qMap != null && answersRaw != null) {
        final newQuestion = Question(
          id: int.tryParse(qMap['id'].toString()) ?? 0,
          categoryId: int.tryParse(qMap['category_id'].toString()) ?? 0,
          categoryName: data['questions_category']['name'] ?? '',
          text: qMap['question'] ?? '',
          orderNo: int.tryParse(qMap['order_no'].toString()) ?? 0,
          answers: answersRaw
              .map(
                (a) => Answer(
                  id: int.tryParse(a['id'].toString()) ?? 0,
                  text: a['answer'] ?? '',
                ),
              )
              .toList(),
        );

        setState(() {
          _questions.clear();
          _questions.add(newQuestion);
          _currentIndex = 0;
          // _currentIndex = _questions.length - 1;
          _orderNo = newQuestion.orderNo;
          _serverPercent =
              double.tryParse(data['questionAnswerPercentage'].toString()) ?? 0;
          _selectedAnswerId = null;
          _loading = false;
          _hasError = false; // Confirm error is false
        });

        _lottieController.animateTo(
          _progressValue,
          duration: const Duration(milliseconds: 500),
        );
      }
    } else {
      setState(() => _loading = false);
      if (result['error'] == "No more questions available!") {
        _navigateToCompletion();
        // Add this inside _fetchPage else block to see the real error:
        debugPrint("API ERROR: ${result['error']}");
      } else {
        setState(() => _hasError = true);
        debugPrint("API ERROR: ${result['error']}");
      }
    }
  }

  Future<void> _handleNext() async {
    if (_selectedAnswerId == null) {
      setState(
        () => _answerError = "Select answer first to move to the next question",
      );
      return;
    }
    setState(() {
      _btnLoader = true;
      _answerError = null;
    });

    final currentQ = _questions[_currentIndex];

    // 1. Get the result map from the service
    final result = await _service.saveUserAnswer(
      categoryId: currentQ.categoryId,
      questionId: currentQ.id,
      answerId: _selectedAnswerId!,
    );

    // 2. Check the 'success' key inside that map
    if (result['success'] == true) {
      await _fetchPage();
    } else {
      // Optional: Show error message if save failed
      _showErrorDialog(result['error'] ?? "Failed to save answer");
    }

    if (mounted) {
      setState(() => _btnLoader = false);
    }
  }

  void _showErrorDialog(String message, {String title = "Oops, Failed!"}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FailedWidget(),
              const SizedBox(height: 15),
              Texts(
                text: title,
                colorHexValue: 0xFFdf605f,
                size: 22,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 15),
              Texts(
                textAlign: TextAlign.center,
                text: message,
                size: 14,
                colorHexValue: 0xFF4D4D4D,
              ),
              const SizedBox(height: 25),
              MainButtonWidget(
                height: 50,
                text: "Close",
                onTap: () => Navigator.pop(context),
                gradient: const LinearGradient(
                  colors: [Color(0xFF77153C), Color(0xFFDD276F)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCompletion() {
    // Equivalent to dispatch(setScreen("3"))
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainBarScreen()),
    );
  }

  String _capitalize(String val) =>
      val.isEmpty ? "" : val[0].toUpperCase() + val.substring(1);

  // String _capitalize(String val) =>
  //     val.isEmpty ? "" : val[0].toUpperCase() + val.substring(1);

  @override
  Widget build(BuildContext context) {
    if (_loading && _questions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF77153C)),
        ),
      );
    }
    if (_hasError && _questions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Texts(text: "Something went wrong!"),
              const SizedBox(height: 10),
              MainButtonWidget(
                text: 'Retry',
                onTap: () => _fetchPage(),
                gradient: const LinearGradient(
                  colors: [Color(0xFF77153C), Color(0xFFDD276F)],
                ),
              ),
            ],
          ),
        ),
      );
    }
    final q = _questions[_currentIndex];
    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: Text("No questions found.")));
    }
    return PopScope(
      canPop: false,

      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(
                  bottom: 120,
                ), // Padding for fixed button
                child: Column(
                  children: [
                    const SizedBox(height: 100),

                    // Progress Lottie (Matching RN progressWrapper)
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.scale(
                            scaleY: 6,
                            scaleX: 6,
                            child: Lottie.asset(
                              'assets/jsonImg/jason.json',
                              width: 100,
                              height: 100,
                              controller: _lottieController,
                              fit: BoxFit.contain,
                              onLoaded: (comp) =>
                                  _lottieController.duration = comp.duration,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Texts(
                              text: '${_serverPercent.toInt()}%',
                              size: 16,
                              fontWeight: FontWeight.bold,
                              colorHexValue: 0xFF3A7FDB, // Blue color from RN
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Texts(
                      text: _capitalize(q.categoryName),
                      size: 20,
                      fontWeight: FontWeight.w500,
                      colorHexValue: 0xB2000000,
                    ),
                    const SizedBox(height: 20),

                    // Question Box (Matching RN questionBox styles)
                    Containers(
                      radius: BorderRadius.circular(16),
                      hexValue: 0xFFFFFFFF,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      border: Border.all(
                        color: const Color(0xFFE8E3E3),
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 1),
                        ),
                      ],
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Texts(
                                text: '${q.orderNo}. ',
                                size: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              Expanded(
                                child: Texts(
                                  text: q.text,
                                  size: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          ...q.answers.map((ans) {
                            final isSelected = _selectedAnswerId == ans.id;
                            return GestureDetector(
                              onTap: () => setState(() {
                                _selectedAnswerId = ans.id;
                                _answerError = null;
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF77153C)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : const Color(0x80969696),
                                  ),
                                ),
                                child: Center(
                                  child: Texts(
                                    edgeInsets: EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    text: ans.text,
                                    size: 14,
                                    colorHexValue: isSelected
                                        ? 0xFFFFFFFF
                                        : 0x99000000,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    if (_answerError != null)
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Texts(
                          text: _answerError!,
                          colorHexValue: 0xFFFF0000,
                          size: 12,
                        ),
                      ),
                  ],
                ),
              ),

              // Fixed Bottom Button
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: MainButtonWidget(
                  text: 'Next',
                  isLoading: _btnLoader,
                  onTap: _handleNext,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF77153C), Color(0xFFDD276F)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

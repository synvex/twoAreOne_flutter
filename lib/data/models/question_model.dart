class Question {
  final int id;
  final int categoryId;
  final String categoryName;
  final String text;
  final int orderNo;
  final List<Answer> answers;

  Question({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.text,
    required this.orderNo,
    required this.answers,
  });
}


class Answer {
  final int id;
  final String text;
  const Answer({required this.id, required this.text});
}
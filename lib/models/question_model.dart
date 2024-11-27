class Question {
  final String question;
  final String answer;
  final List<String> options;

  Question({
    required this.question,
    required this.answer,
    required this.options,
  });

  // Factory constructor to create a Question object from Firestore data
  factory Question.fromMap(Map<String, dynamic> data) {
    return Question(
      question: data['question'] ?? '',
      answer: data['answer'] ?? '',
      options: List<String>.from(data['options'] ?? []),
    );
  }
}

class RoadmapDay {
  final String title;
  final List<RoadmapExercise> exercises;

  RoadmapDay({required this.title, required this.exercises});
}

class RoadmapExercise {
  final String title;
  final List<Question> questions;

  RoadmapExercise({required this.title, required this.questions});

  factory RoadmapExercise.fromMap(Map<String, dynamic> map) {
    return RoadmapExercise(
      title: map['title'] ?? '',
      questions: List<Question>.from(
        map['questions']?.map((q) => Question.fromMap(q)) ?? [],
      ),
    );
  }
}

class Question {
  final String question;
  final List<String> options;
  final String answer;

  Question(
      {required this.question, required this.options, required this.answer});

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      answer: map['answer'] ?? '',
    );
  }
}

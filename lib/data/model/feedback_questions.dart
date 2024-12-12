class FeedbackQuestion {
  final String id;
  final String question;
  final bool isActive;

  const FeedbackQuestion({
    required this.id,
    required this.question,
    required this.isActive,
  });

  factory FeedbackQuestion.fromJson(Map<String, dynamic> json) {
    return FeedbackQuestion(
      id: json['id'],
      question: json['question'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'isActive': isActive,
    };
  }
}

class FeedbackQuestions {
  final List<FeedbackQuestion> feedbackQuestions;
  const FeedbackQuestions({
    required this.feedbackQuestions,
  });

  factory FeedbackQuestions.fromJson(List feedbackQuestions) {
    return FeedbackQuestions(
      feedbackQuestions: feedbackQuestions.map((e) => FeedbackQuestion.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feedbackQuestions': feedbackQuestions.map((e) => e.toJson()).toList(),
    };
  }

  factory FeedbackQuestions.empty() {
    return const FeedbackQuestions(feedbackQuestions: []);
  }
}

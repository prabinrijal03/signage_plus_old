class FeedbackRequest {
  final String? name;
  final String? email;
  final String? phone;
  final String? message;
  final String orgId;
  final List<Answer> answers;

  const FeedbackRequest({this.name, this.email, this.message, required this.orgId, required this.answers, required this.phone});

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (message != null) 'message': message,
      if (phone != null) 'phone': phone,
      'orgId': orgId,
      'answers': answers.map((e) => e.toJson()).toList(),
    };
  }

  FeedbackRequest copyWith({
    String? name,
    String? email,
    String? message,
    String? orgId,
    String? phone,
    List<Answer>? answers,
  }) {
    return FeedbackRequest(
      name: name ?? this.name,
      email: email ?? this.email,
      message: message ?? this.message,
      orgId: orgId ?? this.orgId,
      phone: phone ?? this.phone,
      answers: answers ?? this.answers,
    );
  }
}

class Answer {
  final String questionId;
  final int answer;

  const Answer({required this.questionId, required this.answer});

  Map<String, dynamic> toJson() {
    return {'questionId': questionId, 'answer': answer};
  }

  Answer copyWith({
    String? questionId,
    int? answer,
  }) {
    return Answer(
      questionId: questionId ?? this.questionId,
      answer: answer ?? this.answer,
    );
  }
}

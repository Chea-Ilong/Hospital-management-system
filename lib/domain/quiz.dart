import 'package:uuid/uuid.dart';

var uuid = Uuid();

class Question {
  final String _id;

  final String title;
  final List<String> choices;
  final String goodChoice;
  int points;

  String get id => _id;

  Question(
      {required this.title,
      required this.choices,
      required this.goodChoice,
      this.points = 1,
      String? id})
      : _id = id ?? uuid.v4();
}

class Answer {
  final String _id;
  final String _questionId;
  final String answerChoice;

  String get id => _id;
  String get questionId => _questionId;

  Answer({required String questionId, required this.answerChoice, String? id})
      : _id = id ?? uuid.v4(),
        _questionId = questionId;

  Question getQuestion(Quiz quiz) {
    return quiz.getQuestionById(_questionId);
  }

  bool isGood(Quiz quiz) {
    Question question = getQuestion(quiz);
    return answerChoice == question.goodChoice;
  }
}

class Submission {
  final String _id;
  final String _quizId;
  final String _playerName;
  final List<Answer> answers;

  String get id => _id;
  String get quizId => _quizId;
  String get playerName => _playerName;

  Submission({required this.answers, required String quizId, required String playerName})
      : _id = uuid.v4(),
        _quizId = quizId,
        _playerName = playerName;
}

class Quiz {
  final String _id;
  List<Answer> answers = [];
  List<Question> questions;
  List<Submission> submissions = [];

  Quiz({required this.questions, String? id}) : _id = id ?? uuid.v4();

  String get id => _id;

  Submission submitAnswer(List<Answer> answers, String playerName) {
    Submission submission = Submission(answers: answers, quizId: id, playerName: playerName);
    submissions.add(submission);
    return submission;
  }

  Answer getAnswerById(String id) {
    return answers.firstWhere((answer) => answer.id == id);
  }

  Question getQuestionById(String id) {
    return questions.firstWhere((question) => question.id == id);
  }

  int getPoint() {
    int point = 0;
    for (int i = 0; i < answers.length; i++) {
      if (answers[i].isGood(this)) {
        Question question = answers[i].getQuestion(this);
        point += question.points;
      }
    }
    return point;
  }

  int totalScore() {
    int totalScore = 0;
    for (Answer answer in answers) {
      if (answer.isGood(this)) {
        totalScore++;
      }
    }
    return totalScore;
  }

  int getScoreInPercentage() {
    int totalScore = 0;
    for (Answer answer in answers) {
      if (answer.isGood(this)) {
        totalScore++;
      }
    }

    return ((totalScore / questions.length) * 100).toInt();
  }
}

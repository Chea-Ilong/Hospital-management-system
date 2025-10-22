import 'dart:convert';
import 'dart:io';
import '../domain/quiz.dart';

class QuizRepository {
  final String filePath;

  QuizRepository(this.filePath);

  Quiz readQuiz() {
    final file = File(filePath);
    final content = file.readAsStringSync();
    final data = jsonDecode(content);

    // Map JSON to domain objects
    var questionsJson = data['questions'] as List;
    var questions = questionsJson.map((q) {
      return Question(
        title: q['title'],
        choices: List<String>.from(q['choices']),
        goodChoice: q['goodChoice'],
        points: q['points'],
        id: q.containsKey('questionId') ? q['questionId'] : null,
      );
    }).toList();

    return Quiz(questions: questions);
  }

  Quiz writeQuiz(Quiz quiz) {
    final file = File(filePath);
    final data = {
      'quizId': quiz.id,
      'questions': quiz.questions.map((q) {
        return {
          'title': q.title,
          'choices': q.choices,
          'goodChoice': q.goodChoice,
          'points': q.points,
          'questionId': q.id,
        };
      }).toList(),
      'submissions': quiz.submissions.map((s) {
        return {
          'submissionId': s.id,
          'quizId': s.quizId,
          'playerName': s.playerName,
          'answers': s.answers.map((a) {
            return {
              'questionId': a.questionId,
              'answerChoice': a.answerChoice,
              'answerId': a.id,
            };
          }).toList(),
        };
      }).toList(),
    };

    final jsonString = JsonEncoder.withIndent('  ').convert(data);
    file.writeAsStringSync(jsonString);

    return quiz;
  }
}

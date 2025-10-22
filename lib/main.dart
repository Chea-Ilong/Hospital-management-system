import 'domain/quiz.dart';
import 'ui/quiz_console.dart';
import 'data/quiz_repository.dart';

void main() {
  String filePath = "./lib/data/content.json";

  QuizRepository repo = QuizRepository(filePath);
  Quiz quiz = repo.readQuiz();
  QuizConsole console = QuizConsole(quiz: quiz, filePath: filePath);
  console.startQuiz();
}

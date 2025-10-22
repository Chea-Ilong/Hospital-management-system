import 'dart:io';

import '../domain/quiz.dart';
import '../domain/player.dart';
import '../data/quiz_repository.dart';

class QuizConsole {
  Quiz quiz;
  List<Player> players = [];
  String? filePath;

  QuizConsole({required this.quiz, this.filePath});

  void startQuiz() {
    while (true) {
      print("Welcome to the Quiz");

      stdout.write("Enter your name: ");
      String? userInput = stdin.readLineSync();
      if (userInput!.trim().isEmpty == true) {
        print('--- Quiz Finished ---');

        if (filePath != null) {
          QuizRepository(filePath!).writeQuiz(quiz);
          print('All submissions saved to $filePath');
        }

        break;
      }

      Player player;
      if (players.any((element) => element.name == userInput)) {
        var samePlayer =
            players.firstWhere((element) => element.name == userInput);
        player = samePlayer;
      } else {
        player = Player(name: userInput);
        players.add(player);
      }

      quiz.answers.clear();

      print("Hello, ${player.name}! Let's start the quiz.\n");
      for (var question in quiz.questions) {
        print('Question: ${question.title} - (${question.points} points )');
        print('Choices: ${question.choices}');
        stdout.write('Your answer: ');
        String? userInput = stdin.readLineSync();

        // Check for null input
        if (userInput != null && userInput.isNotEmpty) {
          Answer answer = Answer(questionId: question.id, answerChoice: userInput);
          quiz.answers.add(answer);
        } else {
          print('No answer entered. Skipping question.');
        }

        print('');
      }

      quiz.submitAnswer(quiz.answers, player.name);
      player.setScore(quiz.getScoreInPercentage());

      print('${player.name}, your score: ${quiz.getScoreInPercentage()}%');
      print('Total points: ${quiz.getPoint()}\n');

      print('--- All Player Scores ---');
      for (var p in players) {
        print('name: ${p.name}, score: ${p.score}');
      }
      print('');
    }
  }
}

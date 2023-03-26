import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz/util/screen_wrapper.dart';
import 'package:quiz/util/stats_utils.dart';
import 'package:quiz/class/service.dart';
import 'package:quiz/class/statistic.dart';
import 'package:quiz/class/topic.dart';

class Question {
  int id;
  String question;
  List<dynamic> options;
  String answerPostPath;
  String? imageUrl;

  Question(this.id, this.question, this.options, this.answerPostPath);

  Question.fromJson(Map<String, dynamic> jsonData)
      : id = jsonData['id'],
        imageUrl = jsonData['image_url'],
        question = jsonData['question'],
        options = jsonData['options'],
        answerPostPath = jsonData['answer_post_path'];
}

class QuestionState {
  int? topicId;
  Question? question;
  String? answer;
  bool? correct;

  QuestionState({this.topicId, this.question, this.answer, this.correct});

  QuestionState setQuestion({int? newTopicId, Question? newQuestion}) {
    return QuestionState(
      topicId: newTopicId ?? topicId,
      question: newQuestion ?? question,
      answer: null,
      correct: null,
    );
  }

  QuestionState setAnswer({String? newAnswer, bool? newCorrect}) {
    return QuestionState(
      topicId: topicId,
      question: question,
      answer: newAnswer ?? answer,
      correct: newCorrect ?? correct,
    );
  }
}

class QuestionNotifier extends StateNotifier<QuestionState> {
  final quizService = QuizService();
  QuestionNotifier() : super(QuestionState());

  fetchQuestion(int topicId) async {
    Question question = await quizService.getQuestion(topicId);
    state = state.setQuestion(newTopicId: topicId, newQuestion: question);
  }

  checkAnswer(int topicId, int questioId, String answer) async {
    bool correct = await quizService.checkAnswer(topicId, questioId, answer);
    state = state.setAnswer(newAnswer: answer, newCorrect: correct);
  }
}

final questionProvider =
    StateNotifierProvider<QuestionNotifier, QuestionState>((ref) {
  final questionNotifier = QuestionNotifier();
  return questionNotifier;
});

class QuestionScreen extends StatelessWidget {
  final int topicId;
  final bool genericPractice;
  const QuestionScreen(this.topicId, {this.genericPractice = false, super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
        Center(child: QuestionWidget(topicId, genericPractice)));
  }
}

class QuestionWidget extends ConsumerWidget {
  final int topicId;
  final bool genericPractice;
  const QuestionWidget(this.topicId, this.genericPractice, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final question = ref.watch(questionProvider).question;
    final answer = ref.watch(questionProvider).answer;
    final isCorrect = ref.watch(questionProvider).correct;

    if (question == null || ref.read(questionProvider).topicId != topicId) {
      ref.read(questionProvider.notifier).fetchQuestion(topicId);
    }

    if (question == null) {
      return SingleChildScrollView(
          child: Column(
        children: [
          const Text(
            'Fetching question...',
          ),
          const Text(
            'Is it taking a long time? Fetch new question manually:',
          ),
          ElevatedButton(
              onPressed: () =>
                  ref.read(questionProvider.notifier).fetchQuestion(topicId),
              child: const Text('Fetch new question'))
        ],
      ));
    }

    return SingleChildScrollView(
        child: Column(
      children: [
        Text(
          question.question,
        ),
        if (question.imageUrl != null)
          Image(image: NetworkImage(question.imageUrl!)),
        Column(
          children: question.options
              .map((option) => ElevatedButton(
                  onPressed: () => ref
                      .read(questionProvider.notifier)
                      .checkAnswer(topicId, question.id, option),
                  child: Text(option)))
              .toList(),
        ),
        if (isCorrect != null)
          (!isCorrect)
              ? const Text(
                  'Wrong answer. Try again!',
                )
              : Column(children: [
                  const Text(
                    'Correct answer!',
                  ),
                  ElevatedButton(
                      onPressed: () {
                        ref
                            .read(statisticsProvider.notifier)
                            .incrementTopicStat(topicId);

                        if (genericPractice == true) {
                          int genericPracticeTopicId =
                              getTopicIdForGenericPractice(
                                  ref.read(topicsProvider),
                                  ref.read(statisticsProvider));
                          context.go('/practice/$genericPracticeTopicId');
                        } else {
                          ref
                              .read(questionProvider.notifier)
                              .fetchQuestion(topicId);
                        }
                      },
                      child: const Text('Next question'))
                ])
      ],
    ));
  }
}

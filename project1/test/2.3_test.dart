import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nock/nock.dart';
import 'package:quiz/class/question.dart';

void main() {
  setUpAll(() {
    nock.defaultBase = 'https://dad-quiz-api.deno.dev';
    nock.init();
  });

  setUp(() {
    nock.cleanAll();
  });

  testWidgets('Fetch and display a question', (tester) async {
    final questionInterceptor = nock.get("/topics/1/questions")
      ..reply(200, {
        "id": 2,
        "question": "What is the outcome of 100 + 100?",
        "options": ["200", "100", "20", "8"],
        "answer_post_path": "/topics/1/questions/2/answers"
      });

    const app =
        ProviderScope(child: MaterialApp(home: QuestionWidget(1, false)));
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(questionInterceptor.isDone, true);

    final questionFinder = find.text('What is the outcome of 100 + 100?');
    expect(questionFinder, findsOneWidget);

    final buttonFinder = find.byType(ElevatedButton);
    expect(buttonFinder, findsNWidgets(4));
  });

  testWidgets('Check answer when wrong', (tester) async {
    final questionInterceptor = nock.get("/topics/1/questions")
      ..reply(200, {
        "id": 2,
        "question": "What is the outcome of 100 + 100?",
        "options": ["200", "100", "20", "8"],
        "answer_post_path": "/topics/1/questions/2/answers"
      });

    final answerInterceptor = nock
        .post("/topics/1/questions/2/answers", {"answer": "20"})
      ..reply(200, {"correct": false});

    const app =
        ProviderScope(child: MaterialApp(home: QuestionWidget(1, false)));
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(questionInterceptor.isDone, true);

    await tester.tap(find.text('20'));
    await tester.pumpAndSettle();

    expect(answerInterceptor.isDone, true);
    final textFinder = find.text('Wrong answer. Try again!');
    expect(textFinder, findsOneWidget);
  });

  testWidgets('Checks answer when correct', (tester) async {
    final questionInterceptor = nock.get("/topics/1/questions")
      ..reply(200, {
        "id": 2,
        "question": "What is the outcome of 100 + 100?",
        "options": ["200", "100", "20", "8"],
        "answer_post_path": "/topics/1/questions/2/answers"
      });

    final answerInterceptor = nock
        .post("/topics/1/questions/2/answers", {"answer": "200"})
      ..reply(200, {"correct": true});

    const app =
        ProviderScope(child: MaterialApp(home: QuestionWidget(1, false)));
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    expect(questionInterceptor.isDone, true);

    await tester.tap(find.text('200'));
    await tester.pumpAndSettle();

    expect(answerInterceptor.isDone, true);
    final textFinder = find.text('Correct answer!');
    expect(textFinder, findsOneWidget);

    final buttonFinder = find.text('Next question');
    expect(buttonFinder, findsOneWidget);
  });
}

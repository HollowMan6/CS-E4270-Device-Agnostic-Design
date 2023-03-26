// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nock/nock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiz/main.dart';
import 'package:quiz/class/statistic.dart';

void main() {
  setUpAll(() {
    nock.defaultBase = 'https://dad-quiz-api.deno.dev';
    nock.init();
  });

  setUp(() {
    nock.cleanAll();
  });

  testWidgets(
      'Generic practice options fetches question for topic with smallest score',
      (tester) async {
    final topicsInterceptor = nock.get("/topics")
      ..reply(
        200,
        [
          {
            "id": 1,
            "name": "Basic arithmetics",
            "question_path": "/topics/1/questions"
          },
          {
            "id": 2,
            "name": "Countries and capitals",
            "question_path": "/topics/2/questions"
          },
          {
            "id": 3,
            "name": "Countries and continents",
            "question_path": "/topics/3/questions"
          },
          {
            "id": 4,
            "name": "Dog breeds",
            "question_path": "/topics/4/questions"
          }
        ],
      );

    final questionInterceptor = nock.get("/topics/3/questions")
      ..reply(200, {
        "id": 7,
        "question": "In what continent is Argentina located?",
        "options": ["Africa", "Asia", "America"],
        "answer_post_path": "/topics/3/questions/7/answers"
      });

    SharedPreferences.setMockInitialValues({
      '1': 3,
      '2': 2,
      '4': 4,
      'total': 9,
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    final app = ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          home: QuizApp(),
        ));

    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    expect(topicsInterceptor.isDone, true);

    await tester.scrollUntilVisible(
      find.text('Generic practice'),
      500.0,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('Generic practice'));
    await tester.pumpAndSettle();

    expect(questionInterceptor.isDone, true);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nock/nock.dart';
import 'package:quiz/class/topic.dart';

void main() {
  setUpAll(() {
    nock.defaultBase = 'https://dad-quiz-api.deno.dev';
    nock.init();
  });

  setUp(() {
    nock.cleanAll();
  });

  testWidgets('Display no topics available text', (tester) async {
    final topicsInterceptor = nock.get("/topics")
      ..reply(
        200,
        [],
      );

    const app = ProviderScope(
        child: MaterialApp(
      home: TopicList(),
    ));
    await tester.pumpWidget(app);

    expect(topicsInterceptor.isDone, true);
    final topicFinder = find.text('No topics available');
    expect(topicFinder, findsOneWidget);
  });

  testWidgets('Displays topics', (tester) async {
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

    const app = ProviderScope(
        child: MaterialApp(
      home: TopicList(),
    ));
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    expect(topicsInterceptor.isDone, true);

    final topicFinder = find.text('Dog breeds');
    expect(topicFinder, findsOneWidget);

    final buttonFinder = find.byType(ElevatedButton);
    expect(buttonFinder, findsNWidgets(5));
  });
}

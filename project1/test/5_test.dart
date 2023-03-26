// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nock/nock.dart';
import 'package:quiz/class/statistic.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    nock.defaultBase = 'https://dad-quiz-api.deno.dev';
    nock.init();
  });

  setUp(() {
    nock.cleanAll();
  });
  testWidgets('Show total answer counts', (tester) async {
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

    SharedPreferences.setMockInitialValues({
      '1': 3,
      '2': 2,
      '4': 4,
      'total': 9,
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    final app = ProviderScope(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ], child: const MaterialApp(home: StatisticsWidget()));
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    final textFinder = find.text('All topics');
    expect(textFinder, findsOneWidget);
    final totalsFinder = find.text('9');
    expect(totalsFinder, findsOneWidget);
  });

  testWidgets('Show answer counts per topic', (tester) async {
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

    SharedPreferences.setMockInitialValues({
      '1': 3,
      '2': 2,
      '4': 4,
      'total': 9,
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    final app = ProviderScope(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ], child: const MaterialApp(home: StatisticsWidget()));
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    final textFinder = find.text('Basic arithmetics');
    expect(textFinder, findsOneWidget);
    final totalsFinder = find.text('3');
    expect(totalsFinder, findsOneWidget);
  });

  testWidgets('Show 0 if there are no stats for the topic', (tester) async {
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

    SharedPreferences.setMockInitialValues({
      '1': 3,
      '2': 2,
      '4': 4,
      'total': 9,
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    final app = ProviderScope(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ], child: const MaterialApp(home: StatisticsWidget()));
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    final textFinder = find.text('Countries and continents');
    expect(textFinder, findsOneWidget);
    final countsFinder = find.text('0');
    expect(countsFinder, findsOneWidget);
  });
}

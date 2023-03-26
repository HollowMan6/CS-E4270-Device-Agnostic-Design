import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz/class/statistic.dart';
import 'package:quiz/class/question.dart';
import 'package:quiz/class/topic.dart';
import 'package:quiz/util/screen_wrapper.dart';

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        routerConfig: GoRouter(
      routes: [
        GoRoute(
            path: '/',
            builder: (context, state) =>
                const ScreenWrapper(Center(child: TopicList()))),
        GoRoute(
            path: '/statistics',
            builder: (context, state) =>
                const ScreenWrapper(StatisticsWidget())),
        GoRoute(
            path: '/topics/:id',
            builder: (context, state) =>
                QuestionScreen(int.parse(state.params['id']!))),
        GoRoute(
            path: '/practice/:id',
            builder: (context, state) => QuestionScreen(
                int.parse(state.params['id']!),
                genericPractice: true)),
      ],
    ));
  }
}

main() async {
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(overrides: [
    sharedPreferencesProvider.overrideWithValue(prefs),
  ], child: const QuizApp()));
}

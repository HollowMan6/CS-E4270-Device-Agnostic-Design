import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ScreenWrapper extends ConsumerWidget {
  final Widget widget;
  const ScreenWrapper(this.widget, {super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Quizz App'),
        actions: <Widget>[
          TextButton(
            onPressed: () => context.go('/'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            child: const Text('Topics'),
          ),
          TextButton(
            onPressed: () => context.go('/statistics'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            child: const Text('Statistics'),
          ),
        ],
      ),
      body: widget,
    );
  }
}

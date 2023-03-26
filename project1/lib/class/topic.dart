import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz/class/service.dart';
import 'package:quiz/util/stats_utils.dart';
import 'package:quiz/class/statistic.dart';

class Topic {
  int id;
  String name;
  String questionPath;

  Topic(this.id, this.name, this.questionPath);

  Topic.fromJson(Map<String, dynamic> jsonData)
      : id = jsonData['id'],
        name = jsonData['name'],
        questionPath = jsonData['question_path'];
}

class TopicStat {
  int topicId;
  String name;
  int score;

  TopicStat({required this.topicId, required this.name, required this.score});
}

class TopicsNotifier extends StateNotifier<List<Topic>> {
  final questionService = QuizService();
  TopicsNotifier() : super([]);

  _initialize() async {
    state = await questionService.getTopics();
  }
}

final topicsProvider =
    StateNotifierProvider<TopicsNotifier, List<Topic>>((ref) {
  final topicsNotifier = TopicsNotifier();
  topicsNotifier._initialize();
  return topicsNotifier;
});

class TopicList extends ConsumerWidget {
  const TopicList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topics = ref.watch(topicsProvider);
    const help = [
      Text('Please select a topic to answer questions'),
      Text('Check your achievement with "Statistics"'),
      Text('Select "Generic practice" to practice your weakest topic.'),
    ];
    return SingleChildScrollView(
        child: Column(
            children: topics.isNotEmpty
                ? [
                    ...help,
                    ...topics.map((topic) => ElevatedButton(
                        onPressed: () => context.go('/topics/${topic.id}'),
                        child: Text(topic.name))),
                    ElevatedButton(
                        onPressed: () {
                          int genericPracticeTopicId =
                              getTopicIdForGenericPractice(
                                  topics, ref.read(statisticsProvider));
                          context.go('/practice/$genericPracticeTopicId');
                        },
                        child: const Text('Generic practice')),
                  ]
                : [...help, const Text('No topics available')]));
  }
}

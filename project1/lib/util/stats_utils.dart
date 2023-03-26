import 'dart:math';
import 'package:quiz/class/topic.dart';

List<TopicStat> getSortedTopicStats(
    List<Topic> topics, Map<String, dynamic> stats) {
  List<TopicStat> topicsStats = [];

  for (final topic in topics) {
    int topicId = topic.id;
    topicsStats.add(TopicStat(
        topicId: topicId,
        name: topic.name,
        score: stats[topicId.toString()] ?? 0));
  }
  topicsStats.sort((a, b) => b.score.compareTo(a.score));

  return topicsStats;
}

int getTopicIdForGenericPractice(
    List<Topic> topics, Map<String, dynamic> stats) {
  if (topics.isEmpty) return -1;

  List<int> topicScores = [];
  List<TopicStat> topicsStats = [];

  for (final topic in topics) {
    int topicId = topic.id;
    int score = stats[topicId.toString()] ?? 0;
    topicScores.add(score);
    topicsStats
        .add(TopicStat(topicId: topicId, name: topic.name, score: score));
  }
  int minScore = topicScores.isNotEmpty ? topicScores.reduce(min) : -1;
  Iterable<int> topicIdsForGenericPractice = topicsStats
      .where((t) => t.score == minScore)
      .map((t) => t.topicId)
      .toList()
    ..shuffle();

  return topicIdsForGenericPractice.first;
}

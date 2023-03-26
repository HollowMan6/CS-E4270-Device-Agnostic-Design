import 'package:flutter_test/flutter_test.dart';
import 'package:quiz/class/topic.dart';
import 'package:quiz/util/stats_utils.dart';

void main() {
  final List<Topic> topics = [
    Topic(1, "Basic arithmetics", "/topics/1/questions"),
    Topic(2, "Countries and capitals", "/topics/2/questions"),
    Topic(3, "Countries and continents", "/topics/3/questions"),
    Topic(4, "Dog breeds", "/topics/4/questions")
  ];

  final stats = {
    '1': 3,
    '2': 2,
    '4': 4,
    'total': 9,
  };
  test('Stats are sorted in descending order', () async {
    final sortedTopics = getSortedTopicStats(topics, stats);
    expect(sortedTopics.first.name, "Dog breeds");
    expect(sortedTopics.last.name, "Countries and continents");
  });

  test('Generic practice topic is the one with fewest correct answers',
      () async {
    final topicId = getTopicIdForGenericPractice(topics, stats);
    expect(topicId, 3);
  });
}

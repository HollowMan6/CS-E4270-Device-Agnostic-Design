import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:quiz/util/screen_wrapper.dart';
import 'package:quiz/util/stats_utils.dart';
import 'package:quiz/class/topic.dart';

final sharedPreferencesProvider =
    Provider<SharedPreferences>((ref) => throw UnimplementedError());

class StatisticsNotifier extends StateNotifier<Map<String, dynamic>> {
  final SharedPreferences prefs;
  StatisticsNotifier(this.prefs) : super({});

  _initialize() async {
    final keys = prefs.getKeys();
    final prefsMap = <String, dynamic>{};
    for (String key in keys) {
      prefsMap[key] = prefs.get(key);
    }
    state = prefsMap;
  }

  incrementTopicStat(int topicId) async {
    int topicCount = prefs.getInt('$topicId') ?? 0;
    state['$topicId'] = topicCount + 1;
    prefs.setInt('$topicId', topicCount + 1);

    int totalCount = prefs.getInt('total') ?? 0;
    state['total'] = totalCount + 1;
    prefs.setInt('total', totalCount + 1);
  }
}

final statisticsProvider =
    StateNotifierProvider<StatisticsNotifier, Map<String, dynamic>>((ref) {
  final statsNotifier =
      StatisticsNotifier(ref.watch(sharedPreferencesProvider));
  statsNotifier._initialize();
  return statsNotifier;
});

class StatisticsWidget extends ConsumerWidget {
  const StatisticsWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statisticsProvider);
    final topics = ref.watch(topicsProvider);

    List<TopicStat> topicsStats = getSortedTopicStats(topics, stats);

    return SingleChildScrollView(
        child: Center(
            child: Column(
      children: [
        const Text('Statistics'),
        Table(
          border: TableBorder.all(),
          columnWidths: const <int, TableColumnWidth>{
            0: IntrinsicColumnWidth(),
            1: IntrinsicColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            const TableRow(
              children: [
                Text('Topic'),
                Text('Correct'),
              ],
            ),
            TableRow(
              children: <Widget>[
                const Text('All topics'),
                Text('${stats['total'] ?? 0}'),
              ],
            ),
            ...topicsStats.map((stat) => TableRow(children: [
                  Text(stat.name),
                  Text('${stat.score}'),
                ])),
          ],
        )
      ],
    )));
  }
}

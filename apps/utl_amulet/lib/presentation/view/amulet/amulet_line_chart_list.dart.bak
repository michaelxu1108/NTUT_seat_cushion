import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../change_notifier/amulet/amulet_line_chart_change_notifier.dart';
import '../../change_notifier/amulet/amulet_line_chart_filtered_change_notifier.dart';
import '../../change_notifier/amulet/mapper/mapper.dart';

import 'amulet_line_chart.dart';

class AmuletLineChartList extends StatelessWidget {
  const AmuletLineChartList({super.key});
  Iterable<AmuletLineChartItem> _getItems() sync* {
    for(var item in AmuletLineChartItem.values) {
      switch(item) {
        case AmuletLineChartItem.temperature:
        case AmuletLineChartItem.adc:
        case AmuletLineChartItem.battery:
        case AmuletLineChartItem.step:
        case AmuletLineChartItem.direction:
        case AmuletLineChartItem.area:
          continue;
        default:
          yield item;
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final lineChartManager = context.read<AmuletLineChartManagerChangeNotifier>();
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final height = constraints.maxHeight / 2.5;
        final items = _getItems().toList();
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => SizedBox(
            height: height,
            child: ChangeNotifierProvider(
              create: (_) => AmuletLineChartFilteredChangeNotifier(
                items: [
                  items.elementAt(index),
                ],
                amuletLineChartManagerChangeNotifier: lineChartManager,
              ),
              child: const AmuletLineChart(),
            ),
          ),
        );
      },
    );
  }
}

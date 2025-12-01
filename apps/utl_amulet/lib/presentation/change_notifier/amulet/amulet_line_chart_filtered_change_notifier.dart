import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'amulet_line_chart_change_notifier.dart';
import 'mapper/mapper.dart';

class AmuletLineChartFilteredChangeNotifier extends ChangeNotifier {
  final List<AmuletLineChartItem> items;
  final AmuletLineChartManagerChangeNotifier amuletLineChartManagerChangeNotifier;
  AmuletLineChartFilteredChangeNotifier({
    required this.items,
    required this.amuletLineChartManagerChangeNotifier,
  }) {
    amuletLineChartManagerChangeNotifier.addListener(notifyListeners);
  }
  List<LineSeries<Point<num>, double>> createLineSeriesList() {
    if(amuletLineChartManagerChangeNotifier.firstData == null) return [];
    return sensorDataDtoToFilteredSeriesList(
      firstData: amuletLineChartManagerChangeNotifier.firstData!,
      dataList: amuletLineChartManagerChangeNotifier.dataList,
      items: items,
    );
  }
  @override
  void dispose() {
    amuletLineChartManagerChangeNotifier.removeListener(notifyListeners);
    super.dispose();
  }
}

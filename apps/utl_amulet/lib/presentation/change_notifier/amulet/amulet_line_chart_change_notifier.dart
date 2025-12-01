import 'dart:async';
import 'dart:math';

import 'package:line_chart_utils/line_chart_change_notifier.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:synchronized/synchronized.dart';
import 'package:utl_amulet/presentation/change_notifier/amulet/mapper/mapper.dart';

import '../../../service/data_stream/amulet_sensor_data_stream.dart';

class AmuletLineChartManagerChangeNotifier extends LineChartChangeNotifier<double> {
  static const maxLength = 100;
  final AmuletSensorDataStream amuletSensorDataStream;
  late final StreamSubscription _subscription;
  final Lock _lock = Lock();
  AmuletSensorData? firstData;
  final List<AmuletSensorData> dataListSync = [];
  List<AmuletSensorData> dataListOnTouched = [];
  List<AmuletSensorData> get dataList => (isTouched)
    ? dataListOnTouched
    : dataListSync;
  AmuletLineChartManagerChangeNotifier({
    required super.x,
    required this.amuletSensorDataStream,
  }) {
    _subscription = amuletSensorDataStream.dataStream.listen((data) {
      _lock.synchronized(() {
        firstData ??= data;
        dataListSync.add(data);
        if(dataListSync.length > maxLength) dataListSync.removeAt(0);
        if(!isTouched) dataListOnTouched = dataListSync.toList(growable: false);
        notifyListeners();
      });
    });
  }
  List<LineSeries<Point<num>, double>> createLineSeriesList() {
    if(firstData == null) return [];
    return sensorDataDtoToSeriesList(
      firstData: firstData!,
      dataList: dataList,
    );
  }
  String getXName() {
    return 'Time';
  }
  String getItemName({
    required AmuletLineChartItem item,
  }) {
    return amuletLineChartItemToName(item: item);
  }
  double? getSensorX() {
    if(isTouched) return x;
    final last = dataListSync.lastOrNull;
    return (last != null && firstData != null)
      ? sensorDataTimeDifference(startDateTime: firstData!.time, data: last)
      : null;
  }
  AmuletSensorData? getSensorDataByX() {
    return dataList.where((d) {
      if(firstData == null) return false;
      return sensorDataTimeDifference(startDateTime: firstData!.time, data: d) == x;
    }).firstOrNull;
  }
  num getData({
    required AmuletSensorData data,
    required AmuletLineChartItem item,
  }) {
    return amuletLineChartItemToData(item: item, data: data);
  }
  AmuletSensorData? getLastSensorData() {
    return dataList.lastOrNull;
  }
  void clear() {
    _lock.synchronized(() {
      firstData = null;
      dataList.clear();
    });
  }
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

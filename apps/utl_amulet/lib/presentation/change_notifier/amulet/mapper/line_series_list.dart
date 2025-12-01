part of 'mapper.dart';

LineSeries<Point<num>, double> _sensorDataDtoToSeries({
  required AmuletSensorData firstData,
  required Iterable<AmuletSensorData> dataList,
  required AmuletLineChartItem item,
}) {
  return LineSeries<Point, double>(
    name: amuletLineChartItemToName(item: item),
    dataSource: _sensorDataDtoToDataSource(
      dataList: dataList,
      startDateTime: firstData.time,
      item: item,
    ),
    animationDuration: 0,
    xValueMapper: (Point data, _) => data.x.toDouble(),
    yValueMapper: (Point data, _) => data.y.toDouble(),
    color: _amuletSeriesItemColors[item],
    width: 1.5,
    // markerSettings: MarkerSettings(isVisible: true),
  );
}

List<LineSeries<Point<num>, double>> sensorDataDtoToSeriesList({
  required AmuletSensorData firstData,
  required Iterable<AmuletSensorData> dataList,
}) {
  if(dataList.isEmpty) return [];
  return AmuletLineChartItem.values.map((item) => _sensorDataDtoToSeries(
    firstData: firstData,
    dataList: dataList,
    item: item,
  )).toList();
}

List<LineSeries<Point<num>, double>> sensorDataDtoToFilteredSeriesList({
  required AmuletSensorData firstData,
  required Iterable<AmuletSensorData> dataList,
  required Iterable<AmuletLineChartItem> items,
}) {
  if(dataList.isEmpty) return [];
  return items.map((item) => _sensorDataDtoToSeries(
    firstData: firstData,
    dataList: dataList,
    item: item,
  )).toList();
}

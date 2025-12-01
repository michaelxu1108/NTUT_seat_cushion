part of 'mapper.dart';

String amuletLineChartItemToName({
  required AmuletLineChartItem item,
}) {
  switch (item) {
    case AmuletLineChartItem.accX:
      return 'Acc X';
    case AmuletLineChartItem.accY:
      return 'Acc Y';
    case AmuletLineChartItem.accZ:
      return 'Acc Z';
    case AmuletLineChartItem.accTotal:
      return 'Acc Total';
    case AmuletLineChartItem.magX:
      return 'Mag X';
    case AmuletLineChartItem.magY:
      return 'Mag Y';
    case AmuletLineChartItem.magZ:
      return 'Mag Z';
    case AmuletLineChartItem.magTotal:
      return 'Mag Total';
    case AmuletLineChartItem.pitch:
      return 'Pitch';
    case AmuletLineChartItem.roll:
      return 'Roll';
    case AmuletLineChartItem.yaw:
      return 'Yaw';
    case AmuletLineChartItem.pressure:
      return 'Pressure';
    case AmuletLineChartItem.temperature:
      return 'Temperature';
    case AmuletLineChartItem.posture:
      return 'Posture';
    case AmuletLineChartItem.adc:
      return 'ADC';
    case AmuletLineChartItem.battery:
      return 'Battery';
    case AmuletLineChartItem.area:
      return 'Area';
    case AmuletLineChartItem.step:
      return 'Step';
    case AmuletLineChartItem.direction:
      return 'Direction';
  }
}

import 'package:flutter/widgets.dart';

import '../../domain/entity/amulet_entity.dart';

class AmuletSensorData extends AmuletEntity {
  @protected
  @override
  int get id => super.id;
  AmuletSensorData({
    required super.deviceId,
    required super.time,
    required super.accX,
    required super.accY,
    required super.accZ,
    required super.accTotal,
    required super.magX,
    required super.magY,
    required super.magZ,
    required super.magTotal,
    required super.pitch,
    required super.roll,
    required super.yaw,
    required super.pressure,
    required super.temperature,
    required super.posture,
    required super.adc,
    required super.battery,
    required super.area,
    required super.step,
    required super.direction,
  }) : super(
    id: 0,
  );
}

abstract class AmuletSensorDataStream {
  Stream<AmuletSensorData> get dataStream;
}

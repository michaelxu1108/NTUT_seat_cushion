import 'dart:async';

import 'package:utl_amulet/service/data_stream/amulet_sensor_data_stream.dart';

import '../../source/bluetooth/bluetooth_module.dart';

class AmuletSensorDataStreamImpl implements AmuletSensorDataStream {
  final BluetoothModule bluetoothModule;

  AmuletSensorDataStreamImpl({
    required this.bluetoothModule,
  });

  @override
  Stream<AmuletSensorData> get dataStream => bluetoothModule
    .onReceivePacket
    .map((packet) => packet.mapToData())
    .where((dto) => dto != null)
    .map((dto) => dto!);
}

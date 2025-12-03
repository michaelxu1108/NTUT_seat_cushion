import 'dart:typed_data';

import 'package:utl_amulet/domain/entity/amulet_entity.dart';
import 'package:utl_amulet/service/data_stream/amulet_sensor_data_stream.dart';

class BluetoothReceivedPacket {
  const BluetoothReceivedPacket({
    required this.deviceId,
    required this.deviceName,
    required this.data,
  });
  final String deviceId;
  final String deviceName;
  final Uint8List data;
  @override
  String toString() {
    return "BluetoothReceivedPacket: "
        "\n\tdeviceId: $deviceId"
        "\n\tdeviceName: $deviceName"
        "\n\tdata: $data"
    ;
  }
  AmuletSensorData? mapToData() {
    if(data.length < 37) return null;  // 至少需要 37 bytes (包含 point)
    final bytes = ByteData.sublistView(data);
    final postureByte = bytes.getUint8(26);
    if(postureByte >= AmuletPostureType.values.length) return null;

    return AmuletSensorData(
      deviceId: deviceId,
      time: DateTime.now(),
      // 修改：所有 16-bit 數值從 little endian 改為 big endian
      accX: bytes.getInt16(0, Endian.big),          // [0][1] 先高後低
      accY: bytes.getInt16(2, Endian.big),          // [2][3] 先高後低
      accZ: bytes.getInt16(4, Endian.big),          // [4][5] 先高後低
      accTotal: bytes.getUint16(6, Endian.big),     // [6][7] 先高後低
      roll: bytes.getInt16(8, Endian.big),          // [8][9] 先高後低
      pitch: bytes.getInt16(10, Endian.big),        // [10][11] 先高後低
      yaw: bytes.getInt16(12, Endian.big),          // [12][13] 先高後低
      magX: bytes.getInt16(14, Endian.big),         // [14][15] 先高後低
      magY: bytes.getInt16(16, Endian.big),         // [16][17] 先高後低
      magZ: bytes.getInt16(18, Endian.big),         // [18][19] 先高後低
      magTotal: bytes.getUint16(20, Endian.big),    // [20][21] 先高後低
      temperature: bytes.getUint16(24, Endian.big), // [24][25] 先高後低
      posture: AmuletPostureType.values[postureByte], // [26]
      beaconRssi: bytes.getInt16(27, Endian.big),   // [27][28] 新增 Beacon RSSI (先高後低)
      direction: bytes.getUint8(29),                // [29]
      adc: bytes.getInt16(30, Endian.big),          // [30][31] 先高後低
      battery: bytes.getUint8(32),                  // [32]
      area: bytes.getUint8(33),                     // [33]
      step: bytes.getInt16(34, Endian.big),         // [34][35] 先高後低
      point: bytes.getUint8(36),                    // [36] 新增 Point
      pressure: bytes.getFloat32(38, Endian.little), // [38-41] 保持 little endian (Float32)
    );
  }
}

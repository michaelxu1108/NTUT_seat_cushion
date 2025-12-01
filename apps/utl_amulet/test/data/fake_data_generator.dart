import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:utl_amulet/infrastructure/source/bluetooth/bluetooth_received_packet.dart';

class FakeDataGenerator {
  BluetoothReceivedPacket createFakeBluetoothReceivedPacket() {
    return BluetoothReceivedPacket(
      deviceId: '123',
      deviceName: 'SuYian',
      data: Uint8List.fromList(List.generate(50, (_) {
        return Random.secure().nextInt(0x100);
      })),
    );
  }
}
import 'dart:async';

import 'package:utl_amulet/init/resource/infrastructure/bluetooth_resource.dart';
import 'package:utl_amulet/main.dart' as home;

import 'data/fake_data_generator.dart';

Future<void> main() async {
  await home.main();
  final fakeDataGenerator = FakeDataGenerator();
  Timer.periodic(const Duration(milliseconds: 10), (timer) {
    BluetoothResource.bluetoothModule.mockPacket(fakeDataGenerator.createFakeBluetoothReceivedPacket());
  });
}

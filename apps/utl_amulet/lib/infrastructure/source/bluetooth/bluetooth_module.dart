import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:flutter/material.dart';

import '../../../init/resource/infrastructure/bluetooth_resource.dart';
import 'bluetooth_received_packet.dart';

class BluetoothModule {
  final Map<String, fbp.BluetoothDevice> _connectedDevices = {};
  final Map<String, List<StreamSubscription>> _deviceSubscriptions = {};
  final StreamController<BluetoothReceivedPacket> _controller = StreamController.broadcast();
  late final StreamSubscription _connectionStateSubscription;

  BluetoothModule() {
    // Listen to connection state changes
    _connectionStateSubscription = fbp.FlutterBluePlus.events.onConnectionStateChanged.listen((event) {
      final device = event.device;
      final state = event.connectionState;

      if (state == fbp.BluetoothConnectionState.connected) {
        _onDeviceConnected(device);
      } else if (state == fbp.BluetoothConnectionState.disconnected) {
        _onDeviceDisconnected(device);
      }
    });
  }

  Future<void> _onDeviceConnected(fbp.BluetoothDevice device) async {
    _connectedDevices[device.remoteId.str] = device;

    try {
      // Discover services
      final services = await device.discoverServices();
      final subscriptions = <StreamSubscription>[];

      // Subscribe to characteristics with receivedUuids
      for (final service in services) {
        for (final characteristic in service.characteristics) {
          for (final uuid in BluetoothResource.receivedUuids) {
            if (characteristic.uuid.toString().toLowerCase() == uuid.toLowerCase()) {
              // Enable notifications
              await characteristic.setNotifyValue(true);

              // Listen to value changes
              final sub = characteristic.lastValueStream.listen((value) {
                if (value.isNotEmpty) {
                  _controller.add(BluetoothReceivedPacket(
                    data: Uint8List.fromList(value),
                    deviceName: device.platformName,
                    deviceId: device.remoteId.str,
                  ));
                }
              });
              subscriptions.add(sub);
            }
          }
        }
      }

      _deviceSubscriptions[device.remoteId.str] = subscriptions;
    } catch (e) {
      debugPrint('Error setting up device ${device.platformName}: $e');
    }
  }

  void _onDeviceDisconnected(fbp.BluetoothDevice device) {
    final deviceId = device.remoteId.str;

    // Cancel all subscriptions for this device
    final subscriptions = _deviceSubscriptions[deviceId];
    if (subscriptions != null) {
      for (final sub in subscriptions) {
        sub.cancel();
      }
      _deviceSubscriptions.remove(deviceId);
    }

    _connectedDevices.remove(deviceId);
  }

  @visibleForTesting
  @pragma('vm:notify-debugger-on-exception')
  void mockPacket(BluetoothReceivedPacket packet) {
    _controller.add(packet);
  }

  Stream<BluetoothReceivedPacket> get onReceivePacket => _controller.stream;

  Future<bool> sendCommand({required String command}) async {
    try {
      // Convert hex string to bytes
      final bytes = _hexStringToBytes(command);

      // Send to all connected devices
      for (final device in _connectedDevices.values) {
        final services = await device.discoverServices();

        for (final service in services) {
          for (final characteristic in service.characteristics) {
            for (final uuid in BluetoothResource.sentUuids) {
              if (characteristic.uuid.toString().toLowerCase() == uuid.toLowerCase()) {
                if (characteristic.properties.write) {
                  await characteristic.write(bytes, withoutResponse: false);
                } else if (characteristic.properties.writeWithoutResponse) {
                  await characteristic.write(bytes, withoutResponse: true);
                }
              }
            }
          }
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error sending command: $e');
      return false;
    }
  }

  List<int> _hexStringToBytes(String hex) {
    // Remove spaces and convert hex string to bytes
    final cleanHex = hex.replaceAll(' ', '');
    final bytes = <int>[];

    for (int i = 0; i < cleanHex.length; i += 2) {
      final hexByte = cleanHex.substring(i, i + 2);
      bytes.add(int.parse(hexByte, radix: 16));
    }

    return bytes;
  }

  void cancel() {
    _connectionStateSubscription.cancel();

    // Cancel all device subscriptions
    for (final subscriptions in _deviceSubscriptions.values) {
      for (final sub in subscriptions) {
        sub.cancel();
      }
    }
    _deviceSubscriptions.clear();
    _connectedDevices.clear();

    _controller.close();
  }
}

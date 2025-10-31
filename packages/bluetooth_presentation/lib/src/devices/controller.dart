part of 'bluetooth_device_tile.dart';

/// Provides logic for scanning and managing Bluetooth devices.
/// Intended to be mixed into classes that extend [ChangeNotifier].
///
/// **References**
/// - [BluetoothDevice]
/// - [fbp.BluetoothDevice]
mixin BluetoothDevicesController on ChangeNotifier {
  final List<StreamSubscription> _sub = [];

  // Flutter Blue Plus
  @protected
  late final bool fbpIsSupported;
  @protected
  Set<fbp.BluetoothDevice> fbpSystemDevices = {};
  @protected
  Iterable<fbp.BluetoothDevice> get fbpAllDevices => {
    ...fbpSystemDevices,
    ...BondFlutterBluePlus.bondedDevices,
    ...ScanResultFlutterBluePlus.lastScannedDevices,
  };

  @mustCallSuper
  @protected
  void init({
    required bool fbpIsSupported,
    bool Function(fbp.BluetoothDevice device)? fbpIsSelected,
    required List<fbp.BluetoothDevice> fbpSystemDevices,
    void Function(fbp.BluetoothDevice device)? fbpToggleSelection,
  }) {
    // Flutter Blue Plus
    this.fbpIsSupported = fbpIsSupported;
    this.fbpIsSelected = fbpIsSelected;
    this.fbpSystemDevices = fbpSystemDevices.toSet();
    this.fbpToggleSelection = fbpToggleSelection;
    if (fbpIsSupported) {
      _sub.addAll([
        fbp.FlutterBluePlus.isScanning.listen((_) {
          notifyListeners();
        }),
        BondFlutterBluePlus.onBondStateChanged.listen((_) {
          notifyListeners();
        }),
        ConnectionStateFlutterBluePlus.onConnectionStateChanged.listen((_) {
          notifyListeners();
        }),
        RssiFlutterBluePlus.onAllRssi.listen((_) {
          notifyListeners();
        }),
        ScanResultFlutterBluePlus.onScanResponse.listen((_) {
          notifyListeners();
        }),
      ]);
    }
  }

  Future<void> setScanning(bool isOn) async {
    for (final permission in bluetoothPermissions) {
      if (!(await permission.request()).isGranted) {
        return;
      }
    }
    if (isOn) {
      // Flutter Blue Plus
      if (fbpIsSupported) {
        try {
          debugPrint('🔍 開始藍牙掃描...');
          fbpSystemDevices = (await fbp.FlutterBluePlus.systemDevices(
            [],
          )).toSet();
          debugPrint('   系統設備數量: ${fbpSystemDevices.length}');
          await BondFlutterBluePlus.updateBondedDevices();
          debugPrint('   已配對設備數量: ${BondFlutterBluePlus.bondedDevices.length}');
          await fbp.FlutterBluePlus.startScan(
            timeout: const Duration(seconds: 15),
          );
        } catch (e) {
          debugPrint('❌ 掃描啟動失敗: $e');
        }
      }
    } else {
      // Flutter Blue Plus
      if (fbpIsSupported) {
        try {
          await fbp.FlutterBluePlus.stopScan();
          debugPrint('🛑 藍牙掃描已停止');
          debugPrint(
            '   總共掃描到設備: ${ScanResultFlutterBluePlus.lastScannedDevices.length}',
          );
          for (final device in ScanResultFlutterBluePlus.lastScannedDevices) {
            debugPrint(
              '   - ${device.platformName.isEmpty ? "(無名稱)" : device.platformName} (${device.remoteId.str})',
            );
          }
        } catch (e) {
          debugPrint('❌ 掃描停止失敗: $e');
        }
      }
    }
    notifyListeners();
  }

  Future<void> toggleScanning() async {
    for (final permission in bluetoothPermissions) {
      if (!(await permission.request()).isGranted) {
        return;
      }
    }
    // Flutter Blue Plus
    await setScanning(!fbp.FlutterBluePlus.isScanningNow);
    return;
  }

  bool get isScanning {
    // Flutter Blue Plus
    if (!fbpIsSupported) return false;
    return fbp.FlutterBluePlus.isScanningNow;
  }

  // Flutter Blue Plus
  @protected
  bool Function(fbp.BluetoothDevice device)? fbpIsSelected;

  @protected
  void Function(fbp.BluetoothDevice device)? fbpToggleSelection;

  Iterable<BluetoothDevice> get devices =>
      // Flutter Blue Plus
      fbpAllDevices.map(fbpDeviceToDevice);

  // Flutter Blue Plus
  @protected
  fbp.BluetoothDevice? deviceToFbpDevice(BluetoothDevice device) {
    return fbpAllDevices.where((d) => d.remoteId.str == device.id).firstOrNull;
  }

  // Flutter Blue Plus
  @protected
  BluetoothDevice fbpDeviceToDevice(fbp.BluetoothDevice device) {
    final scanResult = ScanResultFlutterBluePlus.lastScanResults
        .where((r) => r.device == device)
        .firstOrNull;
    final isConnectable = scanResult?.advertisementData.connectable ?? false;

    // 診斷日誌：顯示設備的廣播資訊
    if (device.platformName.contains('UTL_Cushion')) {
      debugPrint('📱 設備掃描結果: ${device.platformName}');
      debugPrint('   MAC: ${device.remoteId.str}');
      debugPrint('   可連接: $isConnectable');
      debugPrint('   已連接: ${device.isConnected}');
      debugPrint(
        '   已配對: ${BondFlutterBluePlus.bondedDevices.contains(device)}',
      );
      debugPrint('   RSSI: ${device.rssi}');
      if (scanResult != null) {
        debugPrint('   廣播資料: ${scanResult.advertisementData}');
      }
    }
    VoidCallback? togglePairing;
    if (device.isBondable && !device.isBonded) {
      togglePairing = () async {
        for (final permission in bluetoothPermissions) {
          if (!(await permission.request()).isGranted) {
            return;
          }
        }
        try {
          await device.createBond();
        } catch (e) {
          debugPrint('❌ 配對失敗: $e');
        }
      };
    }
    if (device.isUnBondable && device.isBonded) {
      togglePairing = () async {
        for (final permission in bluetoothPermissions) {
          if (!(await permission.request()).isGranted) {
            return;
          }
        }
        try {
          await device.removeBond();
        } catch (e) {
          debugPrint('❌ 取消配對失敗: $e');
        }
      };
    }
    return BluetoothDevice(
      id: device.remoteId.str,
      inSystem: fbpSystemDevices.contains(device),
      isPaired: BondFlutterBluePlus.bondedDevices.contains(device),
      isConnectable: isConnectable,
      isConnected: device.isConnected,
      isScanned: ScanResultFlutterBluePlus.lastScannedDevices.contains(device),
      isSelected: fbpIsSelected?.call(device) ?? false,
      name: device.platformName,
      rssi: device.rssi ?? 0,
      tech: BluetoothTech.lowEnergy,
      toggleConnection: (isConnectable)
          ? () async {
              for (final permission in bluetoothPermissions) {
                if (!(await permission.request()).isGranted) {
                  return;
                }
              }
              if (device.isConnected) {
                try {
                  await device.disconnect(queue: true);
                } catch (e) {
                  debugPrint('❌ 斷開設備失敗: ${device.platformName}');
                }
              } else {
                try {
                  debugPrint(
                    '🔵 嘗試連接設備: ${device.platformName} (${device.remoteId.str})',
                  );
                  await device.connect(
                    license: License.free,
                    autoConnect: true,
                    mtu: null,
                  );
                  debugPrint('✅ 成功連接設備: ${device.platformName}');
                } catch (e) {
                  debugPrint('❌ 連接設備失敗: ${device.platformName}');
                  debugPrint('   錯誤詳情: $e');
                  rethrow;
                }
              }
            }
          : null,
      togglePairing: togglePairing,
      toggleSelection: (fbpToggleSelection != null)
          ? () => fbpToggleSelection!(device)
          : null,
    );
  }

  @mustCallSuper
  void cancelDevicesController() {
    for (final s in _sub) {
      s.cancel();
    }
  }
}

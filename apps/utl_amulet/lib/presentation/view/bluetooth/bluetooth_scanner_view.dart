import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

class BluetoothScannerView extends StatefulWidget {
  const BluetoothScannerView({super.key});

  @override
  State<BluetoothScannerView> createState() => _BluetoothScannerViewState();
}

class _BluetoothScannerViewState extends State<BluetoothScannerView> {
  List<fbp.ScanResult> _scanResults = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _scanResults = [];
    });

    try {
      // Start scanning
      await fbp.FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

      // Listen to scan results
      fbp.FlutterBluePlus.scanResults.listen((results) {
        if (mounted) {
          setState(() {
            _scanResults = results;
          });
        }
      });

      // Wait for scan to complete
      await fbp.FlutterBluePlus.isScanning.firstWhere((scanning) => !scanning);
    } catch (e) {
      debugPrint('Error during scan: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _stopScan() async {
    await fbp.FlutterBluePlus.stopScan();
    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _connectToDevice(fbp.BluetoothDevice device) async {
    try {
      await device.connect(license: fbp.License.free);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connected to device'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error connecting to device: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to connect'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Devices'),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.stop : Icons.refresh),
            onPressed: _isScanning ? _stopScan : _startScan,
          ),
        ],
      ),
      body: _isScanning && _scanResults.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _scanResults.length,
              itemBuilder: (context, index) {
                final result = _scanResults[index];
                final device = result.device;
                final deviceName = device.platformName.isEmpty
                    ? 'Unknown Device'
                    : device.platformName;

                return ListTile(
                  title: Text(deviceName),
                  subtitle: Text(device.remoteId.str),
                  trailing: StreamBuilder<fbp.BluetoothConnectionState>(
                    stream: device.connectionState,
                    initialData: fbp.BluetoothConnectionState.disconnected,
                    builder: (context, snapshot) {
                      final isConnected =
                          snapshot.data == fbp.BluetoothConnectionState.connected;

                      return ElevatedButton(
                        onPressed: isConnected
                            ? () => device.disconnect()
                            : () => _connectToDevice(device),
                        child: Text(isConnected ? 'Disconnect' : 'Connect'),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

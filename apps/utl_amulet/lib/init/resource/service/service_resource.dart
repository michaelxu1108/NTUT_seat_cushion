import 'package:utl_amulet/service/data_stream/amulet_sensor_data_stream.dart';

import '../../../service/file/file_handler.dart';

class ServiceResource {
  ServiceResource._();

  static AmuletSensorDataStream? _amuletSensorDataStream;
  static AmuletSensorDataStream get amuletSensorDataStream {
    final value = _amuletSensorDataStream;
    if (value == null) {
      throw StateError('ServiceResource not initialized. Call Initializer() first. This usually happens during Hot Reload - try Hot Restart instead (Shift+R).');
    }
    return value;
  }
  static set amuletSensorDataStream(AmuletSensorDataStream value) {
    _amuletSensorDataStream = value;
  }

  static FileHandler? _fileHandler;
  static FileHandler get fileHandler {
    final value = _fileHandler;
    if (value == null) {
      throw StateError('ServiceResource not initialized. Call Initializer() first. This usually happens during Hot Reload - try Hot Restart instead (Shift+R).');
    }
    return value;
  }
  static set fileHandler(FileHandler value) {
    _fileHandler = value;
  }
}

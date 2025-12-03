import 'package:utl_amulet/application/amulet_entity_creator.dart';
import 'package:utl_amulet/init/resource/data/data_resource.dart';
import 'package:utl_amulet/init/resource/service/service_resource.dart';

class ApplicationPersist {
  ApplicationPersist._();
  static void init() {
    _amuletEntityCreator = AmuletEntityCreatorImpl(
      amuletRepository: DataResource.amuletRepository,
      amuletSensorDataStream: ServiceResource.amuletSensorDataStream,
    );
  }

  static AmuletEntityCreator? _amuletEntityCreator;
  static AmuletEntityCreator get amuletEntityCreator {
    if (_amuletEntityCreator == null) {
      throw StateError('ApplicationPersist not initialized. Call Initializer() first.');
    }
    return _amuletEntityCreator!;
  }
}

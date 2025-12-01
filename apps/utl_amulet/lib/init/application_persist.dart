import 'package:utl_amulet/application/amulet_entity_creator.dart';
import 'package:utl_amulet/init/resource/data/data_resource.dart';
import 'package:utl_amulet/init/resource/service/service_resource.dart';

class ApplicationPersist {
  ApplicationPersist._();
  static void init() {
    amuletEntityCreator = AmuletEntityCreatorImpl(
      amuletRepository: DataResource.amuletRepository,
      amuletSensorDataStream: ServiceResource.amuletSensorDataStream,
    );
  }
  static late final AmuletEntityCreator amuletEntityCreator;
}

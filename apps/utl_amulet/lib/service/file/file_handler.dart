import 'package:utl_amulet/domain/entity/amulet_entity.dart';

abstract class FileHandler {
  Future<bool> downloadAmuletEntitiesFile({
    required Stream<AmuletEntity> fetchEntitiesStream,
  });
}

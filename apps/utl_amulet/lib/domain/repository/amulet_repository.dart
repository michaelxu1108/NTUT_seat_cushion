import 'package:utl_amulet/domain/entity/amulet_entity.dart';

abstract class AmuletRepository {
  Stream<AmuletEntity> get entitySyncStream;
  Stream<int> get entityIdRemovedStream;
  Stream<AmuletEntity> fetchEntities();
  Future<bool> upsert({
    required AmuletEntity entity,
  });
  Future<bool> delete({
    required int entityId,
  });
  Future<int> createId();
  Future<bool> clear();
}

import 'package:utl_amulet/domain/repository/amulet_repository.dart';

class DataResource {
  DataResource._();

  static AmuletRepository? _amuletRepository;
  static AmuletRepository get amuletRepository {
    if (_amuletRepository == null) {
      throw StateError('DataResource not initialized. Call Initializer() first.');
    }
    return _amuletRepository!;
  }
  static set amuletRepository(AmuletRepository value) {
    _amuletRepository = value;
  }
}

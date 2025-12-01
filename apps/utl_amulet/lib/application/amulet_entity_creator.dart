import 'dart:async';

import 'package:utl_amulet/domain/repository/amulet_repository.dart';
import 'package:utl_amulet/service/data_stream/amulet_sensor_data_stream.dart';

import '../adapter/usecase/save_amulet_sensor_data_to_repository_usecase.dart';

abstract class AmuletEntityCreator {
  bool get isCreating;
  Stream<bool> get isCreatingStream;
  void startCreating();
  void stopCreating();
  void toggleCreating();
}

class AmuletEntityCreatorImpl implements AmuletEntityCreator {
  final AmuletRepository amuletRepository;
  final AmuletSensorDataStream amuletSensorDataStream;
  final StreamController<bool> _controller = StreamController.broadcast();
  late final StreamSubscription _subscription;
  bool _isCreating = false;

  AmuletEntityCreatorImpl({
    required this.amuletRepository,
    required this.amuletSensorDataStream,
  }) {
    final saveAmuletSensorDataToRepositoryUsecase = SaveAmuletSensorDataToRepositoryUsecase(
      amuletRepository: amuletRepository,
    );
    _subscription = amuletSensorDataStream.dataStream.listen((data) {
      if(!_isCreating) return;
      saveAmuletSensorDataToRepositoryUsecase(data: data);
    });
  }

  @override
  bool get isCreating => _isCreating;

  @override
  void startCreating() {
    _isCreating = true;
    _controller.add(_isCreating);
  }

  @override
  void stopCreating() {
    _isCreating = false;
    _controller.add(_isCreating);
  }

  @override
  void toggleCreating() {
    return (isCreating)
      ? stopCreating()
      : startCreating();
  }

  @override
  Stream<bool> get isCreatingStream => _controller.stream;

  void close() {
    _subscription.cancel();
    _controller.close();
  }
}

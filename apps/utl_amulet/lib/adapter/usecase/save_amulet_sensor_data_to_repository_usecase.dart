import 'package:utl_amulet/domain/entity/amulet_entity.dart';
import 'package:utl_amulet/domain/repository/amulet_repository.dart';
import 'package:utl_amulet/service/data_stream/amulet_sensor_data_stream.dart';

class SaveAmuletSensorDataToRepositoryUsecase {
  final AmuletRepository amuletRepository;
  SaveAmuletSensorDataToRepositoryUsecase({
    required this.amuletRepository,
  });
  call({
    required AmuletSensorData data,
  }) async {
    return amuletRepository.upsert(
      entity: AmuletEntity(
        id: await amuletRepository.createId(),
        deviceId: data.deviceId,
        time: data.time,
        accX: data.accX,
        accY: data.accY,
        accZ: data.accZ,
        accTotal: data.accTotal,
        magX: data.magX,
        magY: data.magY,
        magZ: data.magZ,
        magTotal: data.magTotal,
        pitch: data.pitch,
        roll: data.roll,
        yaw: data.yaw,
        pressure: data.pressure,
        temperature: data.temperature,
        posture: data.posture,
        adc: data.adc,
        battery: data.battery,
        area: data.area,
        step: data.step,
        direction: data.direction,
      ),
    );
  }
}

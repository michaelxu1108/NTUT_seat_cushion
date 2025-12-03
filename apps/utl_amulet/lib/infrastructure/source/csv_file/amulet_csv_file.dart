import 'package:file_utils/csv/simple_csv_file.dart';
import 'package:utl_amulet/l10n/gen_l10n/app_localizations.dart';
import 'package:synchronized/synchronized.dart';
import 'package:utl_amulet/domain/entity/amulet_entity.dart';

class AmuletCsvFile {
  static String _generateTimeString() {
    DateTime t = DateTime.now();
    return "${t.year.toString().padLeft(2, '0')}"
        "-${t.month.toString().padLeft(2, '0')}"
        "-${t.day.toString().padLeft(2, '0')}"
        "_${t.hour.toString().padLeft(2, '0')}"
        "-${t.minute.toString().padLeft(2, '0')}"
        "-${t.second.toString().padLeft(2, '0')}"
        "_${t.millisecond.toString().padLeft(3, '0')}"
        "${t.microsecond.toString().padLeft(3, '0')}";
  }

  final Lock _lock = Lock();
  final SimpleCsvFile _file;
  final AppLocalizations appLocalizations;

  AmuletCsvFile({
    required String folderPath,
    required this.appLocalizations,
  }) : _file = SimpleCsvFile(
    path: "$folderPath/Amulet_${_generateTimeString()}.csv",
  );

  Future<bool> clearThenGenerateHeader() {
    return _lock.synchronized(() async {
      try {
        await _file.clear(bom: true);
        await _file.writeAsString(
          data: [
            appLocalizations.id,
            appLocalizations.deviceId,
            appLocalizations.time,
            appLocalizations.accX,
            appLocalizations.accY,
            appLocalizations.accZ,
            appLocalizations.accTotal,
            appLocalizations.magX,
            appLocalizations.magY,
            appLocalizations.magZ,
            appLocalizations.magTotal,
            appLocalizations.pitch,
            appLocalizations.roll,
            appLocalizations.yaw,
            appLocalizations.pressure,
            appLocalizations.temperature,
            appLocalizations.posture,
            appLocalizations.beaconRssi,
            appLocalizations.adc,
            appLocalizations.battery,
            appLocalizations.area,
            appLocalizations.step,
            appLocalizations.direction,
            appLocalizations.point,
          ],
        );
        return true;
      } catch(e) {
        return false;
      }
    });
  }

  Future<bool> writeEntities({
    required Iterable<AmuletEntity> entities,
  }) {
    return _lock.synchronized(() async {
      for (var entity in entities) {
        try {
          await _file.writeAsString(
            data: [
              entity.id.toString(),
              entity.deviceId,
              entity.time.toIso8601String(),
              entity.accX.toString(),
              entity.accY.toString(),
              entity.accZ.toString(),
              entity.accTotal.toString(),
              // entity.gyroX.toString(),
              // entity.gyroY.toString(),
              // entity.gyroZ.toString(),
              // entity.gyroTotal.toString(),
              entity.magX.toString(),
              entity.magY.toString(),
              entity.magZ.toString(),
              entity.magTotal.toString(),
              entity.pitch.toString(),
              entity.roll.toString(),
              entity.yaw.toString(),
              // entity.gValue.toString(),
              entity.pressure.toString(),
              entity.temperature.toString(),
              entity.posture.name,
              entity.beaconRssi.toString(),
              entity.adc.toString(),
              entity.battery.toString(),
              entity.area.toString(),
              entity.step.toString(),
              entity.direction.toString(),
              entity.point.toString(),
            ],
          );
        } catch(e) {
          return false;
        }
      }
      return true;
    });
  }
}

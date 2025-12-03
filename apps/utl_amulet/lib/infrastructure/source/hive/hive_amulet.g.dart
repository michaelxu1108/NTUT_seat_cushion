// ============================================================================
// 自動生成的程式碼 - 請勿手動修改！
// GENERATED CODE - DO NOT MODIFY BY HAND
// ============================================================================
//
// 這個檔案是由 build_runner 根據 hive_amulet.dart 自動生成的
//
// 檔案用途：
// - 提供 Hive 資料庫的序列化/反序列化功能（TypeAdapter）
// - 將 Dart 物件轉換為二進位資料儲存到資料庫
// - 將二進位資料還原為 Dart 物件
//
// 如何重新生成此檔案？
// 1. 修改 hive_amulet.dart
// 2. 執行指令：flutter packages pub run build_runner build
// 3. 或手動依照 hive_amulet.dart 的結構更新此檔案
//
// 警告：
// - ⚠️ 手動修改此檔案會在下次執行 build_runner 時被覆蓋
// - ⚠️ 如果要修改資料結構，請修改 hive_amulet.dart，而非此檔案
//
// ============================================================================

part of 'hive_amulet.dart';

// **************************************************************************
// TypeAdapterGenerator - Hive 類型適配器生成器
// **************************************************************************

/// HiveAmuletPostureType 的類型適配器
///
/// 什麼是 TypeAdapter？
/// - 就像「翻譯器」，負責在 Dart 物件和二進位資料之間轉換
/// - read()：從資料庫讀取二進位資料，轉換成 Dart 枚舉
/// - write()：將 Dart 枚舉轉換成二進位資料，寫入資料庫
///
/// 為什麼需要？
/// - Hive 不知道如何儲存自定義類型（枚舉、類別）
/// - TypeAdapter 教會 Hive 如何處理這些類型
///
/// typeId = 0：
/// - 這個適配器處理的類型 ID 是 0
/// - 對應到 hive_amulet.dart 中的 @HiveType(typeId: 0)
class HiveAmuletPostureTypeAdapter extends TypeAdapter<HiveAmuletPostureType> {
  /// typeId：此適配器負責的類型 ID
  @override
  final int typeId = 0;

  /// read()：反序列化 - 從二進位資料讀取並轉換為 Dart 枚舉
  ///
  /// 參數：
  /// - reader: BinaryReader 用於讀取二進位資料
  ///
  /// 回傳：
  /// - HiveAmuletPostureType 枚舉值
  ///
  /// 運作方式：
  /// 1. 讀取一個 byte（0-11）
  /// 2. 根據數字決定回傳哪個枚舉值
  /// 3. 如果讀到未知數字，回傳 init（預設值）
  ///
  /// 對應表：
  /// - 0 → init
  /// - 1 → seating
  /// - 2 → standing
  /// - ... (共 12 種姿態)
  @override
  HiveAmuletPostureType read(BinaryReader reader) {
    // 讀取一個 byte，根據數值決定姿態類型
    switch (reader.readByte()) {
      case 0:
        return HiveAmuletPostureType.init;
      case 1:
        return HiveAmuletPostureType.seating;
      case 2:
        return HiveAmuletPostureType.standing;
      case 3:
        return HiveAmuletPostureType.supine;
      case 4:
        return HiveAmuletPostureType.rightLateralDecubitus;
      case 5:
        return HiveAmuletPostureType.falling;
      case 6:
        return HiveAmuletPostureType.prone;
      case 7:
        return HiveAmuletPostureType.leftLateralDecubitus;
      case 8:
        return HiveAmuletPostureType.reserved;
      case 9:
        return HiveAmuletPostureType.walking;
      case 10:
        return HiveAmuletPostureType.tempUnstable;
      case 11:
        return HiveAmuletPostureType.upright;
      default:
        // 如果讀到未知數字，回傳預設值 init
        return HiveAmuletPostureType.init;
    }
  }

  @override
  void write(BinaryWriter writer, HiveAmuletPostureType obj) {
    switch (obj) {
      case HiveAmuletPostureType.init:
        writer.writeByte(0);
        break;
      case HiveAmuletPostureType.seating:
        writer.writeByte(1);
        break;
      case HiveAmuletPostureType.standing:
        writer.writeByte(2);
        break;
      case HiveAmuletPostureType.supine:
        writer.writeByte(3);
        break;
      case HiveAmuletPostureType.rightLateralDecubitus:
        writer.writeByte(4);
        break;
      case HiveAmuletPostureType.falling:
        writer.writeByte(5);
        break;
      case HiveAmuletPostureType.prone:
        writer.writeByte(6);
        break;
      case HiveAmuletPostureType.leftLateralDecubitus:
        writer.writeByte(7);
        break;
      case HiveAmuletPostureType.reserved:
        writer.writeByte(8);
        break;
      case HiveAmuletPostureType.walking:
        writer.writeByte(9);
        break;
      case HiveAmuletPostureType.tempUnstable:
        writer.writeByte(10);
        break;
      case HiveAmuletPostureType.upright:
        writer.writeByte(11);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveAmuletPostureTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HiveAmuletEntityAdapter extends TypeAdapter<HiveAmuletEntity> {
  @override
  final int typeId = 1;

  @override
  HiveAmuletEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveAmuletEntity(
      deviceId: fields[0] as String,
      time: fields[1] as DateTime,
      accX: fields[2] as int,
      accY: fields[3] as int,
      accZ: fields[4] as int,
      accTotal: fields[5] as int,
      magX: fields[6] as int,
      magY: fields[7] as int,
      magZ: fields[8] as int,
      magTotal: fields[9] as int,
      pitch: fields[10] as int,
      roll: fields[11] as int,
      yaw: fields[12] as int,
      pressure: fields[13] as double,
      temperature: fields[14] as int,
      posture: fields[15] as HiveAmuletPostureType,
      adc: fields[16] as int,
      battery: fields[17] as int,
      area: fields[18] as int,
      step: fields[19] as int,
      direction: fields[20] as int,
      beaconRssi: fields[21] as int,
      point: fields[22] as int,
    );
  }

  @override
  void write(BinaryWriter writer, HiveAmuletEntity obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.deviceId)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.accX)
      ..writeByte(3)
      ..write(obj.accY)
      ..writeByte(4)
      ..write(obj.accZ)
      ..writeByte(5)
      ..write(obj.accTotal)
      ..writeByte(6)
      ..write(obj.magX)
      ..writeByte(7)
      ..write(obj.magY)
      ..writeByte(8)
      ..write(obj.magZ)
      ..writeByte(9)
      ..write(obj.magTotal)
      ..writeByte(10)
      ..write(obj.pitch)
      ..writeByte(11)
      ..write(obj.roll)
      ..writeByte(12)
      ..write(obj.yaw)
      ..writeByte(13)
      ..write(obj.pressure)
      ..writeByte(14)
      ..write(obj.temperature)
      ..writeByte(15)
      ..write(obj.posture)
      ..writeByte(16)
      ..write(obj.adc)
      ..writeByte(17)
      ..write(obj.battery)
      ..writeByte(18)
      ..write(obj.area)
      ..writeByte(19)
      ..write(obj.step)
      ..writeByte(20)
      ..write(obj.direction)
      ..writeByte(21)
      ..write(obj.beaconRssi)
      ..writeByte(22)
      ..write(obj.point);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveAmuletEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// Domain 層的實體類別：業務邏輯使用的資料結構
import 'package:utl_amulet/domain/entity/amulet_entity.dart';

// Infrastructure 層的 Hive 實體：資料庫儲存使用的資料結構
import 'hive_amulet.dart';

// ============================================================================
// 檔案說明：Hive Mapper - 資料轉換器
// ============================================================================
//
// 這個檔案負責在兩種資料結構之間轉換：
// 1. Domain 層：AmuletEntity（業務邏輯使用）
// 2. Infrastructure 層：HiveAmuletEntity（資料庫儲存使用）
//
// 為什麼需要兩種資料結構？
// - 分層架構原則：Domain 層不應該知道資料庫的存在
// - Domain 層可能有業務邏輯方法，但資料庫不需要儲存這些方法
// - 資料庫結構可以獨立變更，不影響業務邏輯
//
// 比喻：
// - Domain 層的 AmuletEntity 就像「商品」
// - Hive 層的 HiveAmuletEntity 就像「包裹」
// - Mapper 負責「打包」和「拆包」
//
// 轉換方向：
// - fromAmuletEntity(): AmuletEntity → HiveAmuletEntity（儲存到資料庫前）
// - toAmuletEntity(): HiveAmuletEntity → AmuletEntity（從資料庫讀取後）
//
// ============================================================================

/// Hive Amulet 資料轉換器
///
/// 提供靜態方法在 Domain 層和 Infrastructure 層之間轉換資料
///
/// 設計模式：
/// - 使用「私有建構子」防止實例化（HiveAmuletMapper._()）
/// - 所有方法都是 static（靜態方法），直接用類別名稱呼叫
/// - 這是「工具類」（Utility Class）的常見寫法
///
/// 使用範例：
/// ```dart
/// // 儲存前：Domain → Hive
/// AmuletEntity domainEntity = ...;
/// HiveAmuletEntity hiveEntity = HiveAmuletMapper.fromAmuletEntity(
///   entity: domainEntity
/// );
///
/// // 讀取後：Hive → Domain
/// HiveAmuletEntity hiveEntity = ...;
/// AmuletEntity domainEntity = HiveAmuletMapper.toAmuletEntity(
///   id: 123,
///   entity: hiveEntity
/// );
/// ```
class HiveAmuletMapper {
  /// 私有建構子：防止外部建立 HiveAmuletMapper 實例
  ///
  /// 為什麼要這樣做？
  /// - HiveAmuletMapper 只提供靜態方法，不需要建立實例
  /// - 私有建構子確保使用者不會錯誤地寫 `new HiveAmuletMapper()`
  /// - 這是「工具類」的標準寫法
  HiveAmuletMapper._();

  /// 從 Domain Entity 轉換為 Hive Entity
  ///
  /// 使用時機：
  /// - 當要將資料儲存到 Hive 資料庫時
  /// - 藍牙接收到新資料 → Domain Entity → Hive Entity → 儲存
  ///
  /// 參數：
  /// - entity: Domain 層的 AmuletEntity 物件
  ///
  /// 回傳：
  /// - HiveAmuletEntity: 可以儲存到 Hive 的物件
  ///
  /// 轉換細節：
  /// - 大部分欄位直接複製（accX, accY, deviceId 等）
  /// - 姿態枚舉需要轉換：AmuletPostureType → HiveAmuletPostureType
  /// - 使用 `.index` 取得枚舉的順序編號，然後用 `.values[index]` 轉換
  ///
  /// 範例：
  /// ```dart
  /// AmuletEntity domain = AmuletEntity(
  ///   id: 123,
  ///   posture: AmuletPostureType.sit,  // Domain 層枚舉
  ///   // ...
  /// );
  ///
  /// HiveAmuletEntity hive = HiveAmuletMapper.fromAmuletEntity(
  ///   entity: domain
  /// );
  /// // hive.posture == HiveAmuletPostureType.seating （Hive 層枚舉）
  /// ```
  static HiveAmuletEntity fromAmuletEntity({
    required AmuletEntity entity,
  }) {
    // 建立新的 HiveAmuletEntity 物件
    return HiveAmuletEntity(
      // 基本資訊：直接複製
      deviceId: entity.deviceId,
      time: entity.time,

      // 加速度資料：直接複製
      accX: entity.accX,
      accY: entity.accY,
      accZ: entity.accZ,
      accTotal: entity.accTotal,

      // 磁力計資料：直接複製
      magX: entity.magX,
      magY: entity.magY,
      magZ: entity.magZ,
      magTotal: entity.magTotal,

      // 姿態角度：直接複製
      pitch: entity.pitch,
      roll: entity.roll,
      yaw: entity.yaw,

      // 環境資料：直接複製
      pressure: entity.pressure,
      temperature: entity.temperature,

      // ⭐ 姿態類型：需要轉換枚舉
      // entity.posture.index 取得 AmuletPostureType 的順序編號
      // HiveAmuletPostureType.values[index] 轉換為對應的 HiveAmuletPostureType
      // 例如：AmuletPostureType.sit (index=1) → HiveAmuletPostureType.seating (index=1)
      posture: HiveAmuletPostureType.values[entity.posture.index],

      // 其他感測器資料：直接複製
      adc: entity.adc,
      battery: entity.battery,
      area: entity.area,
      step: entity.step,
      direction: entity.direction,

      // 協議 v2.0 新增欄位：直接複製
      beaconRssi: entity.beaconRssi,
      point: entity.point,
    );
  }

  /// 從 Hive Entity 轉換為 Domain Entity
  ///
  /// 使用時機：
  /// - 當從 Hive 資料庫讀取資料時
  /// - 資料庫讀取 → Hive Entity → Domain Entity → 業務邏輯/UI
  ///
  /// 參數：
  /// - id: 資料庫中的 ID（Domain 層需要，但 Hive 層不儲存）
  /// - entity: Hive 層的 HiveAmuletEntity 物件
  ///
  /// 回傳：
  /// - AmuletEntity: Domain 層可使用的物件
  ///
  /// 為什麼需要 id 參數？
  /// - HiveAmuletEntity 不包含 id 欄位（繼承自 HiveObject，id 由 Hive 管理）
  /// - AmuletEntity 需要 id 欄位（用於業務邏輯識別）
  /// - 所以轉換時要額外傳入 id
  ///
  /// 轉換細節：
  /// - 大部分欄位直接複製
  /// - 姿態枚舉需要轉換：HiveAmuletPostureType → AmuletPostureType
  /// - 加入 id 欄位
  ///
  /// 範例：
  /// ```dart
  /// HiveAmuletEntity hive = box.get(123);  // 從資料庫讀取
  ///
  /// AmuletEntity domain = HiveAmuletMapper.toAmuletEntity(
  ///   id: 123,  // 資料庫的 key 就是 id
  ///   entity: hive
  /// );
  /// // domain.posture == AmuletPostureType.sit （Domain 層枚舉）
  /// ```
  static AmuletEntity toAmuletEntity({
    required int id,
    required HiveAmuletEntity entity,
  }) {
    // 建立新的 AmuletEntity 物件
    return AmuletEntity(
      // ⭐ ID：從參數傳入（Hive 的 key）
      id: id,

      // 基本資訊：直接複製
      deviceId: entity.deviceId,
      time: entity.time,

      // 加速度資料：直接複製
      accX: entity.accX,
      accY: entity.accY,
      accZ: entity.accZ,
      accTotal: entity.accTotal,

      // 磁力計資料：直接複製
      magX: entity.magX,
      magY: entity.magY,
      magZ: entity.magZ,
      magTotal: entity.magTotal,

      // 姿態角度：直接複製
      pitch: entity.pitch,
      roll: entity.roll,
      yaw: entity.yaw,

      // 環境資料：直接複製
      pressure: entity.pressure,
      temperature: entity.temperature,

      // ⭐ 姿態類型：需要轉換枚舉
      // entity.posture.index 取得 HiveAmuletPostureType 的順序編號
      // AmuletPostureType.values[index] 轉換為對應的 AmuletPostureType
      // 例如：HiveAmuletPostureType.seating (index=1) → AmuletPostureType.sit (index=1)
      posture: AmuletPostureType.values[entity.posture.index],

      // 其他感測器資料：直接複製
      adc: entity.adc,
      battery: entity.battery,
      area: entity.area,
      step: entity.step,
      direction: entity.direction,

      // 協議 v2.0 新增欄位：直接複製
      beaconRssi: entity.beaconRssi,
      point: entity.point,
    );
  }
}

// ============================================================================
// 檔案結束
// ============================================================================
//
// 資料流向總結：
//
// 儲存資料：
// 藍牙封包 → AmuletSensorData → AmuletEntity
//     ↓ HiveAmuletMapper.fromAmuletEntity()
// HiveAmuletEntity → Hive 資料庫
//
// 讀取資料：
// Hive 資料庫 → HiveAmuletEntity
//     ↓ HiveAmuletMapper.toAmuletEntity()
// AmuletEntity → UI/業務邏輯
//
// ============================================================================

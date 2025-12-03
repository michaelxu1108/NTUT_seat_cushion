// Hive 資料庫套件：用於本地 NoSQL 資料儲存
import 'package:hive/hive.dart';

// part 指令：告訴 Dart 這個檔案有對應的生成檔案
// hive_amulet.g.dart 是由 build_runner 自動生成的 TypeAdapter
part 'hive_amulet.g.dart';

// ============================================================================
// 檔案說明：Hive 資料庫 Schema 定義
// ============================================================================
//
// 這個檔案定義了 Hive 資料庫的「資料結構」（Schema），包括：
// 1. HiveAmuletPostureType：姿態類型的枚舉
// 2. HiveAmuletEntity：感測器資料的實體類別
//
// 為什麼需要這個檔案？
// - Hive 是 NoSQL 資料庫，需要明確告訴它「如何序列化/反序列化物件」
// - 使用 @HiveType 和 @HiveField 註解，Hive 會自動生成對應的 Adapter
//
// 重要概念：
// - typeId：每個類型的唯一識別碼（0, 1, 2...）
// - @HiveField：欄位編號，用於序列化時識別欄位（0, 1, 2...）
//
// 注意事項：
// - ⚠️ typeId 和 HiveField 編號一旦使用，永遠不要改變！
// - ⚠️ 新增欄位只能加在最後，不能插入中間！
// - ⚠️ 刪除欄位不要移除 @HiveField 註解，改為標記「已廢棄」
//
// ============================================================================

/// 姿態類型枚舉（Hive 版本）
///
/// 這是 Domain 層 AmuletPostureType 的 Hive 對應版本
///
/// 為什麼要有兩個版本？
/// - Domain 層：業務邏輯使用（sit, stand, lieDown...）
/// - Hive 層：資料庫儲存使用（seating, standing, supine...）
/// - 兩者透過 Mapper 轉換，讓資料庫可以獨立變更而不影響業務邏輯
///
/// @HiveType(typeId: 0)：
/// - typeId: 0 表示這是 Hive 註冊的第一個自定義類型
/// - 每個 HiveType 必須有唯一的 typeId
///
/// 姿態對應表（藍牙封包 byte[26] → 枚舉值）：
/// - 0: init（初始化）
/// - 1: seating（坐姿）
/// - 2: standing（站立）
/// - 3: supine（仰躺）
/// - 4: rightLateralDecubitus（右側躺）
/// - 5: falling（跌倒）★ 協議更新：原本是 7
/// - 6: prone（趴下）
/// - 7: leftLateralDecubitus（左側躺）★ 協議更新：原本是 5
/// - 8: reserved（保留欄位）
/// - 9: walking（行走）★ 協議更新：原本是 8
/// - 10: tempUnstable（暫時不穩定）★ 新增
/// - 11: upright（直立）★ 新增
@HiveType(typeId: 0)
enum HiveAmuletPostureType {
  /// 初始化狀態（@HiveField(0) 表示序列化為數字 0）
  @HiveField(0)
  init,

  /// 坐姿（@HiveField(1) 表示序列化為數字 1）
  @HiveField(1)
  seating,

  /// 站立（@HiveField(2) 表示序列化為數字 2）
  @HiveField(2)
  standing,

  /// 仰躺（@HiveField(3) 表示序列化為數字 3）
  @HiveField(3)
  supine,

  /// 右側躺（@HiveField(4) 表示序列化為數字 4）
  @HiveField(4)
  rightLateralDecubitus,

  /// 跌倒（@HiveField(5) 表示序列化為數字 5）
  /// ★ 協議 v2.0 變更：原本是 7，現在改為 5
  @HiveField(5)
  falling,

  /// 趴下（@HiveField(6) 表示序列化為數字 6）
  @HiveField(6)
  prone,

  /// 左側躺（@HiveField(7) 表示序列化為數字 7）
  /// ★ 協議 v2.0 變更：原本是 5，現在改為 7
  @HiveField(7)
  leftLateralDecubitus,

  /// 保留欄位（@HiveField(8) 表示序列化為數字 8）
  /// ★ 協議 v2.0 新增
  @HiveField(8)
  reserved,

  /// 行走（@HiveField(9) 表示序列化為數字 9）
  /// ★ 協議 v2.0 變更：原本是 8，現在改為 9
  @HiveField(9)
  walking,

  /// 暫時不穩定（@HiveField(10) 表示序列化為數字 10）
  /// ★ 協議 v2.0 新增：姿態轉換過程中的暫時狀態
  @HiveField(10)
  tempUnstable,

  /// 直立（@HiveField(11) 表示序列化為數字 11）
  /// ★ 協議 v2.0 新增：筆直站立的狀態
  @HiveField(11)
  upright,
}

/// Amulet 感測器資料實體（Hive 版本）
///
/// 這是 Domain 層 AmuletEntity 的 Hive 對應版本
///
/// 繼承關係：
/// - extends HiveObject：繼承 Hive 的基礎物件類別
/// - 這讓 Hive 能夠追蹤物件的變更
///
/// @HiveType(typeId: 1)：
/// - typeId: 1 表示這是 Hive 註冊的第二個自定義類型（第一個是 HiveAmuletPostureType）
///
/// 欄位編號規則（⚠️ 非常重要）：
/// - @HiveField(N) 的 N 必須從 0 開始遞增
/// - 一旦分配，永遠不能改變！
/// - 新增欄位只能用新的編號（加在最後）
/// - 刪除欄位也不能刪除編號（跳過即可）
///
/// 為什麼要這樣設計？
/// - Hive 用編號而非欄位名稱來識別資料
/// - 這樣改變欄位名稱不會影響舊資料
/// - 也能節省儲存空間（數字比字串小）
///
/// 共 23 個欄位（@HiveField 0-22）
@HiveType(typeId: 1)
class HiveAmuletEntity extends HiveObject {
  // ========== 基本資訊 ==========

  /// 設備 ID（@HiveField(0)）
  /// 用於識別是哪個 Amulet 設備發送的資料
  /// 例如："AMULET_001"
  @HiveField(0)
  final String deviceId;

  /// 時間戳（@HiveField(1)）
  /// 記錄資料產生的時間
  /// 使用 DateTime 類型，Hive 會自動處理序列化
  @HiveField(1)
  final DateTime time;

  // ========== 加速度資料（Accelerometer）==========

  /// 加速度 X 軸（@HiveField(2)）
  /// 單位：通常是 mg（毫重力）
  /// 範圍：-32768 ~ 32767（int16）
  @HiveField(2)
  final int accX;

  /// 加速度 Y 軸（@HiveField(3)）
  @HiveField(3)
  final int accY;

  /// 加速度 Z 軸（@HiveField(4)）
  @HiveField(4)
  final int accZ;

  /// 加速度總量（@HiveField(5)）
  /// 計算方式：sqrt(accX² + accY² + accZ²)
  @HiveField(5)
  final int accTotal;

  // ========== 磁力計資料（Magnetometer）==========

  /// 磁力計 X 軸（@HiveField(6)）
  /// 用於偵測地磁方向
  @HiveField(6)
  final int magX;

  /// 磁力計 Y 軸（@HiveField(7)）
  @HiveField(7)
  final int magY;

  /// 磁力計 Z 軸（@HiveField(8)）
  @HiveField(8)
  final int magZ;

  /// 磁力計總量（@HiveField(9)）
  @HiveField(9)
  final int magTotal;

  // ========== 姿態角度（Orientation）==========

  /// 俯仰角 Pitch（@HiveField(10)）
  /// 範圍：-180° ~ 180°
  /// 前後傾斜的角度
  @HiveField(10)
  final int pitch;

  /// 滾轉角 Roll（@HiveField(11)）
  /// 範圍：-180° ~ 180°
  /// 左右傾斜的角度
  @HiveField(11)
  final int roll;

  /// 偏航角 Yaw（@HiveField(12)）
  /// 範圍：0° ~ 360°
  /// 旋轉方向（指南針方向）
  @HiveField(12)
  final int yaw;

  // ========== 環境資料 ==========

  /// 氣壓（@HiveField(13)）
  /// 單位：hPa（百帕）或 Pa（帕斯卡）
  /// 可用於計算高度（UI 顯示為「高度」）
  /// 使用 double 類型以保留小數精度
  @HiveField(13)
  final double pressure;

  /// 溫度（@HiveField(14)）
  /// 單位：通常是 0.1°C（例如 250 表示 25.0°C）
  @HiveField(14)
  final int temperature;

  // ========== 姿態狀態 ==========

  /// 姿態類型（@HiveField(15)）
  /// 使用 HiveAmuletPostureType 枚舉
  /// 例如：坐、站、躺、跌倒等
  @HiveField(15)
  final HiveAmuletPostureType posture;

  // ========== 其他感測器資料 ==========

  /// ADC 數值（@HiveField(16)）
  /// Analog-to-Digital Converter 類比數位轉換器
  /// 可能用於讀取電池電壓或其他類比訊號
  @HiveField(16)
  final int adc;

  /// 電池電量（@HiveField(17)）
  /// 通常是百分比（0-100）或電壓值
  @HiveField(17)
  final int battery;

  /// 區域編號（@HiveField(18)）
  /// 可能用於室內定位或區域識別
  @HiveField(18)
  final int area;

  /// 步數（@HiveField(19)）
  /// 計步器累計的步數
  @HiveField(19)
  final int step;

  /// 方向（@HiveField(20)）
  /// 可能是 8 方位（0-7）或其他方向編碼
  @HiveField(20)
  final int direction;

  // ========== 協議 v2.0 新增欄位 ==========

  /// Beacon 訊號強度（@HiveField(21)）
  /// ★ 協議 v2.0 新增
  /// 藍牙封包位置：[27][28]
  /// 單位：dBm（分貝毫瓦）
  /// 範圍：通常 -100 ~ 0（越接近 0 訊號越強）
  @HiveField(21)
  final int beaconRssi;

  /// 計分欄位（@HiveField(22)）
  /// ★ 協議 v2.0 新增
  /// 藍牙封包位置：[36]
  /// 用途：可能用於評分或狀態記錄
  @HiveField(22)
  final int point;

  /// 建構子：建立一個新的 HiveAmuletEntity 物件
  ///
  /// 所有欄位都是 required（必填），確保資料完整性
  ///
  /// 使用範例：
  /// ```dart
  /// final entity = HiveAmuletEntity(
  ///   deviceId: 'AMULET_001',
  ///   time: DateTime.now(),
  ///   accX: 100,
  ///   accY: 200,
  ///   accZ: 300,
  ///   // ... 其他欄位
  /// );
  /// ```
  ///
  /// 注意：
  /// - 這個建構子只是建立物件，不會自動儲存到 Hive
  /// - 要儲存需要呼叫 HiveSourceHandler.upsertEntity()
  HiveAmuletEntity({
    required this.deviceId,
    required this.time,
    required this.accX,
    required this.accY,
    required this.accZ,
    required this.accTotal,
    required this.magX,
    required this.magY,
    required this.magZ,
    required this.magTotal,
    required this.pitch,
    required this.roll,
    required this.yaw,
    required this.pressure,
    required this.temperature,
    required this.posture,
    required this.adc,
    required this.battery,
    required this.area,
    required this.step,
    required this.direction,
    required this.beaconRssi,
    required this.point,
  });
}

// ============================================================================
// 檔案結束
// ============================================================================
//
// 重要提醒：
// 1. 修改此檔案後，需要重新生成 hive_amulet.g.dart
// 2. 執行指令：flutter packages pub run build_runner build
// 3. 或手動更新 .g.dart 檔案
//
// ============================================================================

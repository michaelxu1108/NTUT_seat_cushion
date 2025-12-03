// Hive Flutter 套件：提供 Hive 的 Flutter 整合與適配器
import 'package:hive_flutter/adapters.dart';
// Domain 層實體：業務邏輯使用的資料結構
import 'package:utl_amulet/domain/entity/amulet_entity.dart';
// Hive 實體與適配器：資料庫儲存使用的資料結構
import 'package:utl_amulet/infrastructure/source/hive/hive_amulet.dart';
// Hive Mapper：負責資料轉換
import 'package:utl_amulet/infrastructure/source/hive/hive_mapper.dart';
// 同步鎖：防止多執行緒衝突
import 'package:synchronized/synchronized.dart';

// ============================================================================
// 檔案說明：Hive Source Handler - Hive 資料庫操作處理器
// ============================================================================
//
// 這個檔案是直接與 Hive 資料庫互動的「最底層」
//
// 職責：
// 1. 初始化 Hive 資料庫（註冊 Adapter、開啟 Box）
// 2. 提供 CRUD 操作（Create, Read, Update, Delete）
// 3. 提供資料變更監聽（Stream）
// 4. 確保執行緒安全（使用 Lock）
//
// 比喻：
// - HiveSourceHandler 就像「資料庫管理員」
// - 負責直接操作資料庫（Hive Box）
// - 其他程式碼不應該直接操作 Hive，都要透過這個 Handler
//
// 重要概念：
// - Box：Hive 的「資料表」，類似 SQL 的 Table
// - LazyBox：延遲載入的 Box，不會一次載入所有資料到記憶體
// - Adapter：教 Hive 如何序列化/反序列化自定義類型
//
// ============================================================================

/// Hive 資料來源處理器
///
/// 提供完整的 Hive 資料庫操作功能
///
/// 設計模式：
/// - 使用「私有建構子」+ 「工廠方法」進行初始化
/// - 確保 Hive 在使用前已正確初始化
/// - 使用 Lock 確保執行緒安全
///
/// 使用範例：
/// ```dart
/// // 1. 初始化（應用程式啟動時）
/// final handler = await HiveSourceHandler.init(
///   hivePath: '/path/to/hive'
/// );
///
/// // 2. 儲存資料
/// await handler.upsertEntity(entity: myEntity);
///
/// // 3. 讀取資料
/// AmuletEntity? entity = await handler.fetchEntityById(123);
///
/// // 4. 監聽變更
/// handler.entitySyncStream.listen((entity) {
///   print('資料更新：${entity.id}');
/// });
/// ```
class HiveSourceHandler {
  // ==================== 靜態常數 ====================

  /// Box 名稱：Hive 資料表的名稱
  ///
  /// 這是 Hive 用來識別不同資料表的字串
  /// 類似 SQL 的 Table Name
  ///
  /// 為什麼要用 const？
  /// - 確保名稱永不改變
  /// - 編譯時就確定，效能更好
  ///
  /// 為什麼要用 _（底線）開頭？
  /// - 表示這是「私有常數」
  /// - 外部程式碼不應該直接存取
  static const String _entityBoxName = "entityBox";

  // ==================== 初始化方法 ====================

  /// 初始化 Hive 資料庫
  ///
  /// 這是應用程式啟動時必須呼叫的方法
  ///
  /// 參數：
  /// - hivePath: Hive 資料庫檔案的儲存路徑
  ///
  /// 回傳：
  /// - Future\<HiveSourceHandler\>: 初始化完成的 Handler 物件
  ///
  /// 初始化步驟：
  /// 1. 初始化 Hive Flutter（Hive.initFlutter - 包含路徑設定）
  /// 2. 註冊自定義類型適配器（Adapter）
  /// 3. 開啟 LazyBox（延遲載入的資料表）
  /// 4. 建立並回傳 HiveSourceHandler 實例
  ///
  /// 為什麼要註冊 Adapter？
  /// - Hive 只能直接儲存基本類型（int, String, bool 等）
  /// - 自定義類型（HiveAmuletEntity, HiveAmuletPostureType）需要告訴 Hive 如何處理
  /// - Adapter 就是「翻譯器」，教 Hive 如何儲存和讀取
  ///
  /// 什麼是 LazyBox？
  /// - 普通 Box：開啟時會載入所有資料到記憶體（適合小資料）
  /// - LazyBox：只在需要時才載入資料（適合大資料）
  /// - 感測器資料可能有幾萬筆，使用 LazyBox 節省記憶體
  ///
  /// 使用範例：
  /// ```dart
  /// // 在 main() 或應用程式初始化時呼叫
  /// final hivePath = await getApplicationDocumentsDirectory();
  /// final handler = await HiveSourceHandler.init(
  ///   hivePath: '${hivePath.path}/hive'
  /// );
  /// ```
  static Future<HiveSourceHandler> init({
    required String hivePath,
  }) async {
    // 步驟 1: 初始化 Hive Flutter
    // 這會設定 Flutter 相關的路徑和配置
    // initFlutter() 會自動設定路徑，不需要再呼叫 Hive.init()
    await Hive.initFlutter(hivePath);

    // 步驟 2: 註冊自定義類型的 Adapter
    // HiveAmuletEntityAdapter：教 Hive 如何處理 HiveAmuletEntity
    Hive.registerAdapter(HiveAmuletEntityAdapter());
    // HiveAmuletPostureTypeAdapter：教 Hive 如何處理 HiveAmuletPostureType 枚舉
    Hive.registerAdapter(HiveAmuletPostureTypeAdapter());

    // 步驟 3: 開啟 LazyBox（延遲載入的資料表）
    // <HiveAmuletEntity> 表示這個 Box 儲存的是 HiveAmuletEntity 類型
    // _entityBoxName 是 Box 的名稱（"entityBox"）
    var entityBox = await Hive.openLazyBox<HiveAmuletEntity>(_entityBoxName);

    // 步驟 4: 建立 HiveSourceHandler 實例並回傳
    // 使用私有建構子 HiveSourceHandler._() 建立
    return HiveSourceHandler._(entityBox);
  }

  // ==================== 成員變數 ====================

  /// Hive 資料表：實際儲存資料的 Box
  ///
  /// LazyBox\<HiveAmuletEntity\>：
  /// - LazyBox：延遲載入，節省記憶體
  /// - \<HiveAmuletEntity\>：儲存的資料類型
  ///
  /// 為什麼要用 final？
  /// - 一旦初始化就不能改變
  /// - 確保資料表不會被意外替換
  ///
  /// 為什麼要用 _（底線）開頭？
  /// - 這是「私有變數」
  /// - 外部程式碼不應該直接存取 Box
  /// - 所有操作都要透過 HiveSourceHandler 的方法
  final LazyBox<HiveAmuletEntity> _entityBox;

  /// 同步鎖：防止多執行緒同時存取資料庫
  ///
  /// 為什麼需要 Lock？
  /// - 藍牙可能同時接收多筆資料
  /// - 使用者可能同時按「匯出」和「刪除」
  /// - 如果不加鎖，可能造成資料損壞
  ///
  /// 運作方式：
  /// - 當有操作正在執行時，其他操作必須等待
  /// - 類似「廁所門鎖」，一次只能一個人使用
  final Lock _lock = Lock();

  /// 私有建構子：防止外部直接建立實例
  ///
  /// 為什麼要私有？
  /// - 確保只能透過 init() 方法建立
  /// - init() 會確保 Hive 已正確初始化
  /// - 防止使用者忘記初始化就直接使用
  ///
  /// 參數：
  /// - _entityBox: 已開啟的 LazyBox
  ///
  /// 使用 ._ 命名是 Dart 的慣例，表示「私有建構子」
  HiveSourceHandler._(this._entityBox);

  // ==================== CRUD 操作方法 ====================

  /// 根據 ID 查詢單筆資料
  ///
  /// 參數：
  /// - entityId: 要查詢的資料 ID
  ///
  /// 回傳：
  /// - Future\<AmuletEntity?\>:
  ///   - 找到資料：回傳 AmuletEntity 物件
  ///   - 找不到：回傳 null
  ///
  /// 運作流程：
  /// 1. 加鎖確保執行緒安全
  /// 2. 從 Hive Box 讀取 HiveAmuletEntity（await _entityBox.get）
  /// 3. 如果資料不存在，回傳 null
  /// 4. 使用 Mapper 轉換為 Domain 層的 AmuletEntity
  ///
  /// 為什麼需要轉換？
  /// - Hive 儲存的是 HiveAmuletEntity（Infrastructure 層）
  /// - 業務邏輯需要 AmuletEntity（Domain 層）
  /// - Mapper 負責轉換
  ///
  /// 使用範例：
  /// ```dart
  /// AmuletEntity? entity = await handler.fetchEntityById(123);
  /// if (entity != null) {
  ///   print('找到資料：accX=${entity.accX}');
  /// } else {
  ///   print('資料不存在');
  /// }
  /// ```
  Future<AmuletEntity?> fetchEntityById(int entityId) async {
    // 加鎖：確保同一時間只有一個讀取操作
    return _lock.synchronized(() async {
      // 從 Hive Box 讀取資料（LazyBox 會在這時才載入）
      var entity = await _entityBox.get(entityId);
      // 如果資料不存在，回傳 null
      if (entity == null) return null;
      // 使用 Mapper 轉換為 Domain Entity
      return HiveAmuletMapper.toAmuletEntity(id: entityId, entity: entity);
    });
  }

  /// 計算資料總數
  ///
  /// 回傳：
  /// - int: 資料庫中的資料筆數
  ///
  /// 運作方式：
  /// - 直接讀取 Box 的 length 屬性
  /// - 不需要加鎖（讀取 length 是原子操作）
  /// - 非常快速（O(1)）
  ///
  /// 使用範例：
  /// ```dart
  /// int count = handler.countEntities();
  /// print('資料庫共有 $count 筆資料');
  /// ```
  int countEntities() {
    return _entityBox.length;
  }

  /// 取得所有資料的 ID 列表
  ///
  /// 回傳：
  /// - Iterable\<int\>: ID 的可迭代集合
  ///
  /// 為什麼回傳 Iterable 而不是 List？
  /// - Iterable 是「延遲計算」的，不會立即建立完整列表
  /// - 節省記憶體，特別是資料量大時
  /// - 如果需要 List，可以用 .toList() 轉換
  ///
  /// 運作方式：
  /// - _entityBox.keys 取得所有 key（ID）
  /// - .cast\<int\>() 將類型轉換為 int
  /// - 不需要加鎖（keys 是唯讀屬性）
  ///
  /// 使用範例：
  /// ```dart
  /// // 方法 1: 迭代所有 ID
  /// for (int id in handler.fetchEntityIds()) {
  ///   print('ID: $id');
  /// }
  ///
  /// // 方法 2: 轉換為 List
  /// List<int> idList = handler.fetchEntityIds().toList();
  /// print('ID 列表：$idList');
  /// ```
  Iterable<int> fetchEntityIds() {
    return _entityBox.keys.cast<int>();
  }

  // ==================== 資料流（Stream）方法 ====================

  /// 資料同步事件流：監聽資料的新增或更新
  ///
  /// 回傳：
  /// - Stream\<AmuletEntity\>: 資料變更的即時事件流
  ///
  /// 運作方式：
  /// 1. _entityBox.watch() 監聽 Box 的所有變更
  /// 2. where() 過濾：只保留「有值」的事件（新增/更新）
  /// 3. asyncMap() 非同步轉換：
  ///    - 加鎖確保執行緒安全
  ///    - 使用 Mapper 轉換為 Domain Entity
  ///
  /// 什麼時候會發出事件？
  /// - 新增資料時（upsertEntity 被呼叫）
  /// - 更新資料時（upsertEntity 被呼叫）
  /// - ❌ 刪除資料時不會發出（看 entityIdRemovedStream）
  ///
  /// 使用場景：
  /// - UI 需要即時更新（藍牙接收資料 → 自動更新圖表）
  /// - 多個畫面需要同步顯示相同資料
  ///
  /// 使用範例：
  /// ```dart
  /// handler.entitySyncStream.listen((entity) {
  ///   print('資料更新：ID=${entity.id}, accX=${entity.accX}');
  ///   // 更新 UI
  ///   updateChart(entity);
  /// });
  /// ```
  ///
  /// 技術細節：
  /// - 這是「響應式程式設計」（Reactive Programming）
  /// - Stream 是「推送」模式，不是「拉取」模式
  /// - 資料變更會自動通知所有監聽者
  Stream<AmuletEntity> get entitySyncStream {
    // 監聽 Box 的所有變更事件
    return _entityBox.watch()
      // 過濾：只保留「有值」的事件（新增/更新）
      .where((event) => event.value is HiveAmuletEntity)
      // 非同步轉換：Hive Entity → Domain Entity
      .asyncMap((event) async {
        // 加鎖確保執行緒安全
        return _lock.synchronized(() async {
          // 使用 Mapper 轉換
          return HiveAmuletMapper.toAmuletEntity(id: event.key, entity: event.value);
        });
      });
  }

  /// 資料刪除事件流：監聽資料的刪除
  ///
  /// 回傳：
  /// - Stream\<int\>: 被刪除資料的 ID 事件流
  ///
  /// 運作方式：
  /// 1. _entityBox.watch() 監聽 Box 的所有變更
  /// 2. where() 過濾：只保留「值為 null」的事件（刪除）
  /// 3. asyncMap() 非同步轉換：
  ///    - 加鎖確保執行緒安全
  ///    - 回傳被刪除的資料 ID
  ///
  /// 什麼時候會發出事件？
  /// - 刪除資料時（deleteEntity 被呼叫）
  /// - 清空資料庫時（clear 被呼叫）會發出多個事件
  ///
  /// 使用場景：
  /// - UI 需要即時移除顯示的資料
  /// - 圖表需要移除對應的資料點
  ///
  /// 使用範例：
  /// ```dart
  /// handler.entityIdRemovedStream.listen((deletedId) {
  ///   print('資料被刪除：ID=$deletedId');
  ///   // 從 UI 移除
  ///   removeFromChart(deletedId);
  /// });
  /// ```
  Stream<int> get entityIdRemovedStream {
    // 監聽 Box 的所有變更事件
    return _entityBox.watch()
      // 過濾：只保留「值為 null」的事件（刪除）
      .where((event) => event.value == null)
      // 非同步轉換：提取被刪除的 ID
      .asyncMap((event) async {
        // 加鎖確保執行緒安全
        return _lock.synchronized(() async {
          // 回傳 key（就是 ID）
          return event.key;
        });
      });
  }

  // ==================== 工具方法 ====================

  /// 產生新的 ID：為新資料分配唯一識別碼
  ///
  /// 回傳：
  /// - Future\<int\>: 新產生的 ID（永不重複）
  ///
  /// ID 生成規則：
  /// - 取得目前最大的 ID（_entityBox.keys.lastOrNull）
  /// - 如果沒有資料，使用 0
  /// - 加 1 得到新 ID
  ///
  /// 範例：
  /// - 資料庫是空的 → 新 ID = 1
  /// - 最大 ID 是 100 → 新 ID = 101
  /// - 即使刪除 ID 99，新 ID 仍然是 101（不會重複使用）
  ///
  /// 為什麼不用 UUID？
  /// - int 比 String 節省空間
  /// - int 可以排序（方便查詢最新資料）
  /// - 單一設備使用，不需要全球唯一性
  ///
  /// 使用範例：
  /// ```dart
  /// int newId = await handler.createId();
  /// AmuletEntity entity = AmuletEntity(
  ///   id: newId,
  ///   deviceId: 'AMULET_001',
  ///   // ...
  /// );
  /// await handler.upsertEntity(entity: entity);
  /// ```
  Future<int> createId() async {
    // 取得最後一個 key（最大的 ID），如果沒有就用 0，然後加 1
    return (_entityBox.keys.lastOrNull ?? 0) + 1;
  }

  /// Upsert：新增或更新資料
  ///
  /// 參數：
  /// - entity: 要儲存的 Domain Entity
  ///
  /// 回傳：
  /// - Future\<void\>: 操作完成的 Future
  ///
  /// 什麼是 Upsert？
  /// - Update（更新）+ Insert（新增）的合體
  /// - 如果 ID 已存在 → 更新
  /// - 如果 ID 不存在 → 新增
  ///
  /// 運作流程：
  /// 1. 加鎖確保執行緒安全
  /// 2. 使用 Mapper 將 Domain Entity 轉換為 Hive Entity
  /// 3. 呼叫 _entityBox.put() 儲存
  /// 4. Hive 會觸發 watch() 事件，通知 entitySyncStream 的監聽者
  ///
  /// 為什麼不分成 insert 和 update？
  /// - Upsert 更簡單，呼叫者不用判斷資料是否存在
  /// - Hive 的 put() 本身就是 upsert 語意
  /// - 減少程式碼複雜度
  ///
  /// 使用範例：
  /// ```dart
  /// // 新增資料
  /// AmuletEntity newEntity = AmuletEntity(id: 1, ...);
  /// await handler.upsertEntity(entity: newEntity);
  ///
  /// // 更新資料（相同 ID）
  /// AmuletEntity updatedEntity = AmuletEntity(id: 1, accX: 999, ...);
  /// await handler.upsertEntity(entity: updatedEntity);  // 會覆蓋舊資料
  /// ```
  Future<void> upsertEntity({
    required AmuletEntity entity,
  }) async {
    // 加鎖：確保同一時間只有一個寫入操作
    return _lock.synchronized(() {
      // 使用 Mapper 轉換為 Hive Entity，然後儲存
      // entity.id 作為 key，HiveAmuletEntity 作為 value
      return _entityBox.put(entity.id, HiveAmuletMapper.fromAmuletEntity(entity: entity));
    });
  }

  /// 刪除資料：根據 ID 刪除一筆資料
  ///
  /// 參數：
  /// - entityId: 要刪除的資料 ID
  ///
  /// 回傳：
  /// - Future\<void\>: 操作完成的 Future
  ///
  /// 運作流程：
  /// 1. 加鎖確保執行緒安全
  /// 2. 呼叫 _entityBox.delete() 刪除
  /// 3. Hive 會觸發 watch() 事件，通知 entityIdRemovedStream 的監聽者
  ///
  /// 如果 ID 不存在會怎樣？
  /// - 不會報錯，靜默忽略
  /// - 這是 Hive 的預設行為
  ///
  /// 使用範例：
  /// ```dart
  /// await handler.deleteEntity(entityId: 123);
  /// print('資料已刪除');
  /// ```
  Future<void> deleteEntity({
    required int entityId,
  }) async {
    // 加鎖：確保同一時間只有一個刪除操作
    return _lock.synchronized(() {
      // 從 Box 中刪除指定 key 的資料
      return _entityBox.delete(entityId);
    });
  }

  /// 清空所有資料：刪除資料庫中的所有資料
  ///
  /// 回傳：
  /// - Future\<int\>: 被刪除的資料筆數
  ///
  /// 運作流程：
  /// 1. 加鎖確保執行緒安全
  /// 2. 呼叫 _entityBox.clear() 清空
  /// 3. Hive 會為每筆資料觸發 watch() 事件
  /// 4. entityIdRemovedStream 會收到多個刪除事件
  ///
  /// ⚠️ 警告：
  /// - 這個操作無法復原！
  /// - 所有歷史資料都會永久刪除
  /// - 建議在呼叫前先確認使用者意圖
  ///
  /// 使用範例：
  /// ```dart
  /// int deletedCount = await handler.clear();
  /// print('已刪除 $deletedCount 筆資料');
  /// ```
  Future<int> clear() async {
    // 加鎖：確保同一時間只有一個清空操作
    return _lock.synchronized(() {
      // 清空 Box，回傳被刪除的筆數
      return _entityBox.clear();
    });
  }

  // ==================== 生命週期方法 ====================

  /// 釋放資源：關閉 Hive Box
  ///
  /// 使用時機：
  /// - 應用程式關閉時
  /// - 不再需要使用這個 Handler 時
  ///
  /// 運作方式：
  /// - 關閉 _entityBox（釋放檔案鎖定）
  /// - 清理記憶體
  ///
  /// 注意：
  /// - dispose() 後不能再使用這個 Handler
  /// - 需要重新呼叫 init() 建立新的 Handler
  ///
  /// 使用範例：
  /// ```dart
  /// // 應用程式關閉時
  /// @override
  /// void dispose() {
  ///   hiveSourceHandler.dispose();
  ///   super.dispose();
  /// }
  /// ```
  void dispose() {
    // 關閉 Box，釋放資源
    _entityBox.close();
  }
}

// ============================================================================
// 檔案結束
// ============================================================================
//
// 完整資料流向：
//
// 【儲存資料】
// 1. 藍牙封包 → AmuletSensorData
// 2. AmuletSensorData → AmuletEntity (Domain)
// 3. createId() 產生新 ID
// 4. HiveAmuletMapper.fromAmuletEntity() 轉換
// 5. upsertEntity() 儲存到 Hive
// 6. entitySyncStream 發出事件
// 7. UI 自動更新
//
// 【讀取資料】
// 1. fetchEntityById() 或 fetchEntityIds()
// 2. Hive Box 讀取 HiveAmuletEntity
// 3. HiveAmuletMapper.toAmuletEntity() 轉換
// 4. 回傳 AmuletEntity (Domain)
// 5. UI 顯示資料
//
// 【刪除資料】
// 1. deleteEntity() 刪除資料
// 2. entityIdRemovedStream 發出事件
// 3. UI 移除對應顯示
//
// ============================================================================

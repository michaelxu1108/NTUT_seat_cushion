// 同步鎖套件：用於防止多個執行緒同時存取資料庫造成衝突
import 'package:synchronized/synchronized.dart';
// Domain 層的實體類別：定義資料結構
import 'package:utl_amulet/domain/entity/amulet_entity.dart';
// Domain 層的 Repository 介面：定義資料存取規範
import 'package:utl_amulet/domain/repository/amulet_repository.dart';
// Infrastructure 層的 Hive 處理器：實際操作 Hive 資料庫
import 'package:utl_amulet/infrastructure/source/hive/hive_source_handler.dart';

/// Amulet Repository 的具體實作類別
///
/// 這個類別是「資料存取層」的核心，負責：
/// 1. 將 Domain 層的需求（介面）轉換為實際的資料庫操作
/// 2. 使用 Hive 資料庫儲存和讀取感測器資料
/// 3. 提供執行緒安全的資料存取（防止多執行緒衝突）
/// 4. 統一錯誤處理和回傳格式
///
/// 比喻：就像「倉庫管理員」，負責管理資料的存取，確保不會亂掉
class AmuletRepositoryImpl implements AmuletRepository {

  // ==================== 成員變數 ====================

  /// 同步鎖：防止多個操作同時存取資料庫
  ///
  /// 為什麼需要？
  /// - 藍牙可能同時接收多筆資料
  /// - 使用者可能同時按「匯出」按鈕
  /// - 如果不加鎖，可能造成資料損壞或應用程式崩潰
  ///
  /// 運作方式：
  /// - 當有操作正在執行時，其他操作必須等待
  /// - 確保一次只有一個操作在存取資料庫
  final Lock _lock = Lock();

  /// Hive 資料庫處理器：實際執行 CRUD 操作的工具
  ///
  /// 這是真正與 Hive 資料庫溝通的物件
  /// Repository 負責「管理」，HiveSourceHandler 負責「執行」
  final HiveSourceHandler hiveSourceHandler;

  /// 建構子：初始化 Repository
  ///
  /// 參數：
  /// - hiveSourceHandler: 必須提供 Hive 處理器（依賴注入）
  ///
  /// 為什麼用依賴注入？
  /// - 方便測試（可以注入 Mock 物件）
  /// - 符合 Clean Architecture 原則
  AmuletRepositoryImpl({
    required this.hiveSourceHandler,
  });

  // ==================== CRUD 方法實作 ====================

  /// 刪除資料：根據 ID 刪除一筆感測器資料
  ///
  /// 參數：
  /// - entityId: 要刪除的資料 ID
  ///
  /// 回傳：
  /// - Future\<bool\>: true 表示刪除成功
  ///
  /// 運作流程：
  /// 1. 使用 _lock.synchronized() 確保執行緒安全
  /// 2. 呼叫 hiveSourceHandler 執行實際的刪除動作
  /// 3. 永遠回傳 true（表示操作完成）
  ///
  /// 使用範例：
  /// ```dart
  /// bool success = await repository.delete(entityId: 123);
  /// if (success) print('刪除成功');
  /// ```
  @override
  Future<bool> delete({required int entityId}) {
    // synchronized() 確保同一時間只有一個刪除操作在執行
    return _lock.synchronized(() async {
      // 實際執行刪除動作（交給 Hive 處理器）
      await hiveSourceHandler.deleteEntity(entityId: entityId);
      // 回傳 true 表示操作完成
      return true;
    });
  }

  // ==================== 資料流（Stream）====================

  /// 資料刪除事件流：監聽哪些資料被刪除了
  ///
  /// 這是一個 Stream（資料流），會即時通知：
  /// - 當有資料被刪除時，會發出該資料的 ID
  ///
  /// 使用場景：
  /// - UI 需要即時更新（當資料被刪除，圖表要移除對應的點）
  ///
  /// 使用範例：
  /// ```dart
  /// repository.entityIdRemovedStream.listen((deletedId) {
  ///   print('資料 $deletedId 被刪除了');
  ///   // 更新 UI
  /// });
  /// ```
  ///
  /// 技術細節：
  /// - 這是一個「getter」，直接轉發 hiveSourceHandler 的 Stream
  /// - 不需要加鎖（Stream 本身是單向的）
  @override
  Stream<int> get entityIdRemovedStream => hiveSourceHandler.entityIdRemovedStream;

  /// 資料同步事件流：監聽資料的新增或更新
  ///
  /// 這是一個 Stream（資料流），會即時通知：
  /// - 當有新資料被新增時
  /// - 當有舊資料被更新時
  ///
  /// 使用場景：
  /// - 藍牙接收到新資料 → 自動儲存 → Stream 發出事件 → UI 自動更新圖表
  ///
  /// 使用範例：
  /// ```dart
  /// repository.entitySyncStream.listen((entity) {
  ///   print('收到新資料：accX=${entity.accX}');
  ///   // 更新圖表
  /// });
  /// ```
  ///
  /// 技術細節：
  /// - 這是響應式程式設計（Reactive Programming）的核心
  /// - 資料變更會自動通知所有監聽者
  @override
  Stream<AmuletEntity> get entitySyncStream => hiveSourceHandler.entitySyncStream;

  /// 查詢所有資料：從資料庫讀取所有感測器資料
  ///
  /// 回傳：
  /// - Stream\<AmuletEntity\>: 資料流，逐筆發出資料
  ///
  /// 為什麼用 Stream 而不是 List？
  /// - 資料可能有幾萬筆，一次全部載入會消耗大量記憶體
  /// - Stream 可以「邊讀邊用」，節省記憶體
  /// - 使用者可以提前看到資料（不用等全部載入完）
  ///
  /// 運作流程：
  /// 1. 先取得所有資料的 ID 列表
  /// 2. 逐一根據 ID 查詢完整資料
  /// 3. 過濾掉 null 值（可能資料已被刪除）
  /// 4. 使用 yield 逐筆發出資料
  ///
  /// 使用範例：
  /// ```dart
  /// // 方法 1: 監聽 Stream
  /// repository.fetchEntities().listen((entity) {
  ///   print('讀取到：${entity.deviceId}');
  /// });
  ///
  /// // 方法 2: 轉換為 List（一次取得全部）
  /// List<AmuletEntity> allData = await repository.fetchEntities().toList();
  /// print('共 ${allData.length} 筆資料');
  /// ```
  ///
  /// 技術細節：
  /// - async* 表示這是「非同步生成器函式」
  /// - yield 類似 return，但不會結束函式，而是發出一個值後繼續執行
  /// - 每次查詢都加鎖，確保執行緒安全
  @override
  Stream<AmuletEntity> fetchEntities() async* {
    // 步驟 1: 取得所有資料的 ID 列表（Iterable 轉成 List）
    for(var entityId in hiveSourceHandler.fetchEntityIds().toList()) {
      // 步驟 2: 根據 ID 查詢完整資料（加鎖確保執行緒安全）
      final entity = await _lock.synchronized(() async {
        // 實際從 Hive 讀取資料
        return await hiveSourceHandler.fetchEntityById(entityId);
      });
      // 步驟 3: 過濾 null 值，只發出有效資料
      if(entity != null) yield entity;  // yield 發出這筆資料
    }
    // 迴圈結束，Stream 自動關閉
  }

  // ==================== 工具方法 ====================

  /// 產生新的 ID：為新資料分配唯一識別碼
  ///
  /// 回傳：
  /// - Future\<int\>: 新產生的 ID（永不重複）
  ///
  /// 使用時機：
  /// - 當藍牙接收到新資料，準備儲存前，需要先分配 ID
  ///
  /// 運作原理：
  /// - 使用遞增計數器（1, 2, 3, 4...）
  /// - 永不重複，即使刪除資料也不會重複使用舊 ID
  ///
  /// 使用範例：
  /// ```dart
  /// int newId = await repository.createId();
  /// AmuletEntity entity = AmuletEntity(
  ///   id: newId,  // 使用新產生的 ID
  ///   deviceId: 'ABC123',
  ///   // ... 其他欄位
  /// );
  /// ```
  ///
  /// 技術細節：
  /// - 不需要加鎖（createId 本身已經是原子操作）
  /// - 直接轉發給 hiveSourceHandler 處理
  @override
  Future<int> createId() {
    return hiveSourceHandler.createId();
  }

  /// Upsert：新增或更新資料
  ///
  /// 參數：
  /// - entity: 要儲存的感測器資料
  ///
  /// 回傳：
  /// - Future\<bool\>: true 表示操作成功
  ///
  /// 什麼是 Upsert？
  /// - Update（更新）+ Insert（新增）的合體
  /// - 如果資料已存在（相同 ID）→ 更新
  /// - 如果資料不存在 → 新增
  ///
  /// 使用場景：
  /// - 藍牙接收到新資料 → 呼叫 upsert 儲存
  /// - 不用擔心資料是新的還是舊的，都能正確處理
  ///
  /// 運作流程：
  /// 1. 加鎖確保執行緒安全
  /// 2. 呼叫 hiveSourceHandler 執行實際儲存
  /// 3. Hive 會自動判斷要新增還是更新
  /// 4. 回傳 true 表示操作完成
  ///
  /// 使用範例：
  /// ```dart
  /// AmuletEntity newData = AmuletEntity(
  ///   id: 123,
  ///   deviceId: 'ABC',
  ///   accX: 100,
  ///   // ...
  /// );
  /// bool success = await repository.upsert(entity: newData);
  /// if (success) print('儲存成功');
  /// ```
  @override
  Future<bool> upsert({required AmuletEntity entity}) {
    // 加鎖：確保同一時間只有一個寫入操作
    return _lock.synchronized(() async {
      // 實際執行儲存動作
      await hiveSourceHandler.upsertEntity(entity: entity);
      // 回傳 true 表示操作完成
      return true;
    });
  }

  /// 清空所有資料：刪除資料庫中的所有感測器資料
  ///
  /// 回傳：
  /// - Future\<bool\>: true 表示清空成功
  ///
  /// 使用時機：
  /// - 使用者按下「清除所有資料」按鈕
  /// - 測試時清理資料
  /// - 重置應用程式狀態
  ///
  /// ⚠️ 警告：
  /// - 這個操作無法復原！
  /// - 所有歷史資料都會永久刪除
  /// - 建議在呼叫前先確認使用者意圖
  ///
  /// 運作流程：
  /// 1. 加鎖確保執行緒安全
  /// 2. 呼叫 hiveSourceHandler 清空資料庫
  /// 3. 回傳 true 表示操作完成
  ///
  /// 使用範例：
  /// ```dart
  /// // 先詢問使用者
  /// bool confirm = await showConfirmDialog('確定要刪除所有資料嗎？');
  /// if (confirm) {
  ///   bool success = await repository.clear();
  ///   if (success) print('所有資料已清空');
  /// }
  /// ```
  @override
  Future<bool> clear() {
    // 加鎖：確保同一時間只有一個清空操作
    return _lock.synchronized(() async {
      // 實際執行清空動作
      await hiveSourceHandler.clear();
      // 回傳 true 表示操作完成
      return true;
    });
  }

}
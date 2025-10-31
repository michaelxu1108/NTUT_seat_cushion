# VS Code 設定與問題修正

**日期**: 2025-10-31

## 概述

本次更新主要解決了 VS Code 中 Java/Gradle 擴充套件與 Flutter Monorepo 專案的衝突問題，並完善了專案的開發環境設定。

---

## 問題背景

### 遇到的主要問題

1. **Gradle 衝突錯誤**

   ```
   A project with the name android already exists.
   Duplicate root element android
   ```

2. **Flutter SDK 路徑錯誤**

   ```
   Included build '/Users/xuguanwen/fvm/versions/3.29.0/packages/flutter_tools/gradle' does not exist.
   ```

3. **Dart 程式碼警告**

   - 命名規範錯誤 (`constant_identifier_names`)
   - Library doc comment 問題 (`dangling_library_doc_comments`)
   - 未使用元素警告 (`unused_element`)

### 根本原因

- VS Code 的 **Red Hat Java 擴充套件** 和 **Gradle for Java 擴充套件** 會自動掃描所有 `android/` 資料夾
- 將每個 `apps/*/android/` 都當作獨立的 Gradle 專案導入
- 造成專案名稱衝突和重複元素錯誤

---

## 解決方案

### 1. 修正 Android 專案配置

#### 創建 `local.properties`

為 `apps/ad5940_temp_debugger/android/local.properties` 創建正確的設定：

```properties
sdk.dir=/Users/xuguanwen/Library/Android/sdk
flutter.sdk=/Users/xuguanwen/flutter
```

**重點**：

- `flutter.sdk` 必須指向實際的 Flutter SDK 路徑
- 不是 FVM 的版本路徑，而是全域的 Flutter 安裝路徑
- 可透過 `which flutter` 查詢正確路徑

---

### 2. VS Code 工作區設定

#### `.vscode/settings.json`

完整的設定檔內容：

```json
{
  "cmake.ignoreCMakeListsMissing": true,

  // ========================================
  // 禁用 Java 擴充套件功能（等同於停用）
  // ========================================
  "java.enabled": false,
  "java.jdt.ls.java.home": null,
  "java.import.gradle.enabled": false,
  "java.import.maven.enabled": false,
  "java.autobuild.enabled": false,
  "java.configuration.updateBuildConfiguration": "disabled",
  "java.project.sourcePaths": [],
  "java.project.referencedLibraries": [],
  "java.server.launchMode": "Standard",
  "java.import.exclusions": ["**"],

  // ========================================
  // 禁用 Gradle 擴充套件功能
  // ========================================
  "gradle.nestedProjects": false,
  "gradle.autoDetect": "off",

  // ========================================
  // 排除平台特定資料夾（不監控、不顯示）
  // ========================================
  "files.exclude": {
    "**/android/.gradle": true,
    "**/android/build": true,
    "**/.gradle": true,
    "**/build": true
  },
  "files.watcherExclude": {
    "**/android/**": true,
    "**/ios/**": true,
    "**/macos/**": true,
    "**/linux/**": true,
    "**/windows/**": true,
    "**/web/**": true,
    "**/.gradle/**": true,
    "**/build/**": true
  },
  "search.exclude": {
    "**/android/**": true,
    "**/ios/**": true,
    "**/macos/**": true,
    "**/linux/**": true,
    "**/windows/**": true,
    "**/web/**": true
  }
}
```

**設定說明**：

| 設定項目                         | 用途                               |
| -------------------------------- | ---------------------------------- |
| `java.enabled: false`            | 完全禁用 Java 語言伺服器           |
| `java.import.exclusions: ["**"]` | 排除所有檔案，不導入任何 Java 專案 |
| `gradle.autoDetect: "off"`       | 關閉 Gradle 自動偵測               |
| `files.exclude`                  | 隱藏編譯產生的資料夾               |
| `files.watcherExclude`           | 不監控平台特定資料夾的變更         |
| `search.exclude`                 | 搜尋時排除平台資料夾               |

---

#### `.vscode/extensions.json`

推薦和不推薦的擴充套件清單：

```json
{
  "recommendations": ["dart-code.dart-code", "dart-code.flutter"],
  "unwantedRecommendations": [
    "redhat.java",
    "vscjava.vscode-gradle",
    "vscjava.vscode-java-pack",
    "vscjava.vscode-java-dependency"
  ]
}
```

**效果**：

- ✅ 新成員開啟專案時會收到安裝 Dart/Flutter 擴充套件的建議
- ⚠️ 警告不要在此工作區使用 Java 相關擴充套件

---

### 3. Dart 程式碼修正

#### JSON 序列化設計決策

**檔案**: `domains/seat_cushion/lib/model/seat_cushion.dart`

##### 原本的問題

```dart
class LeftSeatCushion extends SeatCushion {
  @override
  Map<String, dynamic> toJson() => _$SeatCushionToJson(this);  // 呼叫父類的序列化
}
```

會產生警告：

```
The declaration '_$LeftSeatCushionToJson' isn't referenced.
```

##### 設計考量

**選擇 1**：使用子類別專用的序列化函數

```dart
Map<String, dynamic> toJson() => _$LeftSeatCushionToJson(this);
```

- ✅ 消除警告
- ✅ 符合物件導向原則
- ⚠️ 未來如果子類別新增欄位，序列化行為會不同

**選擇 2**：統一使用父類別的序列化函數（最終採用）

```dart
Map<String, dynamic> toJson() => _$SeatCushionToJson(this);
```

- ✅ 統一 JSON 格式（左右座墊結構相同）
- ✅ 只用 `type` 欄位區分左右
- ⚠️ 會有 unused element 警告（可忽略）

##### 最終決定

保持使用 `_$SeatCushionToJson(this)`，因為：

1. `LeftSeatCushion` 和 `RightSeatCushion` 沒有額外欄位
2. 實際儲存結構由 `SeatCushionSet` 控制
3. 統一格式便於反序列化

---

#### 排除自動生成檔案的警告

**檔案**: `domains/seat_cushion/analysis_options.yaml`

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
```

**說明**：

- `.g.dart` 檔案由 `build_runner` 自動生成
- 不應該手動編輯
- 排除分析可避免無意義的警告

---

## 開發工具說明

### `json_serializable` 與 `build_runner`

#### 為什麼需要自動生成？

手動寫 JSON 序列化很繁瑣且容易出錯：

```dart
//  手動寫（繁瑣、易錯）
Map<String, dynamic> toJson() {
  return {
    'forces': forces,
    'time': time.toIso8601String(),
    'type': type.toString().split('.').last,
  };
}
```

```dart
//  使用自動生成（簡潔、可靠）
@JsonSerializable()
class SeatCushion {
  Map<String, dynamic> toJson() => _$SeatCushionToJson(this);
}
```

#### 工作流程

```
1. 寫程式碼加上 @JsonSerializable() 註解
   ↓
2. 執行 dart run build_runner build
   ↓
3. build_runner 掃描程式碼
   ↓
4. json_serializable 生成序列化程式碼
   ↓
5. 產生 .g.dart 檔案
```

#### 常用指令

```bash
# 生成一次（覆蓋舊檔案）
dart run build_runner build --delete-conflicting-outputs

# 監聽模式（自動重新生成）
dart run build_runner watch --delete-conflicting-outputs

# 清除生成的檔案
dart run build_runner clean
```

---

## 團隊協作建議

### 新成員設定步驟

1. **Clone 專案後**

   ```bash
   cd /path/to/project
   flutter pub get
   ```

2. **停用 Java 擴充套件**（如果已安裝）

   - 開啟 VS Code 擴充套件面板 (`Cmd+Shift+X`)
   - 搜尋 `Language Support for Java`
   - 點擊齒輪 → **Disable (Workspace)**
   - 搜尋 `Gradle for Java`
   - 點擊齒輪 → **Disable (Workspace)**

3. **重新載入視窗**

   - `Cmd+Shift+P` → `Developer: Reload Window`

### 確認設定正確

執行以下檢查：

- ✅ VS Code 底部沒有 Gradle 相關錯誤
- ✅ Dart 程式碼有語法高亮和自動完成
- ✅ 可以正常執行 `flutter run`

---

## 常見問題 (FAQ)

### Q1: 為什麼要禁用 Java 擴充套件？

**A**: 這是 Flutter 專案，不是純 Java/Android 專案。Java 擴充套件會誤判 `android/` 資料夾為獨立專案，造成衝突。Flutter 開發只需要 Dart 和 Flutter 擴充套件。

### Q2: 禁用後會影響 Android 開發嗎？

**A**: 不會。Flutter 的 Android 部分由 Flutter 工具鏈管理，不需要 VS Code 的 Java 擴充套件。實際建置透過 `flutter build apk` 等指令完成。

### Q3: 如果真的需要編輯 Android 原生程式碼怎麼辦？

**A**:

- 方案 1：使用 Android Studio 開啟 `android/` 資料夾
- 方案 2：暫時啟用 Java 擴充套件，編輯完再停用

### Q4: `local.properties` 要加入版本控制嗎？

**A**: **不要**。這個檔案包含每個開發者的本機路徑，應該加入 `.gitignore`。每個開發者執行 `flutter pub get` 時會自動生成。

### Q5: 為什麼 `flutter.sdk` 路徑不是 FVM 的路徑？

**A**: Gradle 需要實際的 Flutter SDK 路徑。如果使用 FVM，應該指向 FVM 的 symlink 或全域安裝的 Flutter，而不是特定版本的路徑。

---

## 參考資源

- [VS Code Workspace Settings](https://code.visualstudio.com/docs/getstarted/settings)
- [json_serializable 文件](https://pub.dev/packages/json_serializable)
- [build_runner 文件](https://pub.dev/packages/build_runner)
- [Flutter Gradle 配置](https://docs.flutter.dev/deployment/android)

---

## 變更記錄

| 日期       | 變更內容                                 | 原因                                  |
| ---------- | ---------------------------------------- | ------------------------------------- |
| 2025-10-31 | 創建 `.vscode/settings.json`             | 禁用 Java/Gradle 擴充套件功能         |
| 2025-10-31 | 創建 `.vscode/extensions.json`           | 提示團隊成員使用正確的擴充套件        |
| 2025-10-31 | 修正 `local.properties` Flutter SDK 路徑 | 解決 Gradle 找不到 Flutter 工具的問題 |
| 2025-10-31 | 更新 `analysis_options.yaml`             | 排除自動生成檔案的警告                |

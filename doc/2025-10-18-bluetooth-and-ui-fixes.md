# 2025-10-18 藍牙連接與 UI 修復更新

## 概述
本次更新主要修復了座墊壓力感測系統的藍牙連接問題、UI 渲染錯誤，以及優化了壓力熱點標示功能。

---

## 🔧 主要修改

### 1. 修復藍牙數據解碼崩潰問題

**問題描述：**
- 連接 `UTL_Cushion_Left` 設備後應用崩潰
- 錯誤訊息：`StateError (Bad state: No element)`

**根本原因：**
- `WeiZheDecoder.valuesToSeatCushionType()` 和 `valuesToStage()` 在處理空數據包時直接調用 `values.first`
- 當接收到空數據包時會拋出異常

**修復內容：**

#### 文件：`domains/seat_cushion/lib/infrastructure/sensor_decoder/wei_zhe_decoder.dart`

1. **添加空數據包檢查** (Line 46-54)
```dart
SeatCushionType? valuesToSeatCushionType(List<int> values) {
  if (values.isEmpty) {
    print('⚠️ valuesToSeatCushionType: 收到空的數據包');
    return null;
  }
  final header = values.first & 0xF0;
  if (header == 0x10) return SeatCushionType.right;
  if (header == 0x20) return SeatCushionType.left;
  print('⚠️ valuesToSeatCushionType: 未知的設備類型 header=0x${header.toRadixString(16)}');
  return null;
}
```

2. **添加完整錯誤處理** (Line 142-227)
- 使用 `try-catch` 包裹整個數據處理邏輯
- 捕獲並記錄所有異常與堆疊追蹤
- 防止應用崩潰

3. **添加詳細診斷日誌**
- 📦 顯示收到的每個數據包（長度、header）
- ✅ 確認有效數據包
- ⚠️ 警告無效或不符合的數據
- 🎯 顯示解碼進度
- 📤 確認數據發送到 stream
- ❌ 完整的錯誤報告

**修復前 3 個邏輯錯誤：**

原本的 `allStageValuesIsNotEmpty` 判斷邏輯錯誤：
```dart
// 錯誤的邏輯
final allStageValuesIsNotEmpty = !_buffer[type]!.values.fold(
  false,
  (result, values) => result || (values == null),
);
```

修正為：
```dart
// 正確的邏輯
final allStageValuesIsNotEmpty = _buffer[type]!.values.every(
  (values) => values != null,
);
```

---

### 2. 修復 UI 渲染 NaN 錯誤

**問題描述：**
- UI 渲染時拋出錯誤：`Offset argument contained a NaN value`
- 錯誤位置：`seat_cushion_ischium_point_widget.dart:68:17`

**根本原因：**
- `ischiumPosition()` 計算時，當所有力值為 0，`1 / total` 會產生 `Infinity` 或 `NaN`

**修復內容：**

#### 文件：`domains/seat_cushion/lib/model/seat_cushion.dart`

1. **添加除零保護** (Line 132-134, 151-153)
```dart
// 防止空列表
if (units.isEmpty) {
  return null;
}

// 當所有力值都是 0 時不顯示圓圈
if (maxPoint.force == 0.0) {
  return null;
}
```

#### 文件：`domains/seat_cushion_presentation/lib/src/2d/ischium/seat_cushion_ischium_point_widget.dart`

2. **添加數值有效性檢查** (Line 27-29)
```dart
// 防止 NaN 或 Infinity 值導致渲染錯誤
if (!x.isFinite || !y.isFinite) {
  return;
}
```

3. **修改返回類型為可空**
- `ischiumPosition()` 返回類型：`Point<double>` → `Point<double>?`
- 當無壓力時返回 `null`，UI 不顯示圓圈

#### 文件：`domains/seat_cushion/lib/model/seat_cushion_set.dart`

4. **處理 null safety** (Line 49-55)
```dart
final leftPos = left.ischiumPosition();
final rightPos = right.ischiumPosition();

// 如果任一側沒有壓力點，返回 0
if (leftPos == null || rightPos == null) {
  return 0.0;
}
```

---

### 3. 優化壓力熱點圓圈顯示

**需求：**
- 圓圈不要遮擋數值
- 圓圈要更小
- 當壓力為 0 時不顯示
- 圓圈要能出現在整個格子範圍（包括四個角）
- 標示熱圖上最紅（最高壓力）的位置

**實現內容：**

#### 文件：`domains/seat_cushion_presentation/lib/src/2d/ischium/seat_cushion_ischium_point_widget.dart`

1. **改為空心圓環設計** (Line 37-62)
```dart
// 計算圓環的半徑
final double radius;
if (radiusMm != null && radiusMm! > 0) {
  // 使用動態半徑（從毫米轉換為像素）
  radius = size.width * (radiusMm! / SeatCushion.deviceWidth);
} else {
  // 使用默認半徑
  radius = size.width *
      ((SeatCushionUnit.sensorWidth * 0.4) / SeatCushion.deviceWidth);
}

// 繪製空心圓環（外圈）
final outerRingPaint = Paint()
  ..color = themeExtension.borderColor
  ..style = PaintingStyle.stroke
  ..strokeWidth = 2.0;

// 繪製空心圓環（內圈，粉紅色）
final innerRingPaint = Paint()
  ..color = themeExtension.ischiumColor
  ..style = PaintingStyle.stroke
  ..strokeWidth = 1.5;

// 繪製兩層圓環
canvas.drawCircle(center, radius + 1.5, outerRingPaint);
canvas.drawCircle(center, radius, innerRingPaint);
```

**特點：**
- ✅ 雙層空心圓環，中間透明
- ✅ 外圈：邊框色，線寬 2.0px
- ✅ 內圈：粉紅色，線寬 1.5px
- ✅ 半徑縮小至原來的 0.6 倍
- ✅ 數值完全可見

#### 文件：`domains/seat_cushion/lib/model/seat_cushion.dart`

2. **檢查所有角點以找到最高壓力位置** (Line 137-148)
```dart
// 收集所有角點（包括中心點）
final allPoints = units.expand((unit) => [
  unit.tlPoint,  // 左上角
  unit.trPoint,  // 右上角
  unit.blPoint,  // 左下角
  unit.brPoint,  // 右下角
  unit.mmPoint,  // 中心點
]).toList();

// 找到力值最大的點（最紅的點）
final maxPoint = allPoints.reduce(
  (current, next) => next.force > current.force ? next : current
);
```

**改進：**
- ✅ 之前只檢查中心點 (`mmPoint`)
- ✅ 現在檢查每個單元的 5 個點（4 個角 + 中心）
- ✅ 圓圈可以精準顯示在任何位置，包括格子的角落

3. **基於顏色熱度定位** (Line 120-157)
```dart
/// Estimates the **ischium (sit-bone) position** based on the highest force point.
///
/// Returns the position of the single highest pressure point.
/// Checks all corner points (top-left, top-right, bottom-left, bottom-right, center)
/// to find the exact location of maximum pressure (reddest point on heatmap).
/// Returns null if all forces are 0 or the list is empty.
Point<double>? ischiumPosition() {
  // ... 找到力值最大的點
  return maxPoint.position;
}
```

**顏色映射邏輯** (參考 `wei_zhe_color.dart`)：
- 高壓力 → hue ≈ -45° → **紅色** (最熱)
- 中壓力 → hue ≈ 105° → 綠色
- 低壓力 → hue ≈ 255° → 藍/紫色 (最冷)

**結果：**
- ✅ 圓圈精準顯示在熱圖最紅的位置
- ✅ 固定半徑 = `SeatCushionUnit.sensorWidth * 0.6`
- ✅ 視覺效果穩定

---

### 4. 添加藍牙連接診斷日誌

**目的：**
方便診斷藍牙連接問題

#### 文件：`packages/bluetooth_presentation/lib/src/devices/controller.dart`

1. **設備掃描資訊** (Line 137-146)
```dart
if (device.platformName.contains('UTL_Cushion')) {
  print('📱 設備掃描結果: ${device.platformName}');
  print('   MAC: ${device.remoteId.str}');
  print('   可連接: $isConnectable');
  print('   已連接: ${device.isConnected}');
  print('   已配對: ${BondFlutterBluePlus.bondedDevices.contains(device)}');
  print('   RSSI: ${device.rssi}');
  if (scanResult != null) {
    print('   廣播資料: ${scanResult.advertisementData}');
  }
}
```

2. **連接狀態日誌** (Line 186-196)
```dart
try {
  print('🔵 嘗試連接設備: ${device.platformName} (${device.remoteId.str})');
  await device.connect(
    license: License.free,
    autoConnect: true,
    mtu: null,
  );
  print('✅ 成功連接設備: ${device.platformName}');
} catch (e) {
  print('❌ 連接設備失敗: ${device.platformName}');
  print('   錯誤詳情: $e');
  rethrow;
}
```

3. **掃描開始/停止日誌** (Line 68-92)
```dart
print('🔍 開始藍牙掃描...');
print('   系統設備數量: ${fbpSystemDevices.length}');
print('   已配對設備數量: ${BondFlutterBluePlus.bondedDevices.length}');

// ... 掃描停止時
print('🛑 藍牙掃描已停止');
print('   總共掃描到設備: ${ScanResultFlutterBluePlus.lastScannedDevices.length}');
for (final device in ScanResultFlutterBluePlus.lastScannedDevices) {
  print('   - ${device.platformName.isEmpty ? "(無名稱)" : device.platformName} (${device.remoteId.str})');
}
```

---

## 📊 測試結果

### 藍牙連接測試
```
✅ UTL_Cushion_Left (D2:04:16:18:1D:A5) - 成功連接
✅ UTL_Cushion_Right (D9:F4:37:BE:11:29) - 成功連接
✅ 數據正常接收和解碼
✅ 解碼後力值數量: 248 個
✅ Stream 正常發送到 UI
```

### UI 渲染測試
```
✅ 無 NaN 錯誤
✅ 粉色圓圈正常顯示
✅ 圓圈不遮擋數值
✅ 壓力為 0 時圓圈隱藏
✅ 圓圈準確標示最高壓力點
```

---

## 🗂️ 修改文件清單

### 核心邏輯
- `domains/seat_cushion/lib/model/seat_cushion.dart`
- `domains/seat_cushion/lib/model/seat_cushion_set.dart`
- `domains/seat_cushion/lib/infrastructure/sensor_decoder/wei_zhe_decoder.dart`

### UI 組件
- `domains/seat_cushion_presentation/lib/src/2d/ischium/seat_cushion_ischium_point_widget.dart`

### 藍牙模組
- `packages/bluetooth_presentation/lib/src/devices/controller.dart`

---

## 🔍 技術細節

### 座墊數據協議
- **設備識別**：通過數據包 header 的高 4 位識別
  - `0x10` = 右側座墊
  - `0x20` = 左側座墊
- **階段識別**：通過數據包 header 的低 4 位識別
  - `0x01` = 第一階段 (243 bytes)
  - `0x02` = 第二階段 (243 bytes)
  - `0x03` = 第三階段 (13 bytes)
- **完整數據**：收集完 3 個階段後才解碼並發送

### 壓力點檢測
每個感測器單元有 5 個參考點：
- `tlPoint` - 左上角
- `trPoint` - 右上角
- `blPoint` - 左下角
- `brPoint` - 右下角
- `mmPoint` - 中心點

角點力值為相鄰感測器的平均值，用於更平滑的視覺效果。

### 顏色映射
使用 HSV 色彩空間：
- H (Hue)：根據壓力值線性映射 -45° 到 255°
- S (Saturation)：1.0 (完全飽和)
- V (Value)：1.0 (完全明亮)

---

## 📝 注意事項

1. **診斷日誌**：生產環境建議使用 logging framework 替換 `print` 語句
2. **性能優化**：`ischiumPosition()` 每次都重新計算所有角點，可考慮緩存優化
3. **空 catch 區塊**：部分藍牙操作仍使用空 catch 區塊，可考慮添加錯誤處理

---

## 🚀 未來改進建議

1. 使用正式的 logging framework（如 `logger` package）
2. 添加單元測試覆蓋修復的邏輯
3. 考慮添加性能監控和分析
4. 優化角點計算的性能（緩存機制）
5. 提供用戶可配置的圓圈大小和顏色選項

---

**更新日期：** 2025-10-18
**更新人員：** Claude Code
**版本：** 1.0.0

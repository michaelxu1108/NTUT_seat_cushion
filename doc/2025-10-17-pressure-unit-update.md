# 壓力單位更新 - 2025-10-17

## 概述

本次更新將座墊壓力感測器的顯示單位從**公斤（kg）**改為**毫米汞柱（mmHg）**，並在熱圖的每個感測器點上顯示數值。

## 更新內容

### 1. Git 歷史恢復

- **恢復了被刪除的專案檔案**
  - 使用 `git revert 69d658b` 恢復了 `ad5940_temp_debugger` app
  - 恢復了 `domains/ad5940` domain package
  - 保留了 `2873b18` (增加測試用假資料選項) 的變更

- **最終 commit 歷史**
  ```
  185aacc 增加測試用假資料選項
  a84c1c1 Revert "刪除無用專案資料"
  69d658b 刪除無用專案資料
  6d29bad init
  ```

### 2. 壓力單位轉換為 mmHg

#### 換算邏輯
- **1 kg = 760 mmHg** (根據 1 kg = 1 bar = 760 mmHg)
- 原始數據單位：克（g）
- 顯示單位：毫米汞柱（mmHg）

#### 數值範圍變更
- **原始範圍**：0.0 - 2.5 kg
- **新範圍**：0 - 1900 mmHg

### 3. 彩條單位更新

**檔案：** `apps/seat_cushion_debugger/lib/presentation/widget/seat_cushion_force_color_bar/widget.dart`

**變更內容：**
```dart
// 修改前
Text((SeatCushion.forceMin / 1000.0).toString()),  // 0.0
Text((SeatCushion.forceMax / 1000.0).toString()),  // 2.5

// 修改後
Text('${(SeatCushion.forceMin / 1000.0 * 760).toStringAsFixed(0)} mmHg'),  // 0 mmHg
Text('${(SeatCushion.forceMax / 1000.0 * 760).toStringAsFixed(0)} mmHg'),  // 1900 mmHg
```

### 4. 熱圖數值標示

**檔案：** `domains/seat_cushion_presentation/lib/src/2d/force/widget/seat_cushion_force_widget.dart`

**新增功能：**
- 在每個感測器方格中央顯示壓力數值（以 mmHg 為單位）
- 自動對比色文字顏色選擇
  - 背景亮色（luminance > 0.5）→ 黑色文字
  - 背景暗色（luminance ≤ 0.5）→ 白色文字
- 文字大小自動縮放以適應方格尺寸
- 數值顯示為整數（例如：0, 380, 760, 1140, 1900）

**實作細節：**
```dart
// 轉換公式
final forceInMmHg = (force / 1000.0) * 760;

// 文字顯示
Text(
  forceInMmHg.toStringAsFixed(0),
  style: TextStyle(
    color: _getContrastColor(backgroundColor),
    fontSize: min(width, height) * 0.25,
    fontWeight: FontWeight.bold,
  ),
)

// 對比色計算
Color _getContrastColor(Color backgroundColor) {
  final luminance = backgroundColor.computeLuminance();
  return luminance > 0.5 ? Colors.black : Colors.white;
}
```

## 影響範圍

### 修改的檔案
1. `apps/seat_cushion_debugger/lib/presentation/widget/seat_cushion_force_color_bar/widget.dart`
   - 彩條下方的單位標示

2. `domains/seat_cushion_presentation/lib/src/2d/force/widget/seat_cushion_force_widget.dart`
   - 熱圖感測器方格的數值顯示

### 資料模型
- **未修改** `domains/seat_cushion/lib/model/seat_cushion.dart`
- 原始數據單位保持為克（g）
- 僅在 UI 顯示層進行單位轉換

## 使用說明

### Mock 模式配置
在 `apps/seat_cushion_debugger/lib/main.dart` 第 31 行：
```dart
const bool useMockData = true;  // true = 模擬數據，false = 藍牙裝置
```

### 顯示效果
1. **彩條下方**
   - 左側：`0 mmHg`
   - 右側：`1900 mmHg`

2. **熱圖座標點**
   - 每個方格中央顯示當前壓力值
   - 範圍：0 - 1900 mmHg
   - 顏色漸層：藍色（低壓）→ 綠色 → 黃色 → 紅色（高壓）

## 技術細節

### 壓力數據流
```
感測器原始數據 (g)
    ↓
SeatCushion.forces[row][column] (0-2500g)
    ↓
UI 顯示轉換：(force / 1000.0) * 760
    ↓
顯示數值 (mmHg)
```

### 顏色映射
- 使用 `weiZheForceToColorConverter` 進行壓力到顏色的轉換
- 彩條分為 64 層漸層顏色
- 顏色範圍對應 0-2500g 的壓力值

## 後續建議

1. **單位換算精確性**
   - 目前使用簡化公式 `1 kg = 760 mmHg`
   - 如需更精確換算，建議使用 `1 kg/cm² = 735.56 mmHg`

2. **顯示優化**
   - 可考慮在熱圖上方添加 "mmHg" 單位說明
   - 可調整文字大小以適應不同螢幕尺寸

3. **資料記錄**
   - 確認匯出的 JSON 檔案是否需要包含單位資訊
   - 考慮在資料中保存單位換算係數

## 測試檢查清單

- [x] 彩條下方顯示 mmHg 單位
- [x] 熱圖每個點顯示數值
- [x] 文字顏色與背景有良好對比
- [x] Mock 模式可正常運行
- [ ] 藍牙模式實際裝置測試
- [ ] 不同螢幕尺寸的顯示效果
- [ ] 資料匯出功能測試

## 參考資料

- 原始壓力範圍定義：`domains/seat_cushion/lib/model/seat_cushion.dart`
- 顏色轉換器：`weiZheForceToColorConverter`
- 單位換算：1 kg = 1 bar = 760 mmHg (簡化公式)

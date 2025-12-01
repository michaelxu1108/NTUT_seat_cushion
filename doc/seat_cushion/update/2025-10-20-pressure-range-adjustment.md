# 座墊壓力範圍調整 (2025-10-20)

## 問題描述

廠商回饋當前壓力顯示範圍過大，導致感測器數值飽和：

> 壓力單位1900 mmHg比較大，我們以前測試在800-900 mmHg，有座墊，降壓到400-500 mmHg，電子壓力墊仍然是1900 mmHg，表示max peak pressure 已經飽和

### 實際測量數據

- **無座墊時**: 800-900 mmHg
- **有座墊時**: 400-500 mmHg
- **當前顯示**: 1900 mmHg（飽和）

## 修改需求

1. 使用國際標準轉換公式 (1 bar = 750.062 mmHg)
2. 將最大壓力值設定在 800-900 mmHg 範圍內（對應 1.2 bar），避免感測器飽和
3. 確保所有顯示位置都使用一致的轉換公式和範圍限制

## 計算說明

### 新的最大壓力值計算

使用國際標準轉換公式：

- 1 bar = 750.062 mmHg
- 目標最大值: 900 mmHg

計算過程：

```text
forceMax = 900 mmHg / 750.062 = 1.2 bar
```

### 壓力範圍對照表

| 壓力 (bar) | 壓力 (mmHg) | 說明 |
|-----------|------------|------|
| 0         | 0          | 無壓力 |
| 0.533     | 400        | 有座墊時典型值（下限） |
| 0.667     | 500        | 有座墊時典型值（上限） |
| 1.067     | 800        | 無座墊時測量值（下限） |
| 1.2       | 900        | 無座墊時測量值（上限）/ 新最大值 |
| ~~2.5~~   | ~~1875~~   | ~~舊最大值（已飽和）~~ |

**備註**: 程式碼內部使用 grams 為單位（1 bar = 1000 grams），因此 `forceMax = 1200` grams = 1.2 bar。

## 修改內容

### 修改 1: 調整最大壓力常數

**檔案**: `domains/seat_cushion/lib/model/seat_cushion.dart`

**位置**: Line 55

**修改前**:

```dart
/// Maximum measurable force of each unit sensor.
static const double forceMax = 2500;  // 2.5 bar
```

**修改後**:

```dart
/// Maximum measurable force of each unit sensor.
static const double forceMax = 1200;  // 1.2 bar
```

**說明**: 將最大力值從 2.5 bar 降至 1.2 bar，對應 900 mmHg 的目標最大值。

---

### 修改 2: 更新壓力顯示轉換公式

**檔案**: `domains/seat_cushion_presentation/lib/src/2d/force/widget/seat_cushion_force_widget.dart`

**位置**: Line 43-45

**修改前**:

```dart
// Convert force from grams to mmHg (1kg = 760mmHg)
final forceInMmHg = (force / 1000.0) * 760;
```

**修改後**:

```dart
// Convert force from grams to mmHg (1 bar = 750.062 mmHg)
// Clamp to maximum 900 mmHg to prevent display overflow
final forceInMmHg = ((force / 1000.0) * 750.062).clamp(0.0, 900.0);
```

**說明**:

- 使用國際標準轉換係數 750.062（1 bar = 750.062 mmHg）
- 加入 `.clamp(0.0, 900.0)` 確保顯示值不會超過 900 mmHg
- 即使感測器測量到超過 1.2 bar（例如 1.216 bar = 912 mmHg），顯示值也會被限制為 900 mmHg

**轉換邏輯**:

```text
force (grams) / 1000 = pressure (bar)
pressure (bar) × 750.062 = pressure (mmHg)
```

---

### 修改 3: 更新色條標籤

**檔案**: `apps/seat_cushion_debugger/lib/presentation/widget/seat_cushion_force_color_bar/widget.dart`

**位置**: Line 33 和 35

**修改前**:

```dart
Row(
  children: [
    Text('${(SeatCushion.forceMin / 1000.0 * 760).toStringAsFixed(0)} mmHg'),
    Spacer(),
    Text('${(SeatCushion.forceMax / 1000.0 * 760).toStringAsFixed(0)} mmHg'),
  ],
),
```

**修改後**:

```dart
Row(
  children: [
    Text('${((SeatCushion.forceMin / 1000.0 * 750.062).clamp(0.0, 900.0)).toStringAsFixed(0)} mmHg'),
    Spacer(),
    Text('${((SeatCushion.forceMax / 1000.0 * 750.062).clamp(0.0, 900.0)).toStringAsFixed(0)} mmHg'),
  ],
),
```

**說明**:

- 色條標籤同步使用新的轉換公式 750.062
- 加入 clamp 確保標籤顯示 "0 mmHg" 和 "900 mmHg"
- 與實際數值顯示範圍保持一致

## 問題排查過程

### 問題 1: 顯示值超過 900 mmHg

**現象**: 測試時發現格子內顯示 912 mmHg

**原因分析**:

- 藍牙硬體感測器測量到約 1.216 bar 的壓力
- 解碼器直接轉換：`1.216 bar × 750.062 = 912 mmHg`
- `forceMax = 1.2 bar` 只用於顏色映射的 clamp，不會限制顯示數值

**解決方案**: 在 `seat_cushion_force_widget.dart` 加入 `.clamp(0.0, 900.0)`

---

### 問題 2: 色條標籤仍顯示 912 mmHg

**現象**: App 下方色條的最大值標籤顯示 912 mmHg

**原因分析**:

- 色條標籤檔案仍使用舊的轉換公式 `* 760`
- 沒有加入 clamp 限制
- 獨立於主要數值顯示邏輯

**解決方案**: 更新 `seat_cushion_force_color_bar/widget.dart` 使用相同的轉換公式和 clamp

## 修改結果

- ✅ 新的最大顯示值: **900 mmHg (1.2 bar)**
- ✅ 符合廠商實際測量範圍: 800-900 mmHg (1.067-1.2 bar)
- ✅ 避免感測器飽和問題
- ✅ 使用國際標準轉換公式 (1 bar = 750.062 mmHg)
- ✅ 所有顯示位置（格子內數值、色條標籤）一致使用相同公式
- ✅ 通過 Flutter analyze 驗證，無錯誤

## 影響範圍

### 修改檔案

1. `domains/seat_cushion/lib/model/seat_cushion.dart` - 最大壓力常數 (1.2 bar)
2. `domains/seat_cushion_presentation/lib/src/2d/force/widget/seat_cushion_force_widget.dart` - 數值顯示轉換
3. `apps/seat_cushion_debugger/lib/presentation/widget/seat_cushion_force_color_bar/widget.dart` - 色條標籤

### 相關檔案（未修改）

- `domains/seat_cushion/lib/infrastructure/sensor_decoder/wei_zhe_decoder.dart` - 藍牙數據解碼不受影響
- `domains/seat_cushion_presentation/lib/src/color/infrastructure/wei_zhe_color.dart` - 顏色映射自動使用新的 `forceMax = 1.2 bar`

## 測試建議

1. 實際測試無座墊時的壓力顯示是否在 800-900 mmHg (1.067-1.2 bar) 範圍
2. 確認有座墊時的壓力顯示降至 400-500 mmHg (0.533-0.667 bar)
3. 驗證熱圖顏色映射正常（紅色應出現在接近 900 mmHg / 1.2 bar 時）
4. 確認所有位置（格子內、色條標籤）都顯示最大值 900 mmHg
5. 確認不再出現超過 900 mmHg 的顯示值
6. 確認不再出現 1900 mmHg (2.5 bar) 飽和現象

## 技術細節

### 為什麼需要 clamp？

雖然 `forceMax = 1.2 bar` 會限制顏色映射的範圍，但藍牙感測器可能回傳超過 1.2 bar 的原始數值。如果不加 clamp：

- 顏色會被限制在最大值（紅色）✅
- 但數值顯示會超過 900 mmHg（例如 912）❌

加入 `.clamp(0.0, 900.0)` 後：

- 顏色限制在最大值（紅色）✅
- 數值顯示也限制在 900 mmHg ✅

### 轉換公式說明

程式碼內部使用 **grams** 作為儲存單位，轉換關係為：

```text
1 bar = 1000 grams = 1 kg
1 bar = 750.062 mmHg
```

因此轉換流程：

1. **藍牙接收**: 原始數據（16-bit 整數）
2. **解碼**: 轉換為 force (grams)
3. **顯示**: `(force / 1000) × 750.062 = mmHg`

### 為什麼選擇 1 bar = 750.062 mmHg？

- **舊公式**: 使用標準大氣壓 1 atm = 760 mmHg
- **新公式**: 使用國際標準 1 bar = 750.062 mmHg

1 bar 是 SI 制壓力單位，更符合工程慣例和國際標準。

### 程式碼驗證

檢查關鍵轉換是否正確：

```dart
// ✅ 正確: 1.2 bar = 1200 grams
forceMax = 1200

// ✅ 正確: (1200 / 1000) × 750.062 = 900.0744 mmHg ≈ 900 mmHg
(1200 / 1000.0) * 750.062 = 900.0744

// ✅ 正確: clamp 確保不超過 900
((1200 / 1000.0) * 750.062).clamp(0.0, 900.0) = 900.0
```

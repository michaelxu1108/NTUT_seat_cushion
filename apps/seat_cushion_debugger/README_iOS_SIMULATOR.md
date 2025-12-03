# iOS 模擬器藍牙模擬模式使用說明
# iOS Simulator Bluetooth Mock Mode Guide

## 快速開始 Quick Start

### 1. 設定模擬模式 Configure Mock Mode

在 `lib/main.dart` 檔案的第 46 行，找到以下設定：

```dart
const bool useMockData = true;
```

- **`true`**: 使用模擬資料（適用於 iOS 模擬器）
  - Use mock data (for iOS Simulator)

- **`false`**: 使用真實藍牙（僅適用於實體裝置）
  - Use real Bluetooth (for physical devices only)

### 2. iOS 模擬器執行步驟

```bash
# 1. 開啟 iOS 模擬器
open -a Simulator

# 2. 確認 useMockData = true
# Ensure useMockData = true in lib/main.dart

# 3. 執行應用程式
flutter run
```

### 3. 實體裝置執行步驟

```bash
# 1. 連接 iPhone/iPad 到 Mac
# Connect iPhone/iPad to Mac

# 2. 設定 useMockData = false
# Set useMockData = false in lib/main.dart

# 3. 執行應用程式
flutter run
```

---

## 技術說明 Technical Details

### 模擬模式功能 Mock Mode Features

當 `useMockData = true` 時：

1. **自動生成模擬資料**
   - 使用 `AutoMockSeatCushionSensor()` 自動產生坐墊壓力資料
   - 不需要實體藍牙裝置或連接

2. **完全略過藍牙檢查**
   - 設定 `fbpIsSupported = false` 完全關閉藍牙功能
   - 直接進入主頁面，不會卡在藍牙開啟畫面
   - 避免 iOS 模擬器的「Bluetooth Adapter is not available」錯誤

3. **完整功能測試**
   - UI 介面正常運作
   - 資料記錄、清除、下載功能可用
   - 壓力視覺化顯示正常
   - 所有坐墊相關功能都可以測試（除了真實藍牙連接）

### 真實藍牙模式 Real Bluetooth Mode

當 `useMockData = false` 時：

1. **連接實體裝置**
   - 使用 `BluetoothSeatCushionSensor()` 連接真實坐墊
   - 需要實體 iPhone/iPad（iOS 模擬器不支援）

2. **藍牙掃描與配對**
   - 可掃描附近的藍牙裝置
   - 可連接並接收真實資料

---

## 除錯訊息 Debug Messages

執行時會在控制台看到以下訊息：

### 模擬模式
```
🔧 執行模擬模式 - 使用模擬坐墊資料（適用於 iOS 模擬器）
🔧 Running in MOCK MODE - Using simulated seat cushion data (for iOS Simulator)
```

### 真實藍牙模式
```
📱 執行藍牙模式 - 連接到真實坐墊裝置
📱 Running in BLUETOOTH MODE - Connecting to real seat cushion device
```

---

## 常見問題 FAQ

### Q1: iOS 模擬器可以使用真實藍牙嗎？
**A:** 不行。iOS 模擬器不支援藍牙硬體，必須使用模擬模式。

### Q2: 為什麼會卡在「Bluetooth Adapter is not available」畫面？
**A:** 這表示 `useMockData` 可能設為 `false`，或是舊版程式碼的問題。請確認：
- `lib/main.dart` 第 46 行設定為 `const bool useMockData = true;`
- 使用最新版本的程式碼（`fbpIsSupported = false` 在模擬模式下）
- 重新啟動應用程式

### Q3: 如何切換模式？
**A:** 修改 `lib/main.dart` 第 46 行的 `useMockData` 值，然後重新執行應用程式。

### Q4: 模擬資料是隨機的嗎？
**A:** 是的。`AutoMockSeatCushionSensor()` 會自動生成模擬的坐墊壓力資料。

### Q5: 可以在實體裝置上使用模擬模式嗎？
**A:** 可以。即使在實體 iPhone/iPad 上也可以使用模擬模式進行測試。

### Q6: 模擬模式下藍牙相關功能會怎麼樣？
**A:** 在模擬模式下，藍牙掃描、連接等功能會被完全略過，但坐墊資料的顯示、記錄、下載等功能都正常運作。

---

## 程式碼結構 Code Structure

```
lib/main.dart
├── useMockData (第 46 行)          // 模擬模式開關
├── main()
│   ├── 傳感器初始化                 // Sensor initialization
│   │   ├── AutoMockSeatCushionSensor()    (模擬模式)
│   │   └── BluetoothSeatCushionSensor()   (真實模式)
│   ├── Initializer 配置
│   └── runApp(MyApp())
└── MyApp
    └── MultiProvider
        ├── 藍牙相關提供者            // Bluetooth providers
        └── 坐墊感測器提供者          // Sensor providers
```

---

## 開發建議 Development Tips

1. **開發階段**：使用模擬模式在 iOS 模擬器上快速測試 UI 和功能
2. **測試階段**：在實體裝置上使用真實藍牙模式測試完整功能
3. **除錯**：觀察控制台的除錯訊息確認當前模式
4. **版本控制**：提交前記得檢查 `useMockData` 的設定值

---

## 相關檔案 Related Files

- `lib/main.dart` - 主程式入口與模式設定
- `packages/seat_cushion/lib/infrastructure/sensor/auto_mock_sensor.dart` - 模擬感測器
- `packages/seat_cushion/lib/infrastructure/sensor/bluetooth_sensor.dart` - 真實藍牙感測器

---

最後更新：2025-11-15
Last Updated: 2025-11-15

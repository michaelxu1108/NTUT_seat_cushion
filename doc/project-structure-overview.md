# NTUT-UTL Flutter Monorepo 專案結構總覽

> 文件建立日期：2025-10-21
> 專案路徑：`/Users/xuguanwen/Desktop/projects/flutter/NTUT-UTL-Flutter-Monorepo_editV2`

## 專案概述

這是一個使用 Melos 管理的 Flutter Monorepo 專案，包含多個獨立應用和共享模組。主要專案為座墊壓力感測系統，另外還包含病毒檢測車控制器、藍牙調試器等應用。

---

## 目錄結構

```
NTUT-UTL-Flutter-Monorepo_editV2/
├── apps/                  # 可獨立執行的應用程式
├── domains/               # 核心業務邏輯模組
├── packages/              # 共享工具和UI元件包
├── doc/                   # 專案文件
├── pubspec.yaml          # Workspace 配置 (Melos)
├── .github/              # GitHub 工作流程
└── .vscode/              # VS Code 設定
```

---

## 1. 應用層 (apps/)

### 🪑 座墊壓力感測系統

#### Seat Cushion Debugger
- **路徑**: `apps/seat_cushion_debugger`
- **描述**: 座墊調試應用
- **用途**: 調試和測試座墊壓力感測系統
- **主要功能**:
  - 即時壓力數據顯示（2D 熱圖）
  - 3D 座墊模型渲染
  - 壓力數值標示（mmHg 單位）
  - 藍牙連接管理
- **依賴**: `seat_cushion`, `seat_cushion_presentation`, `bluetooth_utils` 等
- **最新更新**: 壓力範圍調整至 1.2 bar (900 mmHg)

### 🦠 病毒檢測車系統

#### Virus Detector Cart Controller
- **路徑**: `apps/virus_detector_cart_controller`
- **描述**: 病毒檢測車控制器
- **用途**: 病毒檢測車的移動控制系統
- **主要功能**:
  - 搖桿控制
  - Syncfusion 圖表顯示
  - 數據導出功能
  - 3D 渲染
- **依賴**: 多個共用 packages, 3D 渲染庫

### 🔵 藍牙調試系統

#### Bluetooth Debugger
- **路徑**: `apps/bluetooth_debugger`
- **描述**: 藍牙調試應用
- **用途**: 藍牙連接和通信調試
- **主要功能**:
  - 藍牙設備掃描
  - 連接管理
  - 數據收發測試
- **依賴**: `bluetooth_presentation`, `bluetooth_utils`

### 🌡️ 溫度感測系統

#### AD5940 Temp Debugger
- **路徑**: `apps/ad5940_temp_debugger`
- **描述**: 溫度感測器調試應用
- **用途**: AD5940 晶片溫度測試
- **狀態**: 目前未列在主 pubspec.yaml workspace 中

---

## 2. 領域模組層 (domains/)

### 座墊相關

#### Seat Cushion
- **路徑**: `domains/seat_cushion`
- **描述**: 座墊核心模組
- **核心功能**:
  - 座墊壓力數據模型
  - 感測器協議解碼（Wei Zhe 協議）
  - 壓力常數: `forceMax = 1200` (1.2 bar / 900 mmHg)
- **依賴**: `bluetooth_utils`, `stream_utils`

#### Seat Cushion Presentation
- **路徑**: `domains/seat_cushion_presentation`
- **描述**: 座墊展示模組
- **核心功能**:
  - 2D 熱圖顯示（76x48 格子）
  - 3D 座墊模型渲染
  - 壓力顏色映射 (`wei_zhe_color.dart`)
  - 壓力單位轉換: `(force/1000) * 750.062 = mmHg`
- **依賴**: `seat_cushion`, `simple_3d`, `stream_utils`
- **包含**: 示例應用 (`/example`)

### 電化學相關

#### Electrochemical
- **路徑**: `domains/electrochemical`
- **描述**: 電化學模組
- **用途**: 電化學感測數據處理
- **依賴**: `bluetooth_utils`

#### AD5940
- **路徑**: `domains/ad5940`
- **描述**: AD5940 模組
- **用途**: AD5940 晶片驅動和數據解碼
- **核心功能**:
  - FFI 調用 C 程式庫
  - 溫度感測
  - 電化學感測
- **依賴**: `electrochemical`, `bluetooth_utils`
- **特殊**: 包含 FFI 綁定

---

## 3. 共享包層 (packages/)

### 藍牙相關

#### Bluetooth Presentation
- **路徑**: `packages/bluetooth_presentation`
- **用途**: 藍牙 UI 元件和狀態管理

#### Bluetooth Utils
- **路徑**: `packages/bluetooth_utils`
- **用途**: 藍牙通信協議和工具函數

### 數據處理

#### Data Presentation
- **路徑**: `packages/data_presentation`
- **用途**: 通用數據 UI 展示
- **包含**: 示例應用 (`/example`)

#### Data Utils
- **路徑**: `packages/data_utils`
- **用途**: 數據轉換和處理工具

### 系統工具

#### Path Provider Utils
- **路徑**: `packages/path_provider_utils`
- **用途**: 檔案系統路徑管理

#### File Utils
- **路徑**: `packages/file_utils`
- **用途**: 檔案讀寫操作

#### Stream Utils
- **路徑**: `packages/stream_utils`
- **用途**: Stream 和非同步處理工具

#### Text Editing Controller Utils
- **路徑**: `packages/text_editing_controller_utils`
- **用途**: Flutter TextEditingController 擴展功能

---

## 4. Workspace 配置

### Melos Workspace 包含的專案 (21個)

**應用 (3個)**:
- `apps/bluetooth_debugger`
- `apps/seat_cushion_debugger`
- `apps/virus_detector_cart_controller`

**領域模組 (4個)**:
- `domains/ad5940`
- `domains/electrochemical`
- `domains/seat_cushion`
- `domains/seat_cushion_presentation`

**共享包 (8個)**:
- `packages/bluetooth_presentation`
- `packages/bluetooth_utils`
- `packages/data_presentation`
- `packages/data_utils`
- `packages/file_utils`
- `packages/path_provider_utils`
- `packages/stream_utils`
- `packages/text_editing_controller_utils`

**示例應用 (2個)**:
- `domains/seat_cushion_presentation/example`
- `packages/data_presentation/example`

**其他 (4個)**:
- `domains/seat_cushion_presentation/packages/simple_3d`
- `packages/bluetooth_presentation/packages/bluetooth_ble`
- `packages/bluetooth_presentation/packages/bluetooth_classic`
- `packages/bluetooth_presentation/packages/bluetooth_permission`

---

## 5. 專案分類總結

### 座墊壓力感測系統（主要專案）
- **應用**: `seat_cushion_debugger`
- **業務邏輯**: `seat_cushion` domain
- **UI 展示**: `seat_cushion_presentation` domain
- **狀態**: 積極開發中
- **最新改進**: 壓力範圍調整至 900 mmHg (2025-10-20)

### 藍牙通信系統
- **應用**: `bluetooth_debugger`
- **表現層**: `bluetooth_presentation` package
- **工具層**: `bluetooth_utils` package

### 電化學感測系統
- **應用**: `ad5940_temp_debugger` (未在 workspace 中)
- **領域邏輯**: `electrochemical`, `ad5940` domains

### 病毒檢測車系統
- **應用**: `virus_detector_cart_controller`
- **功能**: 搖桿控制、圖表顯示、數據導出

### 通用工具和 UI 元件
- 8 個共享 package 提供跨專案的基礎功能

---

## 6. 最近開發記錄

根據 Git 提交歷史，最新的改進集中在座墊模組：

### 最近 5 次提交
1. **5cfc896** - 刪除無用檔案、取消假資料
2. **df50e81** - 修復藍牙連接崩潰與 UI 渲染錯誤，優化壓力熱點顯示
3. **aeedd2a** - 將座墊壓力顯示單位改為 mmHg 並在熱圖標示數值
4. **185aacc** - 增加測試用假資料選項
5. **a84c1c1** - Revert "刪除無用專案資料"

### 當前未提交的修改
- `apps/seat_cushion_debugger/lib/presentation/widget/seat_cushion_force_color_bar/widget.dart`
- `domains/seat_cushion/lib/model/seat_cushion.dart`
- `domains/seat_cushion_presentation/lib/src/2d/force/widget/seat_cushion_force_widget.dart`
- `doc/2025-10-20-pressure-range-adjustment.md` (新增)

---

## 7. 技術架構

### Monorepo 管理
- **工具**: Melos
- **包管理**: Pub workspace

### 主要技術棧
- **框架**: Flutter
- **狀態管理**: (待確認)
- **3D 渲染**: simple_3d (自訂套件)
- **藍牙**: flutter_blue_plus
- **FFI**: Dart FFI (用於 AD5940)
- **圖表**: Syncfusion (用於病毒檢測車)

### 開發環境
- **平台**: macOS (Darwin 25.0.0)
- **版本控制**: Git
- **編輯器**: VS Code

---

## 8. 相關文件

- [2025-10-17 壓力單位更新](./2025-10-17-pressure-unit-update.md)
- [2025-10-18 藍牙與 UI 修復](./2025-10-18-bluetooth-and-ui-fixes.md)
- [2025-10-20 壓力範圍調整](./2025-10-20-pressure-range-adjustment.md)

---

## 附註

### 專案重點
- **座墊系統**是主要開發重點
- **病毒檢測車**和**藍牙調試器**為輔助專案
- **AD5940 溫度感測器**目前處於實驗階段

### 未來發展方向
- 座墊系統持續優化壓力感測精度
- 改進藍牙連接穩定性
- 擴充數據分析和導出功能

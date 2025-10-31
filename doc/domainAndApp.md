# domains/ - 業務邏輯層

- 放什麼：核心業務邏輯、數據模型、業務規則
- 不包含：具體的 App 實現
- 可被誰用：多個 App 共用

例子：

- seat_cushion - 座墊數據處理、感測器解碼
- electrochemical - 電化學計算邏輯

apps/ - 應用程式層

- 放什麼：可執行的 Flutter 應用（有 main.dart）
- 包含：UI、導航、用戶交互
- 依賴：使用 domains 和 packages

例子：

- seat_cushion_debugger - 座墊調試工具（可執行 flutter run）
- bluetooth_debugger - 藍牙調試工具（可執行 flutter run）

---

簡單記憶

domains/ = 大腦（邏輯）
apps/ = 身體（介面）

apps 使用 domains 提供的功能，展示給使用者。

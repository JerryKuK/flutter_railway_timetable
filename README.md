# 鐵路時刻表

一款以 Flutter 開發的鐵路時刻表查詢 App，支援台鐵（TRA）與台灣高鐵（THSR）兩種鐵路系統，讓使用者可以快速查詢班次、瀏覽票價與個人設定。

---

## 功能介紹

### 首頁（Home）
- **高鐵 / 台鐵切換器**：分段控制器，切換時 UI 配色同步更新（台鐵藍色系、高鐵橘金色系）
- 出發站／到達站選擇（台鐵含縣市篩選 Tab；高鐵顯示 12 站清單）
- **站台記憶（Drift 持久化）**：App 關閉重開或切換頁面後，自動恢復上次選擇的出發／到達站；高鐵與台鐵各自獨立記憶
- 日期與時間選擇
- 查詢班次按鈕
- 近期查詢紀錄（依鐵路系統分流顯示，最多 5 筆）
- **分類清除近期查詢**：「清除全部」只清除當前鐵路類型的查詢紀錄，不影響另一系統

### 時刻表（Timetable）
- 台鐵：依 TDX TRA API v3 查詢 OD 班次
- 高鐵：依 TDX THSR API v2 查詢 OD 班次
- 顯示車次號碼、列車種類、出發／抵達時間、行駛時間、成人票價
- 依出發時間排序，並可過濾指定時間之後的班次
- 無班次時顯示空狀態畫面

### 我的車票（My Tickets）
- 顯示票券卡片（車次、時間、車站、座位）
- 標示「即將出發」與「已完成」狀態

### 我的（Profile）
- 使用者頭像與統計數據（里程、累積點數、常用路線）
- 功能選單

---

## 技術架構

| 層級 | 技術 |
|---|---|
| 狀態管理 | Flutter BLoC |
| 架構 | Clean Architecture（data / domain / presentation） |
| API 串接 | Retrofit + Dio（TDX 台鐵 API v3） |
| 路由 | GoRouter |
| 依賴注入 | GetIt + Injectable |
| 資料模型 | Freezed + json_serializable |
| 本地儲存 | Drift（SQLite） |
| 測試 | flutter_test + Mockito |

---

## 開發工具

這個 App 是透過以下工具協作開發：

### 🎨 Pencil
用於設計所有畫面的 UI 原型與視覺規格，包含元件樣式、間距、色彩系統，讓開發過程有明確的設計依據。

### 🎨 Claude Design
用於設計首頁高鐵 / 台鐵切換 UI 的視覺規格，以互動式 HTML/CSS/JS 原型定義配色系統（台鐵藍色系 `#2E72B8`、高鐵橘金色系 `#C86820`）、Segmented Control 的 Liquid Glass 樣式，以及 Station Picker Modal 的互動細節。設計稿透過 Claude Design 匯出為 handoff bundle，由 Claude Code 直接讀取並實作。

### 🤖 Claude Code
AI 程式開發助理，負責根據規格撰寫 Flutter 程式碼、修正問題、重構架構，並在每次實作後確認與設計稿的一致性。

### 📋 OpenSpec（SDD 工具）
採用規格驅動開發（Specification-Driven Development）流程。OpenSpec 管理每個功能的需求提案（proposal）、規格（spec）與變更記錄（changes），讓開發目標清晰且可追蹤。

### ✅ superpowers（TDD 測試套件）
遵循測試驅動開發（TDD）流程，每個 Use Case 與 BLoC 都有對應的單元測試。superpowers 提供結構化的測試撰寫規範，確保程式碼的正確性與可維護性。

### 📱 Agent Device
在 iOS 模擬器上自動執行 UI 操作，錄製端對端的使用者流程測試，並將結果儲存為 `.ad` workflow 檔案，驗證各功能的實際表現。

---

## 資料來源

本 App 使用 [TDX 運輸資料流通服務](https://tdx.transportdata.tw) API：

**台鐵（TRA）**
- 車站清單：`GET /api/basic/v2/Rail/TRA/Station`
- OD 班次時刻表：`GET /api/basic/v3/Rail/TRA/DailyTrainTimetable/OD/{origin}/to/{destination}/{date}`
- OD 票價：`GET /api/basic/v2/Rail/TRA/ODFare/{origin}/to/{destination}`

**高鐵（THSR）**
- 車站清單：`GET /api/basic/v2/Rail/THSR/Station`
- OD 班次時刻表：`GET /api/basic/v2/Rail/THSR/DailyTimetable/OD/{origin}/to/{destination}/{date}`
- OD 票價：`GET /api/basic/v2/Rail/THSR/ODFare/{origin}/to/{destination}`

> 需申請 TDX 帳號並取得 Client ID / Client Secret，設定於 `lib/core/env/env.dart`。

---

## Widget Extension 本地設定

本專案包含 iOS 桌面小工具（`RailwayWidget` Widget Extension），需額外設定 TDX 憑證。

### 步驟

1. **建立憑證檔案**

   在 `ios/RailwayWidget/` 目錄手動建立 `Secrets.xcconfig`（此檔案已加入 `.gitignore`，不會入版控）：

   ```xcconfig
   TDX_CLIENT_ID = your_client_id
   TDX_CLIENT_SECRET = your_client_secret
   ```

2. **Xcode Build Settings 引用 xcconfig**

   - 在 Xcode 開啟 `Runner.xcworkspace`
   - 選擇 `RailwayWidget` target → **Build Settings** → **Configurations**
   - 在 Debug / Release 兩個 configuration 的 `RailwayWidget` 行，點擊並選擇 `ios/RailwayWidget/Secrets.xcconfig`

3. **確認 App Group**

   - 確認主 App target（`Runner`）與 Widget target（`RailwayWidget`）都在 **Signing & Capabilities** 下啟用了 App Group：`group.com.jerry.railwaytimetable.widget`

4. **建置並測試**

   在 iOS 模擬器或實機上安裝 App，然後長按主畫面 → 新增小工具 → 搜尋「鐵路時刻表」。

> `Secrets.xcconfig` 已加入 `.gitignore`，不會被 commit。

---

## Android Widget 本地設定

本專案包含兩支 Android 桌面小工具：**鐵路時刻表（台鐵 4×2）** 與 **高鐵時刻表（高鐵 4×2）**。兩支 widget 共用同一組 TDX 憑證，無需分別設定。

### 步驟

1. **開啟 `android/local.properties`**

   加入以下兩行（此檔案已在 `android/.gitignore`，不會入版控）：

   ```properties
   TDX_CLIENT_ID=你的_Client_ID
   TDX_CLIENT_SECRET=你的_Client_Secret
   ```

2. **建置並確認**

   ```bash
   cd android && ./gradlew assembleDebug
   ```

3. **安裝並測試**

   安裝 App 後，長按 Android 主畫面 → 新增小工具 → 在 app 區段下可看到「鐵路時刻表」與「高鐵時刻表」兩個選項，皆為 4×2 尺寸，可同時釘住於桌面、各自獨立路線。點擊「查詢」按鈕取得最新班次。

> `local.properties` 已在 `android/.gitignore`，不會被 commit。兩支 widget 共用同一個 SharedPreferences file，但以不同 key prefix（TR 用 `widget_*`、HSR 用 `hsr_widget_*`）完全隔離狀態。

---

## 專案結構

```
lib/
├── core/
│   ├── di/          # 依賴注入
│   ├── env/         # 環境變數（API 金鑰）
│   ├── network/     # Dio 設定、TDX 認證攔截器
│   ├── router/      # GoRouter 路由設定
│   └── widgets/     # 共用元件（AppShell）
└── features/
    ├── home/        # 首頁
    ├── timetable/   # 時刻表
    ├── my_tickets/  # 我的車票
    └── profile/     # 我的
```

---

## 影片Demo

https://github.com/user-attachments/assets/9ef4c18d-5989-4c51-9dec-88ead482e544

---

<table>
<tr>
<td width="50%">

## iOS桌面小工具Demo

https://github.com/user-attachments/assets/ec8a902f-c45e-4903-93d3-7fb90f58e010

</td>
<td width="50%">

## Android桌面小工具Demo

https://github.com/user-attachments/assets/e7a2dae1-9fa6-461f-bec0-6a97954b2c60

</td>
</tr>
</table>

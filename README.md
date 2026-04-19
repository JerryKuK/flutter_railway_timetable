# 鐵路時刻表

一款以 Flutter 開發的鐵路時刻表查詢 App，支援台鐵（TRA）與台灣高鐵（THSR）兩種鐵路系統，讓使用者可以快速查詢班次、瀏覽票價與個人設定。

---

## 功能介紹

### 首頁（Home）
- **高鐵 / 台鐵切換器**：分段控制器，切換時 UI 配色同步更新（台鐵藍色系、高鐵橘金色系）
- 出發站／到達站選擇（台鐵含縣市篩選 Tab；高鐵顯示 12 站清單）
- 日期與時間選擇
- 查詢班次按鈕
- 近期查詢紀錄（依鐵路系統分流顯示）

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

https://github.com/user-attachments/assets/5dff5f23-9daf-493f-8d22-9002733a669d


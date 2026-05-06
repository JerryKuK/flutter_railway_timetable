## Why

使用者在 iOS 主畫面上無法快速查看下一班列車資訊，必須每次開啟 App 才能得知班次。iOS 桌面小工具可在主畫面直接顯示台鐵 / 高鐵最近班次，且透過 AppIntent 讓使用者直接在小工具上點擊「查詢」即時更新班次，無需開啟 App。

## What Changes

- 新增 iOS Widget Extension 目標（WidgetKit / SwiftUI），**僅支援 4×2（Medium）** 尺寸
- 支援台鐵（TR）與高鐵（HSR）兩種鐵路系統，配色沿用 App 主題（台鐵藍 `#2E72B8` / 高鐵橘 `#C86820`）
- Widget 外觀與互動完全依照設計稿 `Home Screen Widgets.html` 還原：
  - 白底圓角（r=22）卡片，列車圓形 icon + 系統名稱 + 可點擊路線
  - 兩列班次（出發時間 / 車種 badge / 車號 / 到站時間）
  - 右上角「查詢」膠囊按鈕（accent 色），點擊即觸發 AppIntent 重新打 TDX API
  - 出發站 / 到達站文字可點擊，跳轉至 App 內 `/widget-config` 設定頁
- **查詢按鈕使用 `AppIntent`**（iOS 16+）：Widget 內 SwiftUI `Button(intent:)` 觸發 `RefreshTimetableIntent`，於 Extension process 直接呼叫 TDX API 並呼叫 `WidgetCenter.shared.reloadTimelines`，不需開啟主 App
- Widget Extension 的 Swift 程式碼採用**乾淨架構**三層分離，與 Flutter 端對應的 TDX 邏輯平行實作
- **TDX Token 機密管理**：在 Xcode 以 `.xcconfig` 注入，對應 `.env` 的 `TDX_CLIENT_ID` / `TDX_CLIENT_SECRET`；`.xcconfig` 加入 `.gitignore`，不入版控
- Flutter App 新增 `home_widget` 套件，供設定出發 / 到達站後將資料寫入 App Group shared UserDefaults，Widget Extension 讀取後渲染

## Capabilities

### New Capabilities

- `ios-widget-extension`: iOS WidgetKit Extension（Swift/SwiftUI），僅 4×2 Medium 尺寸，依設計稿還原視覺；包含 `RailwayWidgetEntryView`（SwiftUI）、`RailwayTimelineProvider`（`TimelineProvider`）、`RefreshTimetableIntent`（`AppIntent`）。內部分三層：
  - **Domain**：`TrainScheduleRepository` protocol、`TrainSchedule` entity（出發/到達時間、車種、車號）、`GetNextTrainsUseCase`
  - **Data**：`TDXAuthManager`（token cache，邏輯同 Flutter `TdxAuthInterceptor`）、`TDXAPIClient`（URLSession）、`TrainScheduleRepositoryImpl`
  - **Presentation**：SwiftUI widget view、`WidgetEntry`（`TimelineEntry`）

- `widget-secrets-xcconfig`: iOS secrets 管理方案，以 `.xcconfig` 檔案注入 TDX 憑證至 Widget Extension build settings；鍵值透過 Widget target 的 `Info.plist` 橋接（`TDX_CLIENT_ID = $(TDX_CLIENT_ID)`），Swift 側以 `Bundle.main.infoDictionary` 讀取；`ios/WidgetExtension/Secrets.xcconfig` 加入 `.gitignore`，並提供 `Secrets.xcconfig.example` 範本入版控

- `widget-data-bridge`: Flutter Dart 側橋接層（`lib/features/widget_config/`），以 `home_widget` 套件將使用者選定的出發站 ID、到達站 ID、鐵路系統寫入 App Group UserDefaults；並在使用者選站後呼叫 `HomeWidget.updateWidget()` 觸發 WidgetKit timeline reload

### Modified Capabilities

- `station-picker`: Widget 設定路由 `/widget-config` 需要一個全螢幕站選介面，由現有 `StationPickerModal` 複用，不修改 Modal 本身；新增獨立的 `WidgetConfigPage`（Flutter）來承載選站流程，選站完成後呼叫 `widget-data-bridge` 更新 App Group

## Impact

- **新增 Flutter 依賴**：`home_widget ^4.x`
- **新增 iOS 設定**：
  - Xcode 新增 Widget Extension target（`RailwayWidget`）
  - App Group：`group.com.jerry.railwaytimetable.widget`（主 App target + Widget target 均啟用）
  - `ios/WidgetExtension/Secrets.xcconfig`（gitignored）+ `Secrets.xcconfig.example`（版控）
  - Widget target `Info.plist` 新增 `TDX_CLIENT_ID`、`TDX_CLIENT_SECRET` 鍵，對應 xcconfig 變數
- **資料流**：
  - 初始路線：Flutter App → `home_widget` → App Group UserDefaults → Widget TimelineProvider 渲染
  - 查詢更新：Widget 查詢按鈕 → `RefreshTimetableIntent` → `TDXAPIClient`（Swift，直接打 API）→ `WidgetCenter.reloadTimelines` → UI 刷新
- **影響範圍**：`lib/features/widget_config/`（新功能）、`ios/RailwayWidget/`（新 target）、`pubspec.yaml`、`ios/.gitignore`
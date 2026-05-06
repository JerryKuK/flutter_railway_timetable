## Requirements

### Requirement: Flutter 側以共享 SQLite 維護 Widget 選站清單
Flutter App SHALL 使用 Drift 在 App Group container 目錄建立 `widget_stations.db`，維護台鐵 / 高鐵各 10 個可選站台的排序清單，供 iOS Widget Extension 的選站 chip grid 讀取。

#### Scenario: App 啟動時初始化選站資料庫
- **WHEN** Flutter App 啟動，呼叫 `WidgetDataService.init()`
- **THEN** 透過 MethodChannel `getAppGroupDir` 取得 App Group 路徑，在該目錄建立 `widget_stations.db`；若資料表尚無資料，`initDefaultsIfNeeded()` 寫入台鐵 / 高鐵各 10 站預設值（與 Swift `PickerStationDefaults` 完全對應）

#### Scenario: 首頁搜尋後更新站台排序
- **WHEN** 使用者在首頁選好出發站 / 到達站後導航至時刻表頁
- **THEN** 系統呼叫 `UpdateWidgetStationsUseCase.execute()`，將搜尋路線的出發站和到達站移至對應系統 SQLite 清單頂端（`setFront()`），保留總數 ≤ 10；接著呼叫 `WidgetDataService.refreshWidget()` 觸發 WidgetKit timeline reload

#### Scenario: 資料庫尚未就緒時靜默跳過
- **WHEN** `UpdateWidgetStationsUseCase.execute()` 執行時，SQLite 資料表中該系統的站台數 < `maxStations`（10）
- **THEN** 直接返回，不修改資料庫，不拋出例外

---

### Requirement: Flutter MethodChannel 提供 App Group 路徑
Flutter App SHALL 透過 `AppDelegate.swift` 的 MethodChannel 取得 App Group container 目錄路徑，以便 Drift SQLite 存入正確位置。

#### Scenario: getAppGroupDir 回傳有效路徑
- **WHEN** Flutter 呼叫 MethodChannel `com.jerry.railwaytimetable/app_group` 的 `getAppGroupDir` 方法
- **THEN** `AppDelegate.swift` 回傳 `FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.jerry.railwaytimetable.widget")?.path`；路徑非空，Drift 可在該目錄建立 DB 檔案

#### Scenario: App Group 未正確設定時靜默降級
- **WHEN** `getAppGroupDir` 回傳 nil 或空字串（App Group entitlement 未設定）
- **THEN** `WidgetDataService.init()` 跳過資料庫初始化，`stationRepository` 保持 null；後續 `UpdateWidgetStationsUseCase` 呼叫靜默跳過，不崩潰

---

### Requirement: App Group 設定與 Widget Reload
系統 SHALL 透過單一 MethodChannel（`com.jerry.railwaytimetable/app_group`）處理所有 Flutter ↔ iOS 原生通訊，包含取得 App Group 路徑與觸發 Widget reload，不依賴第三方套件。

#### Scenario: iOS App target 啟用 App Group
- **WHEN** 主 App target Capabilities 設定
- **THEN** App Group `group.com.jerry.railwaytimetable.widget` 已勾選啟用

#### Scenario: Widget Extension target 啟用相同 App Group
- **WHEN** Widget Extension target Capabilities 設定
- **THEN** 使用與主 App 相同的 App Group `group.com.jerry.railwaytimetable.widget`，確保 SQLite 檔案共享

#### Scenario: refreshWidget 透過 MethodChannel 觸發 WidgetKit reload
- **WHEN** Flutter 呼叫 `WidgetDataService.refreshWidget()`
- **THEN** 系統透過 MethodChannel 呼叫 `reloadWidget`，`AppDelegate.swift` 執行 `WidgetCenter.shared.reloadTimelines(ofKind: "RailwayWidget")`，WidgetKit 排程重新載入 timeline
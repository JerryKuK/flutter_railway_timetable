## 1. Xcode 專案初始設定

- [x] 1.1 在 Xcode 新增 Widget Extension target，命名 `RailwayWidget`，language: Swift，include Configuration Intent: No
- [x] 1.2 主 App target 啟用 App Group `group.com.jerry.railwaytimetable.widget`（Signing & Capabilities）
- [x] 1.3 Widget Extension target 啟用相同 App Group `group.com.jerry.railwaytimetable.widget`
- [x] 1.4 建立本機 `ios/RailwayWidget/Secrets.xcconfig`（含真實 TDX 憑證），加入 `ios/.gitignore`
- [x] 1.6 Widget Extension target Build Settings → Configurations → 引用 `Secrets.xcconfig`
- [x] 1.7 Widget Extension `Info.plist` 新增 `TDX_CLIENT_ID = $(TDX_CLIENT_ID)` 與 `TDX_CLIENT_SECRET = $(TDX_CLIENT_SECRET)` 鍵值

## 2. Swift Domain Layer

- [x] 2.1 建立 `ios/RailwayWidget/Domain/Entity/TrainSchedule.swift`：`struct TrainSchedule` 含 `departureTime`、`arrivalTime`、`trainType`、`trainNumber`、`fare: Int`
- [x] 2.2 建立 `ios/RailwayWidget/Domain/Entity/WidgetRoute.swift`：`struct WidgetRoute` 含 `system: RailwaySystem`（enum TR/HSR）、`fromId`、`fromName`、`toId`、`toName`
- [x] 2.3 建立 `ios/RailwayWidget/Domain/Repository/TrainScheduleRepository.swift`：protocol 定義 `func getNextTrains(from:to:system:date:) async throws -> [TrainSchedule]`
- [x] 2.4 建立 `ios/RailwayWidget/Domain/UseCase/GetNextTrainsUseCase.swift`：注入 `TrainScheduleRepository`，回傳依出發時間排序的前 2 筆
- [x] 2.5 建立 `ios/RailwayWidget/Domain/Entity/PickerStation.swift`：`struct PickerStation`（`name`、`stationId`、`system`、`sortOrder`）；`PickerStationDefaults` 提供台鐵 / 高鐵各 10 站靜態預設清單，作為 SQLite 不可用時的後備
- [x] 2.6 建立 `ios/RailwayWidget/Domain/Repository/IPickerStationRepository.swift`：protocol 定義 `func getStations(system:) -> [PickerStation]`
- [x] 2.7 建立 `ios/RailwayWidget/Domain/UseCase/GetPickerStationsUseCase.swift`：注入 `IPickerStationRepository`，回傳指定系統的站台清單（供 Widget 選站 chip grid 使用）

## 3. Swift Data Layer — Auth、API Client 與資料庫

- [x] 3.1 建立 `ios/RailwayWidget/Data/Auth/TDXAuthManager.swift`：Swift `actor`，實作 `func validToken() async throws -> String`；token cache 邏輯對稱 Flutter `TdxAuthInterceptor`
- [x] 3.2 `TDXAuthManager.init()` 從 `Bundle.main.infoDictionary` 讀取 `TDX_CLIENT_ID` 與 `TDX_CLIENT_SECRET`，缺失時 `fatalError`
- [x] 3.3 建立 `ios/RailwayWidget/Data/Network/TDXAPIClient.swift`：使用 `URLSession` + `async/await`；`func fetchTRASchedule(from:to:date:token:) async throws -> [TrainSchedule]`；`func fetchHSRSchedule(from:to:date:token:) async throws -> [TrainSchedule]`
- [x] 3.4 `TDXAPIClient` 台鐵呼叫：`GET /api/basic/v3/Rail/TRA/DailyTrainTimetable/OD/{Origin}/{Destination}/{TrainDate}`，解析 JSON 回傳 `TrainSchedule` 陣列
- [x] 3.5 `TDXAPIClient` 高鐵呼叫：`GET /api/basic/v2/Rail/THSR/DailyTimetable/OD/{OriginStationID}/to/{DestinationStationID}/{TrainDate}`
- [x] 3.6 建立 `ios/RailwayWidget/Data/Repository/TrainScheduleRepositoryImpl.swift`：組合 `TDXAuthManager` + `TDXAPIClient`，實作 `TrainScheduleRepository` protocol
- [x] 3.7 建立 `ios/RailwayWidget/Data/AppGroup/AppGroupDataSource.swift`：以 `UserDefaults(suiteName: "group.com.jerry.railwaytimetable.widget")` 管理四個 key：`widget_route`（路線 JSON）、`widget_picker_mode`（"none"/"from"/"to"）、`widget_schedules`（班次快取 JSON）、`widget_last_error`（錯誤訊息字串）
- [x] 3.8 建立 `ios/RailwayWidget/Data/Database/WidgetStationDatabase.swift`：以 GRDB `DatabasePool`（WAL mode）開啟 App Group container 目錄中由 Flutter 寫入的 `widget_stations.db`
- [x] 3.9 建立 `ios/RailwayWidget/Data/Repository/PickerStationRepositoryImpl.swift`：從 SQLite 讀取 `PickerStation` 清單（依 `sort_order` 排序）；`WidgetStationDatabase` 不可用時回傳 `PickerStationDefaults` 靜態清單

## 4. Swift Presentation Layer — Widget、AppIntent 與內嵌選站

- [x] 4.1 建立 `ios/RailwayWidget/Presentation/Entry/RailwayWidgetEntry.swift`：`struct RailwayWidgetEntry: TimelineEntry`，含 `date`、`route: WidgetRoute`、`schedules: [TrainSchedule]`、`pickerMode: String`（"none"/"from"/"to"）、`lastError: String?`、`pickerStations: [PickerStation]`
- [x] 4.2 建立 `ios/RailwayWidget/RailwayWidget.swift`：`struct RailwayWidget: Widget`，`kind = "RailwayWidget"`，`supportedFamilies: [.systemMedium]`（4×2 only）
- [x] 4.3 實作 `RailwayTimelineProvider`：`func getTimeline(in:completion:)` 讀取 App Group route、picker mode、schedules、last error → 從 SQLite（或預設值）載入 `pickerStations` → 建立 entry → `completion(Timeline(entries:policy:.after(nextHour)))`
- [x] 4.4 建立 `ios/RailwayWidget/Presentation/View/MediumWidgetView.swift`：SwiftUI 4×2 view，兩種模式：**班次模式**（`pickerMode == "none"`）白底圓角卡片、漸層 icon + 系統名稱、iOS 17+ 站名為可點擊 `Button(intent: ShowPickerIntent(...))`、右上角查詢膠囊按鈕、兩列班次 row；**選站模式**（`pickerMode != "none"`，iOS 17+ only）5×2 station chip grid + 關閉按鈕
- [x] 4.5 實作「查詢」按鈕：`Button(intent: RefreshTimetableIntent())`（iOS 17+），`buttonStyle(.plain)`
- [x] 4.6 建立 `ios/RailwayWidget/Presentation/Intent/RefreshTimetableIntent.swift`：`struct RefreshTimetableIntent: AppIntent`；`perform()` 執行 `GetNextTrainsUseCase` → 成功寫入 `AppGroupDataSource.widget_schedules`（清除 `widget_last_error`）→ 失敗寫入 `widget_last_error`（清空 schedules）→ 呼叫 `WidgetCenter.shared.reloadTimelines(ofKind: "RailwayWidget")`
- [x] 4.7 實作台鐵藍（`#2E72B8`）/ 高鐵橘（`#C86820`）雙系統配色，漸層、badge、accent 顏色正確
- [x] 4.8 建立 `ios/RailwayWidget/Presentation/Intent/StationPickerIntents.swift`：三個 `AppIntent`——`ShowPickerIntent(mode:)`（寫入 picker mode → reload）、`SelectStationIntent(stationName:)`（從 SQLite 查找 stationId → 更新 `widget_route` → 清除 picker mode → reload）、`DismissPickerIntent`（清除 picker mode → reload）

## 5. Flutter — Widget 資料整合

- [x] 5.1 `pubspec.yaml` 新增 `drift: ^2.x`，執行 `flutter pub get`（不依賴 `home_widget`，Widget reload 改由 MethodChannel 處理）
- [x] 5.2 建立 `lib/features/widget_config/` 目錄結構（domain / data 分層；無 presentation layer）
- [x] 5.3 建立 `lib/features/widget_config/data/database/widget_station_database.dart`：Drift SQLite schema，`WidgetStations` table（`name`、`stationId`、`system`、`sortOrder`），WAL mode，存放於 App Group container 目錄（`widget_stations.db`）
- [x] 5.4 建立 `lib/features/widget_config/data/repository/widget_station_repository_impl.dart`：`initDefaultsIfNeeded()` 寫入台鐵 / 高鐵各 10 站預設值（與 Swift `PickerStationDefaults` 完全對應）；`setFront()` 將指定路線的出發 / 到達站移至 SQLite 清單頂端（保留總數 ≤ 10）
- [x] 5.5 建立 `lib/features/widget_config/domain/usecase/update_widget_stations_use_case.dart`：`execute()` 在資料庫就緒（已有 ≥ `maxStations` 筆站台）時呼叫 `setFront()`，所有錯誤靜默吞噬
- [x] 5.6 建立 `lib/features/widget_config/data/widget_data_service.dart`：`init()` 透過 MethodChannel `getAppGroupDir` 取得 App Group 路徑、建立 `WidgetStationDatabase`、呼叫 `initDefaultsIfNeeded()`；`refreshWidget()` 透過 MethodChannel `reloadWidget` 觸發 WidgetKit timeline reload
- [x] 5.7 `ios/Runner/AppDelegate.swift` 新增 MethodChannel `com.jerry.railwaytimetable/app_group`，處理 `getAppGroupDir` 方法：回傳 `FileManager.default.containerURL(forSecurityApplicationGroupIdentifier:)?.path`
- [x] 5.8 `lib/features/home/presentation/page/home_page.dart` 在使用者觸發時刻表導航時呼叫 `UpdateWidgetStationsUseCase.execute()`（更新 SQLite 站台排序）後呼叫 `WidgetDataService.refreshWidget()`（觸發 Widget reload）
- [x] 5.9 `lib/main.dart` 新增 `await WidgetDataService.init()` 於 `runApp` 前

## 6. 驗證與 README

- [x] 6.1 模擬器驗證：新增 Widget → 顯示預設路線（臺北→高雄 台鐵）→ 點出發站名（iOS 17+）→ 顯示選站 chip grid → 選「臺南」→ Widget 更新為臺南→高雄
- [x] 6.2 驗證查詢按鈕：點擊 Widget 右上角「查詢」→ `RefreshTimetableIntent` 觸發 → 班次資料更新
- [x] 6.3 驗證 home page 自動同步：在首頁搜尋「板橋→臺中 台鐵」→ Widget SQLite 站台清單中板橋 / 臺中移至頂端（可透過後續 Widget 選站 chip 驗證）
- [x] 6.4 `README.md` 新增「Widget Extension 本地設定」區段：手動建立 `Secrets.xcconfig`、填入 TDX 憑證、Xcode 設定步驟
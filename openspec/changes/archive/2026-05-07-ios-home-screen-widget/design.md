## Context

專案已有 Flutter Clean Architecture 實作：TDX API（Retrofit + Dio）→ Repository → BLoC → UI。iOS Widget Extension 是獨立的 App Extension process，無法直接使用 Flutter runtime，需在 Swift 側平行建構一套精簡的 Clean Architecture，並透過 App Group UserDefaults 與主 App 共享路線設定資料。

設計稿（`Home Screen Widgets.html`）定義了 4×2 Medium widget 的像素精確外觀：白底圓角卡片、台鐵藍 / 高鐵橘雙系統配色、兩列班次 row、右上角「查詢」膠囊按鈕。

## Goals / Non-Goals

**Goals:**
- 實作 iOS 4×2 Medium widget，視覺 100% 還原設計稿
- 查詢按鈕使用 `AppIntent`，在 Extension process 直接打 TDX API，不啟動主 App
- iOS 17+ 支援 Widget 內嵌選站：點擊站名顯示 chip grid，透過 `AppIntent` 直接更改路線，無需開啟 App
- Swift 側採三層 Clean Architecture（Domain / Data / Presentation），邏輯與 Flutter 端對稱
- TDX 憑證以 `.xcconfig` + `Info.plist` 注入，不入版控
- Flutter App 以共享 SQLite（App Group 目錄）維護選站清單；使用者在首頁搜尋時自動同步最近使用站台至清單頂端

**Non-Goals:**
- 4×4 Large widget（proposal 已排除）
- Android widget
- 獨立的 Flutter `/widget-config` 設定頁（路線設定改由 Widget 內嵌選站完成）
- 離線快取 / 班次資料本地 DB（Widget 每次查詢直接打 API）

## Decisions

### D1：查詢按鈕使用 AppIntent 而非 widgetURL deep link
**選擇**：`AppIntent`（iOS 16+）`RefreshTimetableIntent` 直接在 Extension process 執行 URLSession 打 TDX API。

**替代方案**：`widgetURL` 跳轉主 App → App 打 API → `home_widget` 回寫 → reload。

**理由**：AppIntent 方案使用者不需開啟 App 即可更新班次，體驗更佳；Widget Extension process 本身能存取 App Group secrets，不需跨 process 溝通。

### D2：Swift TDX 憑證以 .xcconfig + Info.plist 橋接
**選擇**：`ios/WidgetExtension/Secrets.xcconfig`（gitignored）→ Widget target Build Settings `USER_DEFINED` 變數 → `Info.plist` 鍵值 `$(TDX_CLIENT_ID)` → `Bundle.main.infoDictionary["TDX_CLIENT_ID"]`。

**替代方案**：hardcode / 環境變數 Script Phase 產生 Swift 常數（類似 Flutter envied）。

**理由**：.xcconfig 是 Xcode 原生支援的標準做法，不需額外 build script，與 Flutter `.env` 模式保持對稱（兩者都 gitignored，都提供 `.example` 範本）。

### D3：Swift Clean Architecture 三層分離
**選擇**：
```
ios/RailwayWidget/
├── Domain/
│   ├── Entity/TrainSchedule.swift        # 值型別 struct
│   ├── Repository/TrainScheduleRepository.swift  # protocol
│   └── UseCase/GetNextTrainsUseCase.swift
├── Data/
│   ├── Network/TDXAPIClient.swift        # URLSession + async/await
│   ├── Auth/TDXAuthManager.swift         # token cache（actor）
│   └── Repository/TrainScheduleRepositoryImpl.swift
└── Presentation/
    ├── Widget/RailwayWidget.swift         # @main, TimelineProvider
    ├── View/MediumWidgetView.swift        # SwiftUI 4×2 view
    ├── Intent/RefreshTimetableIntent.swift # AppIntent
    └── Entry/RailwayWidgetEntry.swift     # TimelineEntry
```

**替代方案**：全部塞在單一 Swift 檔案（簡單但不可測試）。

**理由**：與 Flutter Clean Architecture 對稱，`Domain` layer 可單元測試，`Data` layer 可 mock；長期維護成本低。

### D4：App Group 資料格式
**選擇**：App Group UserDefaults 管理四個 key：

| Key | 型態 | 說明 |
|-----|------|------|
| `widget_route` | JSON String | 目前顯示路線 `{ "system": "TR"\|"HSR", "fromId", "fromName", "toId", "toName" }` |
| `widget_picker_mode` | String | `"none"` / `"from"` / `"to"`，控制 Widget 是否顯示選站 UI |
| `widget_schedules` | Data (JSON Array) | `RefreshTimetableIntent` 寫入的班次快取，`TimelineProvider` 讀取後直接呈現，無需再次打 API |
| `widget_last_error` | String? | API / 認證失敗的錯誤碼，nil 表示無錯誤 |

**理由**：UserDefaults 適合少量狀態資料；`widget_schedules` 快取讓 `TimelineProvider` 同步讀取不需 async，`RefreshTimetableIntent` 負責非同步更新。

### D5：TimelineProvider 更新策略
**選擇**：`TimelineReloadPolicy.after(nextHour)` + 每小時一個 entry；查詢按鈕 `RefreshTimetableIntent` 執行後呼叫 `WidgetCenter.shared.reloadTimelines(ofKind:)`。`TimelineProvider` 直接讀取 `widget_schedules` 快取，不發 API 請求。

**理由**：避免每次 `getTimeline` 都打 API（WidgetKit 呼叫頻率不可控）；明確分離「顯示」（TimelineProvider 同步讀快取）與「更新」（AppIntent 非同步打 API）兩條路徑。

### D6：iOS 17+ 內嵌選站，iOS 16 靜態顯示
**選擇**：站名文字在 iOS 17+ 改為 `Button(intent: ShowPickerIntent(...))`，觸發 `widget_picker_mode` 切換，Widget 顯示 5×2 chip grid；iOS 16 站名為純文字，不可互動。

**替代方案**：`widgetURL` deep link 跳轉主 App 設定頁（spec 原始設計）。

**理由**：`Button(intent:)` 是 iOS 17 引入的 WidgetKit API，使用者不需開啟 App 即可選站，體驗大幅優於 deep link 方案。iOS 16 使用者初始路線為預設值（臺北→高雄 台鐵），可透過 Widget 鎖定後設定。

### D7：選站清單以共享 SQLite 管理
**選擇**：Flutter 以 Drift 寫入 `widget_stations.db`（存放於 App Group container 目錄）；Swift 以 GRDB `DatabasePool`（WAL mode）讀取同一個 DB 檔案。Flutter App 在使用者搜尋時將搜尋路線的站台移至清單頂端（`setFront()`）。

**替代方案**：UserDefaults 存 JSON 陣列（spec 原始設計）。

**理由**：SQLite WAL mode 允許 Flutter（寫）與 Widget Extension process（讀）並行存取；`sort_order` 欄位讓「最近搜尋站台優先顯示」的邏輯易於維護；DB schema 由 Drift 管理版本，升級安全。Flutter 與 Swift 端的預設站台清單（`PickerStationDefaults` / `_trDefaults`）必須保持一致，變更時需雙側同步更新。

## Risks / Trade-offs

- **[Risk] AppIntent / Button(intent:) 最低 iOS 17**  
  → `Button(intent:)` 是 iOS 17 新增 API；iOS 16 使用者站名顯示為純文字，無法互動選站，只能用查詢按鈕刷新班次。若需支援 iOS 16 選站，需額外實作 `widgetURL` deep link fallback。

- **[Risk] TDX API 在 Widget Extension context 的網路限制**  
  → Widget Extension 有 background execution 限制；`URLSession` 僅在 `RefreshTimetableIntent.perform()` 中呼叫（使用者主動觸發），`TimelineProvider` 不發網路請求，改為讀取 `widget_schedules` 快取。

- **[Risk] .xcconfig 忘記設定的 developer**  
  → 提供 `Secrets.xcconfig.example` 並在 `README.md` 加入設定指引；Xcode build 時若 key 缺失，`fatalError` 明確告知。

- **[Known IDE issue] SourceKit 在 `StationPickerIntents.swift` 顯示假警報**  
  → Xcode 16 的 `PBXFileSystemSynchronizedRootGroup` 讓 Widget Extension 自動包含 `RailwayWidget/` 下所有檔案，但 SourceKit IDE extension 尚未完整支援此機制，導致跨檔案符號（`AppGroupDataSource`、`WidgetRoute` 等）無法解析。實際 **xcodebuild 編譯不受影響**，忽略 IDE 錯誤即可。

- **[Risk] Flutter / Swift 預設站台清單不同步**  
  → `PickerStationDefaults`（Swift）與 `_trDefaults` / `_hsrDefaults`（Dart）必須完全一致，否則 `initDefaultsIfNeeded()` 初始化的資料和 Swift fallback 不符。已在 `widget_station_repository_impl.dart` 加入注釋提示同步需求。

- **[Trade-off] Swift 端 TDX Auth 與 Flutter 端各自維護**  
  → Token cache 邏輯重複（`TDXAuthManager` vs `TdxAuthInterceptor`），但 Extension process 無法共用 Flutter DI container，可接受。

## Migration Plan

1. Xcode 新增 Widget Extension target（`RailwayWidget`），建立 App Group，主 App + Widget target 均啟用
2. 建立 `Secrets.xcconfig`（本地），加入 `.gitignore`
3. 實作 Swift Domain Layer（`TrainSchedule`、`WidgetRoute`、`PickerStation` 等 entity 與 protocol）
4. 實作 Swift Data Layer（`TDXAuthManager`、`TDXAPIClient`、`AppGroupDataSource`、`WidgetStationDatabase`）
5. 實作 Swift Presentation Layer（`RailwayWidget`、`MediumWidgetView`、`RefreshTimetableIntent`、`StationPickerIntents`）
6. Flutter 側加入 `home_widget` + `drift`，建立 `WidgetStationDatabase`（Dart）、`WidgetDataService`；在 `AppDelegate.swift` 加入 MethodChannel
7. Flutter `home_page.dart` 整合 `UpdateWidgetStationsUseCase` + `WidgetDataService.refreshWidget()`
8. 在模擬器 / 實機驗證：首頁搜尋 → Widget SQLite 站台更新 → Widget 內嵌選站 → `RefreshTimetableIntent` 刷新班次

**Rollback**：Widget Extension 為獨立 target，移除 target 不影響主 App 功能；Drift SQLite 位於 App Group 目錄，移除後不影響主 App 資料庫。

## Open Questions

- TDX 車站 ID 對應表（台鐵 `fromId` 要用 StationID 如 `1000` 還是站名字串）？目前 Flutter 側使用 `stationId`（String），Swift 側同步使用。
- App Group bundle ID 需在 Apple Developer Portal 建立，確認 `group.com.jerry.railwaytimetable.widget` 可用。
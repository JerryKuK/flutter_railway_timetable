## Why

iOS 台鐵與高鐵桌面小工具的 footer「更新於 HH:mm」目前綁定在 `TimelineEntry.date` 上，只要 `WidgetCenter.reloadTimelines` 被觸發（picker show / dismiss / select 都會），時間就被刷新——但 schedules 並未重抓。使用者看到時間動了卻拿到舊資料，是錯誤的「資料新鮮度」訊號，且容易誤判 widget 已更新。Android 端早已用獨立的 `widget_last_update` SharedPreferences key 解決（只有成功 refresh 才寫入），iOS 需鏡像同一設計以對齊行為與消除信任缺口。

## What Changes

- 新增「最後一次成功 fetch 時間戳記」獨立持久化欄位（App Group UserDefaults key `tr_widget_last_update` / `hsr_widget_last_update`，String 格式 `"HH:mm"`、台北時區）。
- `RefreshTimetableIntent` / `HSRRefreshTimetableIntent` 在 API 成功時以原子 batch 寫入 route + schedules + lastUpdate + 清除 lastError；失敗時只寫 schedules 空 + lastError，**不動 lastUpdate**。
- Picker 系列 intents（`ShowPickerIntent` / `DismissPickerIntent` / `SelectStationIntent` 及 HSR 對應）**完全不動 lastUpdate**。
- `RailwayWidgetEntry` 新增 `lastUpdate: String?` 欄位（沿用同 struct 既有 `lastError: String?` 的 `nil` sentinel 慣例）；timeline provider 從持久層讀取後塞入 entry。
- `MediumWidgetView` footer 改以 `entry.lastUpdate` 為顯示來源；`nil` 時整段「更新於 …」元素不渲染，採 `if let lastUpdate = entry.lastUpdate` 解包（語意鏡像 Android `if (lastUpdate.isNotEmpty())`，編碼因 Swift Optional 慣例調整）。
- 新增 `TaipeiClock` Swift helper 對應 Android `TaipeiClock.nowTime()`，產生 Asia/Taipei 時區的 `"HH:mm"` 字串；同步擴充 `TaipeiClock.todayDate(_ date:)` 產生 `"yyyy-MM-dd"` 字串，取代 refresh intent 與 `GetNextTrainsUseCase` 內三處重複的 `DateFormatter` extension（純 DRY 收斂，行為等價）。
- Swift 測試補強：`AppGroupDataSourceTests` 新增 lastUpdate / batch 方法相關案例；refresh intent 測試（如有）覆蓋成功/失敗對 lastUpdate 的副作用差異。
- 既有使用者升級後初次開 widget 會看到「更新於」消失（`loadLastUpdate()` 回 `nil`，因升級前並未寫入過此 key），按一次查詢即恢復——**無資料遷移需求**。

## Capabilities

### New Capabilities

（無）

### Modified Capabilities

- `ios-widget-extension`: 在「AppIntent 查詢按鈕即時刷新」與「Widget 內嵌選站器」requirements 補強——明確規範 footer 更新時間的觸發來源僅限「成功的 API fetch」，picker 操作與失敗 refresh 都不得改變 footer 顯示時間；初次安裝（無歷史成功 fetch）時 footer 不顯示「更新於」字樣。
- `ios-hsr-widget`: 與台鐵相同的需求調整，套用於 `HSRRefreshTimetableIntent` 與 HSR picker 系列 intents；`hsr_widget_last_update` key 與 `tr_widget_last_update` 完全隔離。

## Impact

- **iOS 程式碼**：
  - `ios/RailwayWidget/Data/AppGroup/AppGroupDataSource.swift`（新增 `saveLastUpdate` / `loadLastUpdate` / `saveRefreshResult` / `saveRefreshError`）
  - `ios/RailwayWidget/Presentation/Entry/RailwayWidgetEntry.swift`（新增 `lastUpdate: String?` 欄位）
  - `ios/RailwayWidget/RailwayWidget.swift`、`HSRWidget.swift`（timeline provider 讀取 lastUpdate）
  - `ios/RailwayWidget/Presentation/Intent/RefreshTimetableIntent.swift`、`HSRRefreshTimetableIntent.swift`（改用 batch 寫入）
  - `ios/RailwayWidget/Presentation/View/MediumWidgetView.swift:147` footer 顯示邏輯
  - 新增 `ios/RailwayWidget/Data/Util/TaipeiClock.swift`（或對應 Domain util 路徑）
  - `ios/RailwayWidget/Domain/UseCase/GetNextTrainsUseCase.swift`（移除 `private DateFormatter.yyyyMMddTaipei` extension、`nowString` 與 `tomorrowStr` 改呼叫 `TaipeiClock`）
- **iOS 測試**：`ios/RailwayWidgetTests/AppGroupDataSourceTests.swift` 與 refresh intent 相關測試。
- **App Group UserDefaults**：新增兩支 key（`tr_widget_last_update`、`hsr_widget_last_update`），既有 key 不變動、不刪除。
- **平台範圍**：僅 iOS。Android（`WidgetPrefs.kt`、`RefreshWidgetAction.kt`、`WidgetComposables.kt`）已是參考實作，不修改。
- **使用者可見變化**：初次升級的既有使用者 footer 會少一行「更新於」直到下次查詢；其餘使用者體驗無回歸風險。
- **無 BREAKING change**：對外 API、widget kind、displayName 與 supportedFamilies 維持不變。
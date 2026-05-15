## ADDED Requirements

### Requirement: 高鐵 Widget Footer 更新時間獨立持久化

高鐵 widget footer 顯示的「更新於 HH:mm」時間 SHALL 來自 App Group UserDefaults `hsr_widget_last_update` 字串值，與 `TimelineEntry.date` 完全脫鉤。此 key MUST 僅由 `HSRRefreshTimetableIntent` 在 TDX HSR API 成功取得班次後寫入；任何 HSR picker 系列 intent（`HSRShowPickerIntent` / `HSRDismissPickerIntent` / `HSRSelectStationIntent`）與 timeline 自動更新失敗路徑 MUST NOT 寫入或修改此 key。字串格式 SHALL 為 `"HH:mm"`，時區 SHALL 為 `Asia/Taipei`。`hsr_widget_last_update` 與 `tr_widget_last_update` 完全隔離、互不影響。

#### Scenario: 成功 refresh 才更新 HSR footer 時間

- **WHEN** `HSRRefreshTimetableIntent.perform()` 成功從 TDX HSR API 取得班次並寫入 `hsr_widget_schedules`
- **THEN** 系統以 Asia/Taipei 時區產生當下 `"HH:mm"` 字串，與 route + schedules + 清除 `hsr_widget_last_error` 一併原子寫入 App Group UserDefaults，`hsr_widget_last_update` key 被更新為新值；`tr_widget_last_update` 不受影響

#### Scenario: HSR Refresh 失敗時 footer 時間維持不變

- **WHEN** `HSRRefreshTimetableIntent.perform()` 因 API 失敗、網路錯誤或例外將錯誤訊息寫入 `hsr_widget_last_error`
- **THEN** `hsr_widget_last_update` 維持失敗前的值不變；widget footer 顯示的「更新於」仍為上一次成功 refresh 的時間

#### Scenario: HSR Picker 操作不改變 footer 時間

- **WHEN** 使用者觸發任一 HSR picker 系列 intent（`HSRShowPickerIntent` / `HSRDismissPickerIntent` / `HSRSelectStationIntent`），導致 `WidgetCenter.shared.reloadTimelines(ofKind: "HSRWidget")` 被呼叫
- **THEN** `hsr_widget_last_update` 完全不被讀寫，`HSRRailwayTimelineProvider` 重新生成 entry 時讀回的值與操作前相同；widget footer 顯示的「更新於」時間維持不變

#### Scenario: 從未成功 refresh 時 HSR footer 不渲染更新時間

- **WHEN** 使用者首次將「高鐵時刻表」widget 拉到桌面，且 `hsr_widget_last_update` 在 App Group UserDefaults 不存在（`loadLastUpdate()` 回傳 `nil`）
- **THEN** Widget footer 中「更新於 …」`Text` 元素整段不渲染，僅顯示右側「查看更多 →」連結；不顯示任何 placeholder 字樣

#### Scenario: TR 與 HSR widget lastUpdate 完全隔離

- **WHEN** 使用者按下高鐵 widget 的「查詢」按鈕成功後，`hsr_widget_last_update` 被更新為新值
- **THEN** `tr_widget_last_update` 不受影響；台鐵 widget footer 顯示的「更新於」時間不變動

---

### Requirement: 高鐵 Widget Entry 攜帶 lastUpdate 欄位

`RailwayWidgetEntry`（高鐵與台鐵共用同一型別） SHALL 包含 `lastUpdate: String?` 欄位以供 view 顯示（與同 struct 既有 `lastError: String?` 採相同 `nil` sentinel 慣例）；`HSRRailwayTimelineProvider.getTimeline` MUST 從 `AppGroupDataSource(system: .hsr).loadLastUpdate()` 讀取後填入 entry，**不得**使用 `entry.date` 或 `Date()` 推導此欄位。

#### Scenario: HSRTimelineProvider 從持久層讀取 lastUpdate 並填入 entry

- **WHEN** iOS 系統呼叫 `HSRRailwayTimelineProvider.getTimeline(in:context:completion:)`
- **THEN** Provider 呼叫 `AppGroupDataSource(system: .hsr).loadLastUpdate()` 取得 `String?`（不存在時為 `nil`），將其作為 `lastUpdate` 欄位傳入新建立的 `RailwayWidgetEntry`；`entry.date` 仍維持 `Date()` 作為 WidgetKit 排程訊號使用

#### Scenario: HSR Placeholder entry 預設 lastUpdate 為 nil

- **WHEN** WidgetKit 呼叫 `placeholder(in:)` 或 `getSnapshot(in:completion:)` 取得 HSR widget 的 placeholder entry
- **THEN** `RailwayWidgetEntry.hsrPlaceholder.lastUpdate` 為 `nil`；對應 widget gallery 預覽顯示時 footer 不渲染「更新於」字樣

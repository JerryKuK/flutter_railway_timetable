## ADDED Requirements

### Requirement: 台鐵 Widget Footer 更新時間獨立持久化

台鐵 widget footer 顯示的「更新於 HH:mm」時間 SHALL 來自 App Group UserDefaults `tr_widget_last_update` 字串值，與 `TimelineEntry.date` 完全脫鉤。此 key MUST 僅由 `RefreshTimetableIntent` 在 TDX API 成功取得班次後寫入；任何 picker 系列 intent（show / dismiss / select）與 timeline 自動更新失敗路徑 MUST NOT 寫入或修改此 key。字串格式 SHALL 為 `"HH:mm"`，時區 SHALL 為 `Asia/Taipei`。

#### Scenario: 成功 refresh 才更新 footer 時間

- **WHEN** `RefreshTimetableIntent.perform()` 成功從 TDX API 取得班次並寫入 `tr_widget_schedules`
- **THEN** 系統以 Asia/Taipei 時區產生當下 `"HH:mm"` 字串，與 route + schedules + 清除 `tr_widget_last_error` 一併原子寫入 App Group UserDefaults，`tr_widget_last_update` key 被更新為新值

#### Scenario: Refresh 失敗時 footer 時間維持不變

- **WHEN** `RefreshTimetableIntent.perform()` 因 API 失敗、網路錯誤或例外將錯誤訊息寫入 `tr_widget_last_error`
- **THEN** `tr_widget_last_update` 維持失敗前的值不變；widget footer 顯示的「更新於」仍為上一次成功 refresh 的時間

#### Scenario: Picker 操作不改變 footer 時間

- **WHEN** 使用者觸發任一 picker 系列 intent（`ShowPickerIntent` / `DismissPickerIntent` / `SelectStationIntent`），導致 `WidgetCenter.shared.reloadTimelines(ofKind: "RailwayWidget")` 被呼叫
- **THEN** `tr_widget_last_update` 完全不被讀寫，TimelineProvider 重新生成 entry 時讀回的值與操作前相同；widget footer 顯示的「更新於」時間維持不變

#### Scenario: 從未成功 refresh 時 footer 不渲染更新時間

- **WHEN** 使用者首次將「台鐵時刻表」widget 拉到桌面，且 `tr_widget_last_update` 在 App Group UserDefaults 不存在（`loadLastUpdate()` 回傳 `nil`）
- **THEN** Widget footer 中「更新於 …」`Text` 元素整段不渲染，僅顯示右側「查看更多 →」連結；不顯示任何 placeholder 字樣（如「—」或「尚未查詢」）

#### Scenario: 既有使用者升級後初次顯示

- **WHEN** 既有使用者從未含本 change 的版本升級安裝後，App Group UserDefaults 中 `tr_widget_last_update` 不存在（既有版本未寫入過此 key）
- **THEN** Widget footer 不顯示「更新於」字樣；使用者點擊一次「查詢」按鈕成功後即恢復顯示

---

### Requirement: 台鐵 Widget Entry 攜帶 lastUpdate 欄位

`RailwayWidgetEntry` SHALL 包含 `lastUpdate: String?` 欄位以供 view 顯示（與同 struct 既有 `lastError: String?` 採相同 `nil` sentinel 慣例）；`RailwayTimelineProvider.getTimeline` MUST 從 `AppGroupDataSource(system: .tr).loadLastUpdate()` 讀取後填入 entry，**不得**使用 `entry.date` 或 `Date()` 推導此欄位。

#### Scenario: TimelineProvider 從持久層讀取 lastUpdate 並填入 entry

- **WHEN** iOS 系統呼叫 `RailwayTimelineProvider.getTimeline(in:context:completion:)`
- **THEN** Provider 呼叫 `AppGroupDataSource(system: .tr).loadLastUpdate()` 取得 `String?`（不存在時為 `nil`），將其作為 `lastUpdate` 欄位傳入新建立的 `RailwayWidgetEntry`；`entry.date` 仍維持 `Date()` 作為 WidgetKit 排程訊號使用，但 view 不再讀取此欄位顯示時間

#### Scenario: MediumWidgetView footer 顯示來源

- **WHEN** `MediumWidgetView` 渲染 footer
- **THEN** footer 「更新於 HH:mm」`Text` 的字串內容來自 `entry.lastUpdate`，**不得**參考 `entry.date`；當 `entry.lastUpdate == nil`，整段「更新於」`Text` 不渲染（含其前綴「更新於」字樣與時間值），實作 SHOULD 採 `if let lastUpdate = entry.lastUpdate { ... }` 形式解包

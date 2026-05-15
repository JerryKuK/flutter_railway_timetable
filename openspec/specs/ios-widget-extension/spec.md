## Purpose

iOS 4×2 Medium 桌面小工具（kind `"RailwayWidget"`）的視覺渲染、AppIntent 互動、Timeline 自動更新與站台選擇器之需求集合。本 capability 僅涵蓋台鐵（TR）系統；高鐵專屬 widget 詳見 `ios-hsr-widget` capability。RailwayWidget Extension target 的 `IPHONEOS_DEPLOYMENT_TARGET` 為 `17.0`，故不含 iOS 16 fallback 路徑。
## Requirements
### Requirement: 4×2 Medium Widget 視覺渲染
系統 SHALL 在 iOS 主畫面顯示 4×2 Medium 尺寸的「台鐵時刻表」widget（kind = `"RailwayWidget"`），外觀依照設計稿 `Home Screen Widgets.html` 像素精確還原；本 widget 僅渲染台鐵（TR）配色與內容，不再支援高鐵切換。

#### Scenario: 台鐵 widget 顯示班次
- **WHEN** App Group UserDefaults `tr_widget_route` 設定為台鐵路線（system = "TR"）且 timeline 有效
- **THEN** Widget 顯示白底圓角（r=22）卡片；header 左側台鐵藍漸層圓圈（#5FA6E0→#2E72B8）+ 「台鐵」字樣 + 出發→到達站名；右上角顯示台鐵藍「查詢」膠囊按鈕；下方兩列班次（出發時間、車種 badge、車號、到站時間）

#### Scenario: 路線未設定時顯示預設路線
- **WHEN** App Group UserDefaults `tr_widget_route` 不存在或無法解析
- **THEN** Widget 使用預設路線（`臺北 → 高雄` 台鐵）顯示，並提示「點右上角查詢取得班次」

#### Scenario: 舊使用者 widget_route.system == HSR 自動 fallback
- **WHEN** 既有舊使用者升級後 `tr_widget_route` 不存在（因為新版本不再讀 `widget_route` 舊 key），且舊 `widget_route` 內容為 HSR 路線
- **THEN** TR widget 不 crash，timeline provider 直接 fallback 到預設 `臺北 → 高雄` 並顯示「點右上角查詢取得班次」提示；既有舊 `widget_route` 等 key 保留在 UserDefaults 中但不被讀取

#### Scenario: 尚無班次資料時顯示提示
- **WHEN** `tr_widget_schedules` 為空且 `tr_widget_last_error` 為 nil
- **THEN** Widget 顯示「點右上角查詢取得班次」提示文字，不顯示班次列

#### Scenario: API 失敗顯示錯誤訊息
- **WHEN** TDX API 請求失敗（非 2xx 或逾時）且 `tr_widget_last_error` 已寫入錯誤訊息
- **THEN** Widget 顯示「無法取得班次，請點查詢重試」，查詢按鈕仍可點擊

---

### Requirement: AppIntent 查詢按鈕即時刷新
台鐵 widget 右上角「查詢」按鈕 SHALL 使用 `RefreshTimetableIntent`，在 Widget Extension process 直接呼叫 TDX API 並重新整理 `"RailwayWidget"` timeline，不啟動主 App；intent 讀寫 `tr_widget_*` 系列 App Group key。

#### Scenario: 點擊查詢按鈕觸發 AppIntent
- **WHEN** 使用者點擊台鐵 widget 右上角「查詢」膠囊按鈕
- **THEN** 系統執行 `RefreshTimetableIntent.perform()`，於 Extension process 以 `AppGroupDataSource(system: .tr)` 讀取 `tr_widget_route`，呼叫 `TDXAPIClient` 取得最新班次，將結果寫入 `tr_widget_schedules`，並呼叫 `WidgetCenter.shared.reloadTimelines(ofKind: "RailwayWidget")`

#### Scenario: AppIntent 更新後 widget 顯示新班次
- **WHEN** `RefreshTimetableIntent` 成功取得新班次資料
- **THEN** Widget timeline 重新整理，UI 更新為最新班次，footer 顯示最新更新時間

#### Scenario: AppIntent 失敗不崩潰
- **WHEN** `RefreshTimetableIntent.perform()` 拋出例外（API 失敗、網路錯誤）
- **THEN** Intent 將錯誤訊息寫入 `tr_widget_last_error`，回傳 `.failure` result，Widget 顯示錯誤狀態，不崩潰

---

### Requirement: Timeline 自動更新策略
Widget TimelineProvider SHALL 依固定策略自動請求 TDX API 並建立 timeline entries。

#### Scenario: Timeline 到期自動重新整理
- **WHEN** 目前 timeline 的最後一個 entry 到期（`atEnd` policy）
- **THEN** 系統呼叫 `TimelineProvider.getTimeline`，打 TDX API 取得最新班次，建立未來 1 小時的 entries

#### Scenario: Timeline entries 每小時一筆
- **WHEN** `getTimeline` 成功取得班次
- **THEN** 產生至少 1 筆 entry，日期為當下，下次更新時間設為 1 小時後

---

### Requirement: Widget 內嵌選站器（iOS 17+）
台鐵 widget 上的出發站 / 到達站名稱 SHALL 為可點擊 `Button(intent:)`，點擊後在 Widget 同一 4×2 空間顯示選站 chip grid；intent 讀寫 `tr_widget_*` 系列 key；picker 僅顯示台鐵車站。（`RailwayWidgetExtension` 之 `IPHONEOS_DEPLOYMENT_TARGET` 為 `17.0`，故無 iOS 16 fallback 路徑；header 保留「（iOS 17+）」字眼作為跨 capability 的版本對齊提示。）

#### Scenario: 點擊出發站名稱開啟選站 grid
- **WHEN** 使用者點擊台鐵 widget 上帶底線的出發站名稱
- **THEN** 系統執行 `ShowPickerIntent(mode: "from")`，將 `"from"` 寫入 `tr_widget_picker_mode`，呼叫 `reloadTimelines(ofKind: "RailwayWidget")`；Widget 切換至選站模式，顯示台鐵對應 system 的最多 10 個站台 chip；標題顯示「選擇出發站」，footer 顯示目前到達站名稱

#### Scenario: 點擊到達站名稱開啟選站 grid
- **WHEN** 使用者點擊台鐵 widget 上帶底線的到達站名稱
- **THEN** 系統執行 `ShowPickerIntent(mode: "to")`，Widget 切換至選站模式；標題顯示「選擇到達站」，footer 顯示目前出發站名稱

#### Scenario: 選擇站台更新路線
- **WHEN** 使用者在台鐵選站 grid 點擊任一站台 chip
- **THEN** 系統執行 `SelectStationIntent(stationName:stationId:)`，從 SQLite 查找 stationId（找不到時使用靜態對照表），更新 `tr_widget_route` UserDefaults，清除 `tr_widget_picker_mode`，呼叫 `reloadTimelines(ofKind: "RailwayWidget")`；Widget 返回班次模式並顯示新路線

#### Scenario: 關閉選站 grid 不變更路線
- **WHEN** 使用者點擊選站 grid 右上角「×」按鈕
- **THEN** 系統執行 `DismissPickerIntent`，清除 `tr_widget_picker_mode`，Widget 返回班次模式，路線維持不變

### Requirement: Swift Domain Layer — TrainSchedule entity 與 Repository protocol
Domain layer SHALL 定義 `TrainSchedule` value type 與 `TrainScheduleRepository` protocol，不依賴任何 Foundation 以外的框架。

#### Scenario: TrainSchedule 包含必要欄位
- **WHEN** Data layer 建立 `TrainSchedule` 實例
- **THEN** 實例包含：`departureTime`（String HH:mm）、`arrivalTime`（String HH:mm）、`trainType`（String）、`trainNumber`（String）、`fare`（Int，NT$，0 若不可用）

#### Scenario: GetNextTrainsUseCase 回傳最近兩班
- **WHEN** 呼叫 `GetNextTrainsUseCase.execute(from:to:system:date:)`
- **THEN** Repository 回傳的班次列表依出發時間排序，use case 回傳前 2 筆；若不足 2 筆則回傳全部

---

### Requirement: Swift Data Layer — TDXAuthManager token 快取
`TDXAuthManager` SHALL 使用 Swift actor 管理 TDX OAuth2 token 快取，邏輯與 Flutter `TdxAuthInterceptor` 對稱。

#### Scenario: Token 不存在或過期時取得新 Token
- **WHEN** 呼叫 `TDXAuthManager.validToken()` 且 token 不存在或已過期
- **THEN** 向 `https://tdx.transportdata.tw/auth/realms/TDXConnect/protocol/openid-connect/token` 發送 `client_credentials` POST，快取回傳的 access_token 及到期時間（expires_in - 60 秒）

#### Scenario: Token 有效時直接回傳快取
- **WHEN** 呼叫 `TDXAuthManager.validToken()` 且 token 尚未過期
- **THEN** 直接回傳快取 token，不發出新 HTTP 請求

#### Scenario: 憑證從 Bundle 讀取
- **WHEN** `TDXAuthManager` 初始化
- **THEN** `clientId` 與 `clientSecret` 從 `Bundle.main.infoDictionary["TDX_CLIENT_ID"]` 與 `["TDX_CLIENT_SECRET"]` 讀取；若 key 不存在則 `fatalError("Missing TDX credentials in Info.plist")`

---

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


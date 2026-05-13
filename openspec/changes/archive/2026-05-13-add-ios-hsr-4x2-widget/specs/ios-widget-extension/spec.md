## Purpose

iOS 4×2 Medium 桌面小工具（kind `"RailwayWidget"`）的視覺渲染、AppIntent 互動、Timeline 自動更新與站台選擇器之需求集合。本 capability 僅涵蓋台鐵（TR）系統；高鐵專屬 widget 詳見 `ios-hsr-widget` capability。RailwayWidget Extension target 的 `IPHONEOS_DEPLOYMENT_TARGET` 為 `17.0`，故不含 iOS 16 fallback 路徑。

## MODIFIED Requirements

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


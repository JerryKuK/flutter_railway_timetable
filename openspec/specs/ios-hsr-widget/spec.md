# ios-hsr-widget Specification

## Purpose

iOS 4×2 Medium 高鐵專屬桌面小工具（kind `"HSRWidget"`）的視覺渲染、AppIntent 互動、Timeline 自動更新與全 12 站固定 N→S 選站器之需求集合。本 capability 與 `ios-widget-extension`（台鐵）平行存在，共用同一個 `RailwayWidgetExtension` target 與 App Group ID，但所有狀態以 `hsr_widget_*` key prefix 完全隔離。RailwayWidget Extension target 的 `IPHONEOS_DEPLOYMENT_TARGET` 為 `17.0`。

## Requirements
### Requirement: HSR 4×2 Medium Widget 視覺渲染
系統 SHALL 在 iOS 主畫面顯示獨立的 4×2 Medium 尺寸「高鐵時刻表」widget（kind = `"HSRWidget"`、displayName `"高鐵時刻表"`、description `"顯示台灣高鐵下班車資訊"`、supportedFamilies `[.systemMedium]`），與既有台鐵 widget 平行存在；外觀依設計檔 `Home Screen Widgets.html` 的 `IOSMedium` + `W_PAL.HSR` 像素還原。

#### Scenario: HSR widget 顯示班次
- **WHEN** App Group UserDefaults `hsr_widget_route` 設定為高鐵路線且 `hsr_widget_schedules` 有資料
- **THEN** Widget 顯示白底圓角（r=22）卡片；header 左側高鐵橘漸層圓圈（`linear-gradient(155deg, #F2A85C 0%, #C86820 100%)`）+ 「高鐵」字樣 + 出發→到達站名（accent 色 `#C86820`，含 accent 色底線、可點擊）；右上角顯示日期 + 高鐵橘「查詢」膠囊按鈕（bg `#C868201A`、border `#C8682033`、文字 `#C86820`）；下方兩列班次（出發時間 18pt 粗體 mono、車種 badge 灰底、車號、到站時間）；footer 顯示「更新於 HH:mm」與 accent `#C86820` 的「查看更多 →」

#### Scenario: HSR widget 首次安裝顯示預設路線
- **WHEN** 使用者第一次將「高鐵時刻表」widget 拉到桌面，且 App Group `hsr_widget_route` 不存在
- **THEN** Widget timeline provider fallback 至預設路線 `WidgetRoute(system: .hsr, fromName: "臺北", toName: "左營")`，顯示「點右上角查詢取得班次」提示直到使用者首次查詢

#### Scenario: HSR widget 與台鐵 widget 狀態完全隔離
- **WHEN** 使用者在高鐵 widget 修改路線（例如改成 `板橋 → 台中`）
- **THEN** 僅 `hsr_widget_route` 被更新；既有 `tr_widget_route` 不受影響；台鐵 widget 顯示內容維持不變

#### Scenario: 尚無班次資料時顯示提示
- **WHEN** `hsr_widget_schedules` 為空且 `hsr_widget_last_error` 為 nil
- **THEN** Widget 顯示「點右上角查詢取得班次」提示文字，不顯示班次列

#### Scenario: API 失敗顯示錯誤訊息
- **WHEN** TDX API 請求失敗（非 2xx 或逾時）且 `hsr_widget_last_error` 已寫入錯誤訊息
- **THEN** Widget 顯示「無法取得班次，請點查詢重試」，查詢按鈕仍可點擊

---

### Requirement: HSR AppIntent 查詢按鈕即時刷新
高鐵 widget 右上角「查詢」按鈕 SHALL 使用 `HSRRefreshTimetableIntent`（新增類別，與既有 `RefreshTimetableIntent` 平行），在 Widget Extension process 直接呼叫 TDX HSR API 並重新整理 `"HSRWidget"` timeline；intent 讀寫 `hsr_widget_*` 系列 App Group key。

#### Scenario: 點擊查詢按鈕觸發 HSR AppIntent
- **WHEN** 使用者點擊高鐵 widget 右上角「查詢」膠囊按鈕
- **THEN** 系統執行 `HSRRefreshTimetableIntent.perform()`，於 Extension process 以 `AppGroupDataSource(system: .hsr)` 讀取 `hsr_widget_route`，呼叫 `TDXAPIClient` 的 HSR 端點取得最新班次，將結果寫入 `hsr_widget_schedules`，並呼叫 `WidgetCenter.shared.reloadTimelines(ofKind: "HSRWidget")`

#### Scenario: HSR AppIntent 更新後 widget 顯示新班次
- **WHEN** `HSRRefreshTimetableIntent` 成功取得新班次資料
- **THEN** 高鐵 widget timeline 重新整理，UI 更新為最新班次，footer 顯示最新更新時間；台鐵 widget 不受影響（kind 不同）

#### Scenario: HSR AppIntent 失敗不崩潰
- **WHEN** `HSRRefreshTimetableIntent.perform()` 拋出例外（API 失敗、網路錯誤）
- **THEN** Intent 將錯誤訊息寫入 `hsr_widget_last_error`，回傳 `.failure` result，Widget 顯示錯誤狀態，不崩潰

---

### Requirement: HSR Timeline 自動更新策略
HSR widget 的 `HSRRailwayTimelineProvider` SHALL 依與台鐵 widget 相同的策略自動請求 TDX HSR API 並建立 timeline entries（與台鐵 widget 兩個 timeline policy 各自獨立、不互相觸發）。

#### Scenario: HSR Timeline 到期自動重新整理
- **WHEN** 目前 HSR timeline 的最後一個 entry 到期（`.after(now + 1h)` policy）
- **THEN** 系統呼叫 `HSRRailwayTimelineProvider.getTimeline`，打 TDX API 取得最新 HSR 班次，建立未來 1 小時的 entries

#### Scenario: HSR Timeline entries 每小時一筆
- **WHEN** `getTimeline` 成功取得 HSR 班次
- **THEN** 產生至少 1 筆 entry，日期為當下，下次更新時間設為 1 小時後

#### Scenario: TR / HSR Timeline 不交叉觸發
- **WHEN** TR widget 的 timeline 到期觸發 `reloadTimelines(ofKind: "RailwayWidget")`
- **THEN** HSR widget 的 timeline 不被觸發（kind 不同）；反之亦然

---

### Requirement: HSR Widget 內嵌選站器
高鐵 widget 上的出發站 / 到達站名稱 SHALL 為可點擊 `Button(intent:)`，點擊後在 Widget 同一 4×2 空間顯示選站 chip grid，僅顯示高鐵車站；intent 讀寫 `hsr_widget_*` 系列 key。（`RailwayWidgetExtension.IPHONEOS_DEPLOYMENT_TARGET = 17.0`，故無 iOS 16 fallback。）

#### Scenario: 點擊出發站名稱開啟 HSR 選站 grid
- **WHEN** 使用者點擊高鐵 widget 上帶底線的出發站名稱
- **THEN** 系統執行 `HSRShowPickerIntent(mode: "from")`（新增類別），將 `"from"` 寫入 `hsr_widget_picker_mode`，呼叫 `reloadTimelines(ofKind: "HSRWidget")`；Widget 切換至選站模式，顯示 `GetPickerStationsUseCase.execute(system: "HSR")` 回傳的全 12 個高鐵站台 chip（6 cols × 2 rows），**永遠按南港→左營的北到南固定順序排列**（`UpdateWidgetStationsUseCase.execute` 對 HSR 短路 early-return，不執行 setFront 重排）；標題顯示「選擇出發站」，footer 顯示目前到達站名稱

#### Scenario: 點擊到達站名稱開啟 HSR 選站 grid
- **WHEN** 使用者點擊高鐵 widget 上帶底線的到達站名稱
- **THEN** 系統執行 `HSRShowPickerIntent(mode: "to")`，Widget 切換至選站模式；標題顯示「選擇到達站」，footer 顯示目前出發站名稱

#### Scenario: 選擇 HSR 站台更新路線
- **WHEN** 使用者在高鐵選站 grid 點擊任一站台 chip
- **THEN** 系統執行 `HSRSelectStationIntent(stationName:stationId:)`（新增類別），從 `widget_stations.db` 查找 stationId（找不到時使用靜態 HSR 對照表），更新 `hsr_widget_route` UserDefaults，清除 `hsr_widget_picker_mode`，呼叫 `reloadTimelines(ofKind: "HSRWidget")`；Widget 返回班次模式並顯示新路線；`tr_widget_route` 不受影響

#### Scenario: 關閉 HSR 選站 grid 不變更路線
- **WHEN** 使用者點擊高鐵選站 grid 右上角「×」按鈕
- **THEN** 系統執行 `HSRDismissPickerIntent`（新增類別），清除 `hsr_widget_picker_mode`，Widget 返回班次模式，路線維持不變

---

### Requirement: HSR Widget 與台鐵 Widget 並存於 WidgetBundle
`RailwayWidgetBundle` SHALL 同時宣告 `RailwayWidget`（台鐵，kind `"RailwayWidget"`）與新增的 `HSRMediumWidget`（高鐵，kind `"HSRWidget"`）；兩支 widget 同屬一個 extension target，共用 App Group `group.com.jerry.railwaytimetable.widget`。

#### Scenario: Bundle 列出兩個 widget
- **WHEN** Widget Extension 啟動並向系統註冊 widget
- **THEN** `RailwayWidgetBundle.body` 同時回傳 `RailwayWidget()` 與 `HSRMediumWidget()` 兩個 widget

#### Scenario: 使用者可在 widget gallery 同時看到兩個選項
- **WHEN** 使用者在 iOS 桌面長按進入「+」widget gallery 並搜尋 app 名稱
- **THEN** widget gallery 顯示兩個獨立選項：「台鐵時刻表」（displayName `"台鐵時刻表"`）與「高鐵時刻表」（displayName `"高鐵時刻表"`）

#### Scenario: 使用者可同時釘住兩支 widget
- **WHEN** 使用者依序將「台鐵時刻表」與「高鐵時刻表」拉到桌面
- **THEN** 桌面同時顯示兩支獨立 widget，各自顯示其系統的班次資料，互不干擾

---

### Requirement: HSR Widget Xcode Preview 配置
HSR widget 原始碼 SHALL 提供 `#Preview(as: .systemMedium)` 預覽 block，使用 `HSRMediumWidget` 與 placeholder entry，能在 Xcode 預覽窗格中正確渲染。

#### Scenario: HSR widget Xcode 預覽
- **WHEN** 開發者在 Xcode 開啟 `HSRWidget.swift` 並啟用 Canvas 預覽
- **THEN** 預覽窗格顯示高鐵 widget Medium 尺寸的 placeholder 狀態（`臺北 → 左營`、無班次提示），不需執行真機或模擬器

---

### Requirement: HSR Widget App Group Key 命名與隔離
HSR widget 相關狀態 SHALL 一律以 `hsr_widget_` 為 prefix 儲存於 App Group `UserDefaults`，不與台鐵 widget 的 `tr_widget_` 系列 key 共用、不寫入舊版 generic key（`widget_route` / `widget_picker_mode` / `widget_schedules` / `widget_last_error`）。

#### Scenario: AppGroupDataSource(system:) 動態組 key
- **WHEN** Widget Extension 程式碼建立 `AppGroupDataSource(system: .hsr)` 並呼叫任何 read/write 方法
- **THEN** 內部以 `"hsr_widget_route"` / `"hsr_widget_picker_mode"` / `"hsr_widget_schedules"` / `"hsr_widget_last_error"` 為 UserDefaults key 操作；同樣 `(system: .tr)` 則使用 `tr_widget_*` prefix

#### Scenario: 兩 widget 同時寫入不互相覆蓋
- **WHEN** 在極短時間內，TR widget 的 `RefreshTimetableIntent` 與 HSR widget 的 `HSRRefreshTimetableIntent` 都觸發並寫入 schedules
- **THEN** `tr_widget_schedules` 與 `hsr_widget_schedules` 各自被寫入正確內容，UserDefaults atomic write 保證兩個 key 各自一致，無資料遺失或交叉污染


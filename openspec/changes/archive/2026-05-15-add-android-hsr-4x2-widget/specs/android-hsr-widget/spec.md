# android-hsr-widget Specification

## Purpose

Android 4×2 高鐵專屬桌面 Glance widget（receiver class `com.example.flutter_railway_timetable.widget.presentation.HSRRailwayWidgetReceiver`、widget class `HSRRailwayGlanceWidget`、widget gallery displayName「高鐵時刻表」）的視覺渲染、`ActionCallback` 互動、SharedPreferences key 隔離、TDX HSR API 整合與 widget metadata 之需求集合。本 capability 與 `android-tr-widget`（台鐵）平行存在，共用同一個 SharedPreferences file（`com.example.flutter_railway_timetable.widget_prefs`）與 `TdxApiClient` / `KotlinTdxAuthManager` 資料層，但所有狀態以 `hsr_widget_` key prefix 完全隔離；視覺渲染對齊設計檔 `Home Screen Widgets.html` 的 `AndroidMedium`(system='HSR')。

## ADDED Requirements

### Requirement: HSR 4×2 Widget 視覺渲染

系統 SHALL 在 Android 主畫面顯示獨立的 4×2（targetCellWidth=4, targetCellHeight=2）高鐵專屬 Glance Widget（widget gallery displayName「高鐵時刻表」），與既有「鐵路時刻表」widget 平行存在；外觀套用 HSR 橘金 palette（accent `#C86820`、accentSoft `#FBEEDF`、icon `R.drawable.widget_icon_hsr`），版面結構與既有 TR widget 對稱以維持兩支 widget 視覺一致。

#### Scenario: HSR widget 顯示班次

- **WHEN** SharedPreferences key `hsr_widget_route` 設定為高鐵路線（system = "HSR"）且 `hsr_widget_schedules` 有資料
- **THEN** Widget 顯示白底卡片；header 左側顯示 `widget_icon_hsr` 圖示（32dp）+ 「高鐵 時刻表」（15sp bold）+ 出發→到達站名（12sp accent `#C86820`，可點擊）；右側顯示 `hsr_widget_last_update` 更新時間 chip（accent soft `#FBEEDF` 背景、accent `#C86820` 文字）+ 「查詢」button（accent soft 背景、accent 文字）；下方最多 3 筆班次列（出發時間 16sp bold accent、車種 chip gray bg `#F3F4F6`、車號 12sp gray、"→ 抵達時間" 12sp gray）

#### Scenario: HSR widget 首次安裝顯示預設路線

- **WHEN** 使用者首次將「高鐵時刻表」widget 加入桌面，且 SharedPreferences `hsr_widget_route` 不存在
- **THEN** Widget 透過 `WidgetRoute.defaultFor("HSR")` 顯示預設路線「臺北 → 左營」（fromId "1000" / toId "1070"），顯示「點站名選路線，再按查詢」提示直到使用者首次查詢；既有 `widget_route`（TR widget 使用的 key）不被讀取也不被寫入

#### Scenario: HSR widget 與 TR widget 狀態完全隔離

- **WHEN** 使用者在 HSR widget 修改路線（例如改為 `板橋 → 台中`）
- **THEN** 僅 `hsr_widget_route` 被更新；既有 `widget_route`（TR widget 使用）不受影響；TR widget 顯示內容維持不變

#### Scenario: 尚無班次資料時顯示提示

- **WHEN** `hsr_widget_schedules` 為空且 `hsr_widget_last_error` 為 null
- **THEN** Widget 顯示「點站名選路線，再按查詢」提示文字（13sp `#9CA3AF`），不顯示班次列

#### Scenario: API 失敗顯示錯誤訊息

- **WHEN** `hsr_widget_last_error` 已寫入錯誤訊息（如「查詢失敗，請稍後再試」、`ERR_NO_CREDENTIALS`）
- **THEN** Widget 顯示 `hsr_widget_last_error` 字串，查詢 button 仍可點擊

---

### Requirement: HSR「查詢」ActionCallback 觸發 API 更新

HSR widget 右上角「查詢」button SHALL 使用 Glance `actionRunCallback<HSRRefreshWidgetAction>()`，在 Widget process 呼叫 `TdxApiClient.fetchHSRSchedule` 並更新 `hsr_widget_*` SharedPreferences key 後刷新 HSR widget，不啟動主 App，不影響 TR widget。

#### Scenario: 點擊查詢 button 觸發 HSRRefreshWidgetAction

- **WHEN** 使用者點擊 HSR widget 右上角「查詢」button
- **THEN** 系統執行 `HSRRefreshWidgetAction.onAction()`：先讀 `WidgetPrefsHSR.loadRoute(context)`，若無則直接 fallback 至 `WidgetRoute.defaultFor("HSR")`（「臺北 → 左營」）；**刻意不走 `GetPickerStationsUseCase.execute("HSR")` 取前兩筆當中間 fallback**（與 TR 行為差異），因 HSR picker 固定 N→S 序、前兩筆永遠是「南港 → 臺北」，會違反 Decision 5 的「臺北 → 左營」預設承諾；以當天 Asia/Taipei 日期（透過 `TaipeiClock.todayDate()`）呼叫 `GetNextTrainsUseCase.execute(fromId, toId, today, "HSR")`

#### Scenario: HSRRefreshWidgetAction 成功取得班次後更新 HSR widget

- **WHEN** `GetNextTrainsUseCase.execute()` 回傳 HSR 班次列表
- **THEN** 呼叫 `WidgetPrefsHSR.saveRefreshResult(context, route, schedules, TaipeiClock.nowTime())` — 透過單次 `prefs.edit()...apply()` 一併寫入 `hsr_widget_route` / `hsr_widget_schedules`（最多 3 筆班次 JSON）/ `hsr_widget_last_update`（當前 HH:mm）並 `.remove(hsr_widget_last_error)`；呼叫 `HSRRailwayGlanceWidget().update(context, glanceId)` 刷新 HSR widget UI；既有 TR widget 不受影響

#### Scenario: HSRRefreshWidgetAction API 失敗不崩潰且立即顯示錯誤

- **WHEN** `GetNextTrainsUseCase.execute()` 拋出例外
- **THEN** `HSRRefreshWidgetAction.onAction()` 捕獲：`WidgetAuthException` 走 `WidgetPrefsHSR.saveRefreshError(context, e.message ?: "ERR_AUTH")`，其他例外走 `WidgetPrefsHSR.saveRefreshError(context, "查詢失敗，請稍後再試")`；該 helper 透過單次 `prefs.edit()...apply()` 同時把 `hsr_widget_schedules` 寫成 `"[]"`、`hsr_widget_last_error` 寫入錯誤訊息，確保 widget UI 的「if schedules empty → show lastError」分支立即觸發，使用者按下查詢後馬上看到錯誤而非殘留舊班次資料；呼叫 `HSRRailwayGlanceWidget().update()` 刷新顯示錯誤狀態，不崩潰

---

### Requirement: HSR Widget 內嵌站台 Picker

HSR widget SHALL 提供點選站名直接切換出發/到達站的能力，picker 永遠按南港→左營 N→S 固定順序顯示全 12 個高鐵站台，不需開啟主 App，不影響 TR widget。

#### Scenario: 點站名開啟 HSR picker

- **WHEN** 使用者點擊 HSR widget header 內的出發或到達站名
- **THEN** `HSRShowPickerAction` 把 `"from"` 或 `"to"` 寫入 `hsr_widget_picker_mode`，HSR widget recompose 切換到 picker 模式（顯示 4 cols × 3 rows = 12 站台 grid，標題「選擇出發站 / 到達站」、副標「高鐵 · 點選下方車站」）

#### Scenario: 選站寫回路線並清空班次

- **WHEN** 使用者在 HSR picker 點擊任一站台
- **THEN** `HSRSelectStationAction` 依 `isFrom` 參數將該站寫回 `hsr_widget_route` 對應欄位、清空 `hsr_widget_schedules`、把 `hsr_widget_picker_mode` 設回 `"home"`、呼叫 `HSRRailwayGlanceWidget().update(context, glanceId)` reload HSR widget；**不呼叫任何 HSR API**（與 TR widget `SelectStationAction` 一致——選站後使用者需主動按查詢才會抓新班次）；既有 TR widget 不受影響

#### Scenario: 關閉 HSR picker 不變更路線

- **WHEN** 使用者點擊 HSR picker 右上角的「×」
- **THEN** `HSRDismissPickerAction` 把 `hsr_widget_picker_mode` 設回 `"home"`，HSR widget 回到班次視圖，`hsr_widget_route` 不變

#### Scenario: HSR picker 站台來源與排序

- **WHEN** HSR widget 進入 picker 模式
- **THEN** `GetPickerStationsUseCase.execute("HSR")` 從 `WidgetStationRepositoryImpl`（Room read-only）讀取 HSR 12 站；既有 Flutter 端 `UpdateWidgetStationsUseCase.execute("HSR")` 短路 early-return 不執行 `setFront` 重排，故 HSR 站永遠按 Drift `_hsrDefaults` 初次 seed 的南港→左營 N→S 序排列；DB 不足 12 筆時以 `PickerStationDefaults.stations("HSR")` 補滿；DB 不可用時整批 fallback 至 defaults

---

### Requirement: HSR Widget SharedPreferences Key 隔離

HSR widget 相關狀態 SHALL 一律透過 `WidgetPrefsHSR : WidgetPrefsBase("hsr_")` 寫入既有 SharedPreferences file（`com.example.flutter_railway_timetable.widget_prefs`），實際 key 自動加上 `hsr_widget_` 前綴；不與 TR widget 的 `widget_*` 系列 key 共用、不透過 `WidgetPrefsTR` 寫入。

#### Scenario: WidgetPrefsHSR.saveRoute 寫入 hsr_widget_route

- **WHEN** 呼叫 `WidgetPrefsHSR.saveRoute(context, route)`
- **THEN** SharedPreferences 寫入 key `hsr_widget_route`，內容為 JSON `{"fromName":"…","fromId":"…","toName":"…","toId":"…","system":"HSR"}`；既有 `widget_route` key 不被讀取或寫入

#### Scenario: 兩 widget 同時寫入不互相覆蓋

- **WHEN** 在極短時間內，TR widget 的 `RefreshWidgetAction` 與 HSR widget 的 `HSRRefreshWidgetAction` 都觸發並寫入 schedules
- **THEN** `WidgetPrefsTR` 寫到 `widget_schedules`、`WidgetPrefsHSR` 寫到 `hsr_widget_schedules`，各自正確內容；SharedPreferences 同 file 不同 key 不會交叉污染；無資料遺失

#### Scenario: HSR widget 不寫入 TR namespace

- **WHEN** HSR widget 任何 `ActionCallback`（`HSRRefreshWidgetAction` / `HSRShowPickerAction` / `HSRDismissPickerAction` / `HSRSelectStationAction`）執行
- **THEN** 內部呼叫所有 prefs 方法皆透過 `WidgetPrefsHSR.xxx(...)`；型別系統保證不存在任何呼叫處透過 `WidgetPrefsTR` 寫入（單元測試以 `mockkObject(WidgetPrefsTR)` + `verify(exactly = 0) { WidgetPrefsTR.saveXxx(any(), any()) }` 雙重防護）

---

### Requirement: HSR Widget Metadata 與 Manifest 設定

系統 SHALL 正確設定 Android `HSRRailwayWidgetReceiver` 的 widget provider info XML 與 Manifest 區塊，使 Launcher 可正確識別「高鐵時刻表」widget 並與既有「鐵路時刻表」widget 並列於 widget gallery。

#### Scenario: HSR AppWidgetProviderInfo 尺寸設定

- **WHEN** 使用者在 Widget gallery 選取「高鐵時刻表」
- **THEN** `railway_widget_hsr_info.xml` 指定 `android:targetCellWidth="4"`、`android:targetCellHeight="2"`、`android:minWidth="294dp"`、`android:minHeight="110dp"`、`android:updatePeriodMillis="0"`（不自動刷新，僅 user 觸發）、`android:label="@string/hsr_widget_label"`（值 = `"高鐵時刻表"`）、`android:description="@string/hsr_widget_description"`、`android:previewImage="@drawable/widget_icon_hsr"`、`android:initialLayout="@layout/railway_widget_initial"`（重用既有 initial layout，避免 redundancy）

#### Scenario: HSRRailwayWidgetReceiver 於 Manifest 正確宣告

- **WHEN** 系統發送 `ACTION_APPWIDGET_UPDATE` broadcast
- **THEN** `AndroidManifest.xml` 內的 `.widget.presentation.HSRRailwayWidgetReceiver` receiver 捕獲並由 Glance 驅動 HSR widget 更新；既有 `.widget.presentation.RailwayWidgetReceiver` 不受影響、繼續處理 TR widget broadcast

#### Scenario: 使用者可在 widget gallery 同時看到兩個選項

- **WHEN** 使用者進入 Android 桌面 widget picker 並搜尋 app 名稱
- **THEN** widget picker 顯示兩個獨立選項：「鐵路時刻表」（既有 TR widget）與「高鐵時刻表」（新 HSR widget）

#### Scenario: 使用者可同時釘住兩支 widget

- **WHEN** 使用者依序將「鐵路時刻表」與「高鐵時刻表」拉到桌面
- **THEN** 桌面同時顯示兩支獨立 widget，各自顯示其系統的班次資料，互不干擾

---

### Requirement: HSR Widget Glance Composable 共用 helper 重用 TR widget 結構

`HSRRailwayGlanceWidget` SHALL 與既有 `RailwayGlanceWidget` 共用同一份 `@Composable` 私有 helper（`WidgetContent` / `PickerContent` / `TrainRow`，位於 `widget/presentation/WidgetComposables.kt`，可見性 `internal`），透過參數注入 HSR palette 與 HSR-specific 行為差異。

#### Scenario: 共用 Composable 渲染兩種 widget

- **WHEN** `HSRRailwayGlanceWidget.provideGlance` 與 `RailwayGlanceWidget.provideGlance` 各自執行
- **THEN** 兩者皆呼叫位於 `WidgetComposables.kt` 的 `internal fun WidgetContent(route, schedules, lastError, lastUpdate, palette, ...)` / `internal fun PickerContent(route, stations, mode, palette, chunkSize, onShowPicker, onDismiss, onSelectStation)`；HSR 傳入 HSR palette + `chunkSize = 4`、TR 傳入 TR palette + `chunkSize = 5`；其餘 Composable 內部邏輯（layout / 字級 / 顏色映射）完全共用

#### Scenario: HSR picker grid 為 4 cols × 3 rows

- **WHEN** HSR widget 進入 picker 模式
- **THEN** `PickerContent` 內 `stations.chunked(chunkSize = 4)` 將 12 個 HSR 站排為 4 cols × 3 rows；原規劃 6 cols × 2 rows 對齊設計檔 `widgets.jsx` 的 `AndroidMediumConfig`(HSR)，但實作驗證發現 Glance `Row` + 6 個 `defaultWeight()` chip 在 4×2 widget 寬度下最後一個 chip 會被擠出可視範圍，故改為 4 cols × 3 rows 確保 12 站可靠渲染；TR widget picker 維持原 `chunkSize = 5`（10 站 chunked(5) = 2 rows 5 cols）

---

### Requirement: HSR Widget 不掛定時 Refresh

HSR widget SHALL 不設置 `updatePeriodMillis` 自動刷新、不註冊 WorkManager 週期任務；HSR widget 只在三個 trigger 下刷新：widget receiver onUpdate（initial render）、`HSRRefreshWidgetAction` 觸發、`HSRSelectStationAction` 觸發。

#### Scenario: 不掛 WorkManager 週期任務

- **WHEN** App 啟動或 HSR widget 加入桌面
- **THEN** 系統不註冊任何針對 HSR widget 的 `PeriodicWorkRequest`；HSR widget 不會因為時間流逝自動觸發 `HSRRefreshWidgetAction`

#### Scenario: railway_widget_hsr_info.xml updatePeriodMillis = 0

- **WHEN** 系統載入 HSR widget provider info
- **THEN** `android:updatePeriodMillis="0"`；Android Launcher 不會週期觸發 `ACTION_APPWIDGET_UPDATE`

---

### Requirement: HSR Widget 全層級單元測試覆蓋

`HSRRefreshWidgetAction` / `HSRShowPickerAction` / `HSRDismissPickerAction` / `HSRSelectStationAction` 與 `WidgetPrefs` 的 HSR prefix 路徑 SHALL 有對應 Kotlin unit test，依 `openspec/specs/common/spec.md` 的 TDD 規範覆蓋成功、失敗、邊界情境。

#### Scenario: HSRRefreshWidgetActionTest 驗證成功路徑

- **WHEN** 測試以 `MockWebServer` 或 mock `TdxApiClient` 提供 HSR 時刻表回應、`WidgetPrefs` 已有 `hsr_widget_route`
- **THEN** 測試驗證：(1) 呼叫了 `TdxApiClient.fetchHSRSchedule`、(2) 寫入 `hsr_widget_schedules` 與 `hsr_widget_last_update`、(3) `widget_route` 與 `widget_schedules`（TR key）**未被寫入**

#### Scenario: HSRSelectStationActionTest 驗證選站不打 API

- **WHEN** 測試模擬使用者點站名
- **THEN** 測試驗證：(1) 寫入 `hsr_widget_route`、(2) `hsr_widget_schedules` 被清空為 `"[]"`、(3) `hsr_widget_picker_mode` 設為 `"home"`、(4) **`TdxApiClient` 完全未被呼叫**、(5) `widget_*`（TR key）未被影響

#### Scenario: WidgetPrefsHSRPrefixTest 驗證 prefix 寫入正確

- **WHEN** 呼叫 `WidgetPrefsHSR.saveRoute(context, route)` 等所有 save/load 方法
- **THEN** SharedPreferences 寫入的 key 全部為 `hsr_widget_route` / `hsr_widget_schedules` / `hsr_widget_last_error` / `hsr_widget_last_update` / `hsr_widget_picker_mode`，無例外

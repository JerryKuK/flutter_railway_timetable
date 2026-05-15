## Requirements

### Requirement: 4×2 鐵路 Widget 視覺渲染
系統 SHALL 在 Android 主畫面顯示 4×2（targetCellWidth=4, targetCellHeight=2）「鐵路時刻表」Glance Widget（widget gallery displayName「鐵路時刻表」），套用台鐵藍 palette，外觀與 iOS `MediumWidgetView`（TR）一致。本 widget 僅渲染台鐵（TR）配色與內容；HSR 專屬 widget 由獨立的 `android-hsr-widget` capability 承載，與本 widget 平行存在於 widget gallery。

#### Scenario: 台鐵 Widget 顯示班次
- **WHEN** SharedPreferences `widget_route` 設定為台鐵路線（system = "TR"），且 `widget_schedules` 有資料
- **THEN** Widget 顯示白底卡片；header 左側台鐵藍漸層圓圈（#5FA6E0→#2E72B8）+ "台鐵 時刻表"（15sp bold）+ 出發→到達站名（12sp accent，可點擊）；右側更新時間 chip + 「查詢」button（accent soft 背景）；下方最多 3 筆班次列（出發時間 16sp bold accent、車種 chip gray bg #F3F4F6、車號 12sp gray、"→ 抵達時間" 12sp gray）

#### Scenario: 尚無班次資料顯示提示
- **WHEN** `widget_schedules` 為空且 `widget_last_error` 為 null
- **THEN** Widget 顯示「點站名選路線，再按查詢」提示文字（13sp #9CA3AF），不顯示班次列

#### Scenario: API 失敗顯示錯誤訊息
- **WHEN** `widget_last_error` 有值（非 null）且 `widget_schedules` 為空
- **THEN** Widget 顯示 `widget_last_error` 字串，查詢 button 仍可點擊

#### Scenario: 路線未設定時使用預設路線
- **WHEN** SharedPreferences `widget_route` 不存在或無法解析
- **THEN** Widget 使用 `WidgetRoute.defaultFor("TR")`（臺北→高雄）顯示，並顯示空班次提示

#### Scenario: HSR widget 存在不影響 TR widget 渲染
- **WHEN** 使用者於桌面同時釘住「鐵路時刻表」與「高鐵時刻表」兩支 widget
- **THEN** TR widget 僅讀寫未加前綴的 `widget_route` / `widget_schedules` / `widget_last_error` / `widget_last_update` / `widget_picker_mode` 系列 key；HSR widget 寫入 `hsr_widget_*` 系列 key 不影響 TR widget 的顯示內容

---

### Requirement: 「查詢」ActionCallback 觸發 API 更新
Widget 右上角「查詢」button SHALL 使用 Glance `actionRunCallback<RefreshWidgetAction>()`，在 Widget process 呼叫 Kotlin TDX API 並更新 SharedPreferences 後刷新 Widget，不啟動主 App。

#### Scenario: 點擊查詢 button 觸發 ActionCallback
- **WHEN** 使用者點擊 Widget 右上角「查詢」button
- **THEN** 系統執行 `RefreshWidgetAction.onAction()`：先讀 `WidgetPrefs.loadRoute()`，若無則由 `GetPickerStationsUseCase` 取前兩筆當 fallback，再無則用 `WidgetRoute.defaultFor(system)`；以當天 Asia/Taipei 日期呼叫 `GetNextTrainsUseCase.execute(fromId, toId, today, system)`

#### Scenario: ActionCallback 成功取得班次後更新 Widget
- **WHEN** `GetNextTrainsUseCase.execute()` 回傳班次列表
- **THEN** `WidgetPrefs.saveRoute()` 持久化使用的路線；`WidgetPrefs.saveSchedules()` 存入最多 3 筆班次 JSON；`WidgetPrefs.saveLastUpdate()` 存入當前 HH:mm；`WidgetPrefs.saveLastError(null)` 清除錯誤；呼叫 `RailwayGlanceWidget().update(context, glanceId)` 刷新 Widget UI

#### Scenario: ActionCallback API 失敗不崩潰
- **WHEN** `GetNextTrainsUseCase.execute()` 拋出例外
- **THEN** `RefreshWidgetAction.onAction()` 捕獲：`WidgetAuthException` 寫入其 message（如 `ERR_NO_CREDENTIALS`），其他例外寫入「查詢失敗，請稍後再試」；呼叫 `RailwayGlanceWidget().update()` 刷新顯示錯誤狀態，不崩潰

---

### Requirement: Widget 內嵌站台 Picker
Widget SHALL 提供點選站名直接切換出發/到達站的能力，而不需開啟主 App。

#### Scenario: 點站名開啟 picker
- **WHEN** 使用者點擊 header 內的出發或到達站名
- **THEN** `ShowPickerAction` 把 `widget_picker_mode` 設為 `"from"` 或 `"to"`，Widget recompose 切換到 `PickerContent`（顯示 5×N 站台 grid，標題「選擇出發站 / 到達站」）

#### Scenario: 選站寫回路線
- **WHEN** 使用者在 picker 點擊一個站台
- **THEN** `SelectStationAction` 依 `isFrom` 將該站寫回 `widget_route` 對應欄位、清空 `widget_schedules`、把 `widget_picker_mode` 設回 `"home"`，Widget 回到班次視圖

#### Scenario: 關閉 picker
- **WHEN** 使用者點擊 picker 右上角的「×」
- **THEN** `DismissPickerAction` 把 `widget_picker_mode` 設回 `"home"`，回到班次視圖

#### Scenario: Picker 站台來源
- **WHEN** Widget 進入 picker 模式
- **THEN** `GetPickerStationsUseCase.execute(system)` 從 `WidgetStationRepositoryImpl`（Room read-only）讀取目前 system 的站台；若 DB 不足 10 筆則以 `PickerStationDefaults` 補滿；DB 不可用時整批 fallback 至 defaults

---

### Requirement: Kotlin TDX Auth + API Client（Clean Architecture）
Domain layer SHALL 定義 `WidgetSchedule`、`WidgetRoute`、`PickerStation` entity 與 `ITrainScheduleRepository`、`IWidgetStationRepository` 介面；Data layer 實作 `KotlinTdxAuthManager`（token 快取）、`TdxApiClient`（Retrofit，TRA + HSR）。本 capability 描述的 Kotlin 資料層為 TR widget 與 HSR widget 共享之基礎建設——`TdxApiClient.fetchTRASchedule` 服務 TR widget、`TdxApiClient.fetchHSRSchedule` 服務 HSR widget；`KotlinTdxAuthManager` token 同時供兩支 widget 使用。

#### Scenario: KotlinTdxAuthManager Token 快取
- **WHEN** 呼叫 `KotlinTdxAuthManager.getValidToken()`，且 token 不存在或已過期
- **THEN** 在 `Dispatchers.IO` 上以 `Mutex` 序列化執行：向 TDX token endpoint 發送 `client_credentials` POST，快取 `access_token` 及到期時間（`expires_in - 60` 秒）；後續呼叫在 token 有效期內直接回傳快取值，不重新請求；TR widget 與 HSR widget 共用同一份快取，不重複請求 token

#### Scenario: TDX 憑證缺失時拋出可識別錯誤
- **WHEN** `BuildConfig.TDX_CLIENT_ID` 或 `BuildConfig.TDX_CLIENT_SECRET` 為空字串
- **THEN** `KotlinTdxAuthManager.getValidToken()` 拋出 `WidgetAuthException("ERR_NO_CREDENTIALS")`；TR 的 `RefreshWidgetAction` 與 HSR 的 `HSRRefreshWidgetAction` 各自捕獲後寫入對應的 `widget_last_error` / `hsr_widget_last_error`，不崩潰

#### Scenario: 台鐵時刻表 API 呼叫
- **WHEN** 呼叫 `TdxApiClient.fetchTRASchedule(fromId, toId, date)`
- **THEN** 向 `GET /api/basic/v3/Rail/TRA/DailyTrainTimetable/OD/{fromId}/to/{toId}/{date}?$format=JSON` 發送請求，解析 `TrainTimetables` 陣列，回傳 `List<WidgetSchedule>`（依 API 原順序，由上層 UseCase 排序），格式 `dep = HH:mm`、`arr = HH:mm`、`type` = TrainTypeName.Zh_tw、`num = "#" + TrainNo`

#### Scenario: 高鐵時刻表 API 呼叫
- **WHEN** 呼叫 `TdxApiClient.fetchHSRSchedule(fromId, toId, date)`
- **THEN** 向 `GET /api/basic/v2/Rail/THSR/DailyTimetable/OD/{fromId}/to/{toId}/{date}?$format=JSON` 發送請求；HTTP 404 視為當日無班次回空 list；其他 4xx/5xx 拋出例外給上層處理；此 API 為 HSR widget 端 `HSRRefreshWidgetAction` 的資料來源

#### Scenario: GetNextTrainsUseCase 過濾並回傳前 3 班
- **WHEN** 呼叫 `GetNextTrainsUseCase.execute(fromId, toId, date, system, now)`
- **THEN** 過濾掉 `dep < now (Asia/Taipei HH:mm)` 的班次後依 `dep` 升冪排序，取前 3 筆；若今日不足 3 筆，再呼叫一次以隔日 date fetch 補滿（隔日呼叫失敗則靜默忽略）；system 參數 `"TR"` 走 `fetchTRASchedule`、`"HSR"` 走 `fetchHSRSchedule`，由 TR widget 與 HSR widget 各自的 Action 帶入

---

### Requirement: SharedPreferences 資料存取（WidgetPrefsBase + namespaced singletons）
TR 與 HSR widget SHALL 共用同一個 SharedPreferences file（name = `com.example.flutter_railway_timetable.widget_prefs`），對稱 iOS `AppGroupDataSource`。Kotlin 端以 `abstract class WidgetPrefsBase(keyPrefix: String)` 容納 JSON encode/decode 與 SharedPreferences edit 邏輯；檔尾兩個 typed singleton 各自綁定 prefix:

- `object WidgetPrefsTR : WidgetPrefsBase("")` — 寫入未加前綴的 `widget_route` / `widget_schedules` / `widget_last_error` / `widget_last_update` / `widget_picker_mode`
- `object WidgetPrefsHSR : WidgetPrefsBase("hsr_")` — 寫入 `hsr_widget_*` 系列 key

呼叫者透過 `WidgetPrefsTR.xxx(...)` / `WidgetPrefsHSR.xxx(...)` 直接取用,無需傳 prefix 參數,呼叫端 type-safe 防呆。Base class 額外提供 `saveRefreshResult(context, route, schedules, lastUpdate)` 與 `saveRefreshError(context, errorMessage)` 把成功/失敗 refresh 的多次寫入合併為單一 `prefs.edit().apply()`,節省 disk schedule 次數。

#### Scenario: WidgetPrefsTR.saveRoute / loadRoute JSON 存取
- **WHEN** 呼叫 `WidgetPrefsTR.saveRoute(context, route)`
- **THEN** 以 JSON `{"fromName":"…","fromId":"…","toName":"…","toId":"…","system":"TR|HSR"}` 寫入 key `widget_route`；`WidgetPrefsTR.loadRoute(context)` 能正確解析並回傳 `WidgetRoute` 物件；解析失敗時回傳 null

#### Scenario: WidgetPrefsTR.saveSchedules / loadSchedules JSON 存取
- **WHEN** 呼叫 `WidgetPrefsTR.saveSchedules(context, schedules)`
- **THEN** 以 JSON array `[{"dep":"HH:mm","arr":"HH:mm","type":"…","num":"#…"}]` 寫入 key `widget_schedules`；`WidgetPrefsTR.loadSchedules(context)` 能正確解析並回傳 `List<WidgetSchedule>`

#### Scenario: WidgetPrefsTR.saveLastError null 移除 key
- **WHEN** 呼叫 `WidgetPrefsTR.saveLastError(context, null)`
- **THEN** key `widget_last_error` 從 SharedPreferences 移除；`WidgetPrefsTR.loadLastError(context)` 回傳 null

#### Scenario: WidgetPrefsTR.savePickerMode / loadPickerMode
- **WHEN** 呼叫 `WidgetPrefsTR.savePickerMode(context, "from"|"to"|"home")`
- **THEN** 寫入 key `widget_picker_mode`；`WidgetPrefsTR.loadPickerMode(context)` 預設回 `"home"`

#### Scenario: WidgetPrefsTR.saveRefreshResult 單次 edit 寫入 route + schedules + lastUpdate 並清除 lastError
- **WHEN** 呼叫 `WidgetPrefsTR.saveRefreshResult(context, route, schedules, "HH:mm")`
- **THEN** 透過單一 `prefs.edit()...apply()` 寫入 `widget_route`、`widget_schedules`、`widget_last_update` 並 `.remove(widget_last_error)`,只 schedule 一次 disk write

#### Scenario: WidgetPrefsTR.saveRefreshError 單次 edit 清空 schedules + 寫入 lastError
- **WHEN** 呼叫 `WidgetPrefsTR.saveRefreshError(context, "查詢失敗，請稍後再試")`
- **THEN** 透過單一 `prefs.edit()...apply()` 把 `widget_schedules` 寫成 `"[]"` 並 `widget_last_error` 寫入錯誤訊息,確保 widget UI 的「if schedules empty → show lastError」分支立即觸發

#### Scenario: HSR namespace 不污染 TR key
- **WHEN** HSR widget 呼叫 `WidgetPrefsHSR.saveRoute(context, route)`
- **THEN** SharedPreferences 寫入 key `hsr_widget_route`；既有 `widget_route` 完全不受影響、TR widget 下次讀取仍取得原值；反之 `WidgetPrefsTR.saveRoute` 不影響 `hsr_widget_route`

---

### Requirement: 站台清單 Room Read-only Bridge
系統 SHALL 透過 Room（`WidgetStationRoomDatabase` + `WidgetStationDao`）以 read-only 方式讀取 Flutter app 由 Drift 寫入的 `widget_stations.db`，schema 完全對齊以避免 Room 的 schema validator 觸發。

#### Scenario: Room schema 對齊 Drift
- **WHEN** Room 開啟 `widget_stations.db`
- **THEN** `WidgetStationEntity` 包含 `id INTEGER PK autoGenerate`、`name TEXT`、`station_id TEXT`、`system TEXT`、`sort_order INTEGER NOT NULL`；`sort_order` 必須 `@ColumnInfo(defaultValue = "0")` 對齊 Drift 的 `DEFAULT 0`；entity **不得**宣告 `indices = [...]`，因為 Drift 的 `uniqueKeys: [{name, system}]` 會生成 SQLite 自動索引 `sqlite_autoindex_widget_stations_1`，而 Room 的 `TableInfo.read` 在驗證時會主動過濾 `sqlite_autoindex_*` — 多宣告反而會導致 schema mismatch 錯誤

#### Scenario: 共用 DB 路徑
- **WHEN** Flutter 透過 MethodChannel `com.jerry.railwaytimetable/app_group` 呼叫 `getAppGroupDir`
- **THEN** `MainActivity` 回傳 `<applicationContext.dataDir>/databases/`（Room 預設位置），讓 Drift 寫入此處後 Room 能讀到同一份資料

#### Scenario: schema 不對齊時不破壞 Flutter 端資料
- **WHEN** Drift 升級 schema 但 Room 未同步
- **THEN** `WidgetStationRoomDatabase` 不啟用 `fallbackToDestructiveMigration`，Room 開檔失敗時拋出 exception 由 `WidgetStationRepositoryImpl` 上層 try/catch 處理，不會清空 Flutter 端資料

---

### Requirement: Widget Metadata 與 Manifest 設定
系統 SHALL 正確設定 Android Widget provider info XML 與 Manifest，使 Launcher 可正確識別與呈現 4×2 Widget。

#### Scenario: AppWidgetProviderInfo 尺寸設定
- **WHEN** 使用者在 Widget picker 選取「鐵路時刻表」
- **THEN** `railway_widget_info.xml` 指定 `android:targetCellWidth="4"`、`android:targetCellHeight="2"`、`android:minWidth="294dp"`、`android:minHeight="110dp"`、`android:updatePeriodMillis="0"`（不自動刷新，僅 user 觸發）

#### Scenario: RailwayWidgetReceiver 於 Manifest 正確宣告
- **WHEN** 系統發送 `ACTION_APPWIDGET_UPDATE` broadcast
- **THEN** `AndroidManifest.xml` 內的 `.widget.presentation.RailwayWidgetReceiver` receiver 捕獲並由 Glance 驅動 Widget 更新

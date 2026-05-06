## Requirements

### Requirement: 4×2 Medium Widget 視覺渲染
系統 SHALL 在 iOS 主畫面顯示 4×2 Medium 尺寸的鐵路時刻表 widget，外觀依照設計稿 `Home Screen Widgets.html` 像素精確還原。

#### Scenario: 台鐵 widget 顯示班次
- **WHEN** App Group UserDefaults `widget_route` 設定為台鐵路線（system = "TR"）且 timeline 有效
- **THEN** Widget 顯示白底圓角（r=22）卡片；header 左側台鐵藍漸層圓圈（#5FA6E0→#2E72B8）+ 台鐵字樣 + 出發→到達站名；右上角顯示台鐵藍「查詢」膠囊按鈕；下方兩列班次（出發時間、車種 badge、車號、到站時間）

#### Scenario: 高鐵 widget 顯示班次
- **WHEN** App Group UserDefaults `widget_route` 設定為高鐵路線（system = "HSR"）且 timeline 有效
- **THEN** Widget 顯示白底圓角卡片；配色改為高鐵橘漸層（#F2A85C→#C86820）；車種顯示「商務」或「標準」

#### Scenario: 路線未設定時顯示預設路線
- **WHEN** App Group UserDefaults `widget_route` 不存在或無法解析
- **THEN** Widget 使用預設路線（臺北→高雄 台鐵）顯示，並提示「點右上角查詢取得班次」

#### Scenario: 尚無班次資料時顯示提示
- **WHEN** `widget_schedules` 為空且 `widget_last_error` 為 nil
- **THEN** Widget 顯示「點右上角查詢取得班次」提示文字，不顯示班次列

#### Scenario: API 失敗顯示錯誤訊息
- **WHEN** TDX API 請求失敗（非 2xx 或逾時）
- **THEN** Widget 顯示「無法取得班次，請點查詢重試」，查詢按鈕仍可點擊

---

### Requirement: AppIntent 查詢按鈕即時刷新
Widget 右上角「查詢」按鈕 SHALL 使用 `AppIntent`，在 Widget Extension process 直接呼叫 TDX API 並重新整理 timeline，不啟動主 App。

#### Scenario: 點擊查詢按鈕觸發 AppIntent
- **WHEN** 使用者點擊 widget 右上角「查詢」膠囊按鈕
- **THEN** 系統執行 `RefreshTimetableIntent.perform()`，於 Extension process 呼叫 `TDXAPIClient` 取得最新班次，並呼叫 `WidgetCenter.shared.reloadTimelines(ofKind: "RailwayWidget")`

#### Scenario: AppIntent 更新後 widget 顯示新班次
- **WHEN** `RefreshTimetableIntent` 成功取得新班次資料
- **THEN** Widget timeline 重新整理，UI 更新為最新班次，footer 顯示最新更新時間

#### Scenario: AppIntent 失敗不崩潰
- **WHEN** `RefreshTimetableIntent.perform()` 拋出例外（API 失敗、網路錯誤）
- **THEN** Intent 回傳 `.failure` result，Widget 顯示錯誤狀態，不崩潰

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
Widget 上的出發站 / 到達站名稱（iOS 17+）SHALL 為可點擊 `Button(intent:)`，點擊後在 Widget 同一 4×2 空間顯示選站 chip grid，使用者可直接選站而無需開啟主 App。iOS 16 站名顯示為純文字，不可互動。

#### Scenario: 點擊出發站名稱開啟選站 grid（iOS 17+）
- **WHEN** 使用者在 iOS 17+ 裝置點擊 widget 上帶底線的出發站名稱
- **THEN** 系統執行 `ShowPickerIntent(mode: "from")`，Widget 切換至選站模式，顯示台鐵 / 高鐵對應系統的最多 10 個站台 chip；標題顯示「選擇出發站」，footer 顯示目前到達站名稱

#### Scenario: 點擊到達站名稱開啟選站 grid（iOS 17+）
- **WHEN** 使用者在 iOS 17+ 裝置點擊 widget 上帶底線的到達站名稱
- **THEN** 系統執行 `ShowPickerIntent(mode: "to")`，Widget 切換至選站模式；標題顯示「選擇到達站」，footer 顯示目前出發站名稱

#### Scenario: 選擇站台更新路線
- **WHEN** 使用者在選站 grid 點擊任一站台 chip
- **THEN** 系統執行 `SelectStationIntent(stationName:)`，從 SQLite 查找 stationId（找不到時使用靜態對照表），更新 `widget_route` UserDefaults，清除 picker mode，Widget 返回班次模式並顯示新路線

#### Scenario: 關閉選站 grid 不變更路線
- **WHEN** 使用者點擊選站 grid 右上角「×」按鈕
- **THEN** 系統執行 `DismissPickerIntent`，清除 picker mode，Widget 返回班次模式，路線維持不變

#### Scenario: iOS 16 站名為純文字
- **WHEN** 使用者在 iOS 16 裝置查看 widget
- **THEN** 出發站 / 到達站顯示為「出發站 → 到達站」純文字，無底線，不可點擊；選站功能不可用

---

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

## ADDED Requirements

### Requirement: API 逾時與頻率超限的錯誤處理
系統 SHALL 在 TDX API 連線逾時或回傳 HTTP 429 時，向使用者顯示明確的錯誤訊息並提供重試機會，不得靜默顯示「查無班次」。

#### Scenario: 連線逾時顯示錯誤狀態
- **WHEN** TDX API 請求觸發 `connectionTimeout`、`receiveTimeout` 或 `sendTimeout` 時
- **THEN** `TimetableBloc` 進入 `error` 狀態並顯示「連線逾時，請檢查網路後重試」，UI 顯示重試按鈕，不得進入 `empty` 狀態

#### Scenario: HTTP 429 顯示頻率超限提示
- **WHEN** TDX API 回傳 HTTP 429 Too Many Requests 時
- **THEN** Repository 拋出含「API 請求頻率超限，請稍後再試」訊息的 `DioException`，`TimetableBloc` 進入 `error` 狀態顯示該訊息

#### Scenario: Dio 連線逾時設定
- **WHEN** Dio client 初始化時
- **THEN** `connectTimeout` 與 `receiveTimeout` 均設定為 30 秒，以容納 THSR DailyTimetable OD 端點的較長回應時間

## MODIFIED Requirements

### Requirement: 查詢台鐵班次時刻表
系統 SHALL 透過 TDX API 查詢指定日期、出發站與到達站之間的所有班次，並同步取得票價資料填入每個班次。

#### Scenario: 成功取得班次列表（含票價）
- **WHEN** 呼叫 `GET /api/basic/v3/Rail/TRA/DailyTrainTimetable/OD/{Origin}/{Destination}/{TrainDate}` 且 ODFare API 均成功時
- **THEN** 系統回傳班次列表，每筆班次的 `fare` 欄位填入對應列車種類的成人全票金額（單位：新台幣元）；`區間` 與 `區間快` 車種使用「成復」票種金額

#### Scenario: 無班次資料
- **WHEN** API 回傳空列表時
- **THEN** Repository 回傳空列表，不拋出例外

#### Scenario: API 請求失敗
- **WHEN** 時刻表 HTTP 請求回傳非 2xx 狀態碼時
- **THEN** Repository 拋出對應 DomainException，由 BLoC 處理並更新為錯誤狀態

#### Scenario: 區間與區間快票價對應成復
- **WHEN** `_trainTypeAbbr()` 收到 `trainTypeName` 包含「區間快」或「區間」的字串時
- **THEN** 函式回傳 `'復'`，使 `fareMap['復']` 取得「成復」成人全票金額填入 `Train.fare`

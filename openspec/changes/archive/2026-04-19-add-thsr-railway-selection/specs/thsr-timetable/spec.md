## ADDED Requirements

### Requirement: 查詢高鐵 OD 時刻表
系統 SHALL 透過 TDX API 查詢指定日期、出發站與到達站之間的所有高鐵班次，並同步取得票價資料填入每個班次。

#### Scenario: 成功取得高鐵班次列表（含票價）
- **WHEN** 呼叫 `GET /api/basic/v2/Rail/THSR/DailyTimetable/OD/{OriginStationID}/to/{DestinationStationID}/{TrainDate}` 且 ODFare API 均成功時
- **THEN** 系統回傳高鐵班次列表，每筆班次包含出發時間、到達時間、車次號碼、行車時間、標準車廂票價

#### Scenario: 高鐵無班次資料
- **WHEN** THSR API 回傳空列表時
- **THEN** Repository 回傳空列表，不拋出例外

#### Scenario: 高鐵 API 請求失敗
- **WHEN** 高鐵時刻表 HTTP 請求回傳非 2xx 狀態碼時
- **THEN** Repository 拋出對應例外，由 BLoC 處理並更新為錯誤狀態

### Requirement: 查詢高鐵 OD 票價
系統 SHALL 透過 TDX API 查詢高鐵指定 OD 的票價，取商務車廂與標準車廂成人票價。

#### Scenario: 成功取得高鐵票價
- **WHEN** 呼叫 `GET /api/basic/v2/Rail/THSR/ODFare/{OriginStationID}/to/{DestinationStationID}` 成功時
- **THEN** 系統回傳票價資料，`Train.fare` 填入標準車廂成人全票金額

#### Scenario: 高鐵票價 API 失敗時降級
- **WHEN** THSR ODFare API 請求失敗時
- **THEN** Repository 捕捉例外並回傳 fare = 0，不影響班次列表顯示

### Requirement: 取得高鐵車站列表
系統 SHALL 從 TDX API 取得高鐵完整車站列表並快取，供車站選擇器使用。

#### Scenario: 取得高鐵車站列表
- **WHEN** 呼叫 `GET /api/basic/v2/Rail/THSR/Station` 成功時
- **THEN** 系統回傳所有高鐵車站（共 12 站），包含站名（中文）與站代碼

#### Scenario: 使用快取高鐵車站列表
- **WHEN** 高鐵車站列表已快取且首頁 BLoC 已載入時
- **THEN** 系統直接使用快取資料，不重新請求 API

### Requirement: THSR Repository 以 Retrofit 實作
系統 SHALL 透過 `TdxThsrApiService`（Retrofit abstract class）存取所有 THSR API，並以 `ThsrTimetableRepositoryImpl` 實作 `ThsrTimetableRepository` 介面。

#### Scenario: THSR Retrofit interface 定義
- **WHEN** 呼叫 THSR 相關 API 時
- **THEN** 使用 `TdxThsrApiService` 以 `@RestApi` 注釋的 abstract class，由 `retrofit_generator` code generation 產生實作

#### Scenario: THSR DTO 使用 json_serializable
- **WHEN** Retrofit 反序列化 THSR API 回應時
- **THEN** THSR 相關 DTO 皆有 `@JsonSerializable` 注釋，支援正確的欄位對應

### Requirement: ThsrTimetableRepository 單元測試
`ThsrTimetableRepositoryImpl` 的所有公開方法 SHALL 有對應單元測試，覆蓋成功、空結果、失敗降級情境。

#### Scenario: getDailyTimetable 成功情境測試
- **WHEN** mock `TdxThsrApiService` 回傳有效時刻表與票價資料時
- **THEN** 測試驗證 `ThsrTimetableRepositoryImpl.getDailyTimetable` 回傳正確 `List<Train>`

#### Scenario: getDailyTimetable 票價失敗降級測試
- **WHEN** mock `TdxThsrApiService.getODFare` 拋出例外時
- **THEN** 測試驗證 `getDailyTimetable` 仍回傳班次列表，`fare` 為 0

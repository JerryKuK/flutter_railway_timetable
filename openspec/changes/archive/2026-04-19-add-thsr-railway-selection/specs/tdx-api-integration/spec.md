## ADDED Requirements

### Requirement: 查詢高鐵 OD 時刻表 API
系統 SHALL 透過 `TdxThsrApiService` 以 Retrofit 呼叫 THSR OD 時刻表 API，取得指定日期出發站至到達站的所有班次。

#### Scenario: THSR DailyTimetable API 呼叫
- **WHEN** 呼叫 `GET /api/basic/v2/Rail/THSR/DailyTimetable/OD/{OriginStationID}/to/{DestinationStationID}/{TrainDate}` 時
- **THEN** Retrofit 以 `TdxThsrTimetableResponseDto` 反序列化回應，包含班次列表與各班次出發/到達時間

#### Scenario: THSR DailyTimetable 404 視為空結果
- **WHEN** API 回傳 404 狀態碼時
- **THEN** Repository 回傳空列表，不拋出例外

### Requirement: 查詢高鐵 OD 票價 API
系統 SHALL 透過 `TdxThsrApiService` 呼叫 THSR ODFare API，取得商務與標準車廂成人票價。

#### Scenario: THSR ODFare API 呼叫
- **WHEN** 呼叫 `GET /api/basic/v2/Rail/THSR/ODFare/{OriginStationID}/to/{DestinationStationID}` 時
- **THEN** Retrofit 以 `List<TdxThsrODFareItemDto>` 反序列化，包含 `TicketType`（商務/標準/幼兒）與 `Price`

#### Scenario: THSR ODFare 失敗降級
- **WHEN** ODFare API 請求失敗（非 2xx 或網路錯誤）時
- **THEN** Repository 捕捉例外並回傳 fare = 0，不影響班次列表顯示

### Requirement: 取得高鐵車站列表 API
系統 SHALL 透過 `TdxThsrApiService` 呼叫 THSR Station API，取得完整高鐵車站清單。

#### Scenario: THSR Station API 呼叫
- **WHEN** 呼叫 `GET /api/basic/v2/Rail/THSR/Station` 成功時
- **THEN** Retrofit 以 `List<TdxThsrStationDto>` 反序列化，包含 `StationID` 與 `StationName.Zh_tw`

### Requirement: TdxThsrApiService Retrofit 介面型別安全
所有 THSR API 呼叫 SHALL 透過 `TdxThsrApiService`（`@RestApi` abstract class）進行，由 `retrofit_generator` 產生實作。

#### Scenario: TdxThsrApiService 定義
- **WHEN** 呼叫 THSR 相關 API 時
- **THEN** 使用 `TdxThsrApiService` 以 `@RestApi(baseUrl: 'https://tdx.transportdata.tw')` 注釋的 abstract class，共用現有 `TdxAuthInterceptor`

#### Scenario: THSR DTO 使用 json_serializable
- **WHEN** Retrofit 反序列化 THSR API 回應時
- **THEN** `TdxThsrTimetableResponseDto`、`TdxThsrStationDto`、`TdxThsrODFareItemDto` 皆有 `@JsonSerializable` 注釋

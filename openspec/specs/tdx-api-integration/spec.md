## Requirements

### Requirement: TDX OAuth2 Token 取得
系統 SHALL 在每次 API 請求前檢查 Bearer token 是否有效，若過期則自動重新取得。

#### Scenario: 取得新 Token
- **WHEN** Token 不存在或已過期時
- **THEN** 系統向 TDX token endpoint 發送 client_credentials 請求，並快取回傳的 access_token 及 expires_in

#### Scenario: 使用快取 Token
- **WHEN** Token 尚未過期時
- **THEN** 系統直接使用快取 token，不重新請求

### Requirement: 查詢台鐵班次時刻表
系統 SHALL 透過 TDX API 查詢指定日期、出發站與到達站之間的所有班次，並同步取得票價資料填入每個班次。

#### Scenario: 成功取得班次列表（含票價）
- **WHEN** 呼叫 `GET /api/basic/v3/Rail/TRA/DailyTrainTimetable/OD/{Origin}/{Destination}/{TrainDate}` 且 ODFare API 均成功時
- **THEN** 系統回傳班次列表，每筆班次的 `fare` 欄位填入對應列車種類的成人全票金額（單位：新台幣元）

#### Scenario: 無班次資料
- **WHEN** API 回傳空列表時
- **THEN** Repository 回傳空列表，不拋出例外

#### Scenario: API 請求失敗
- **WHEN** 時刻表 HTTP 請求回傳非 2xx 狀態碼時
- **THEN** Repository 拋出對應 DomainException，由 BLoC 處理並更新為錯誤狀態

### Requirement: 查詢台鐵 OD 票價
系統 SHALL 透過 TDX API 查詢指定出發站與到達站之間的票價清單。

#### Scenario: 成功取得票價清單
- **WHEN** 呼叫 `GET /api/basic/v2/Rail/TRA/ODFare/{OriginStationID}/to/{DestinationStationID}` 成功時
- **THEN** 系統回傳依列車種類分類的票價清單，每筆包含 TrainType 代碼與成人全票（AdultFare）金額

#### Scenario: ODFare API 呼叫失敗時降級
- **WHEN** ODFare API 請求失敗（非 2xx 狀態碼或網路錯誤）時
- **THEN** Repository 捕捉例外並回傳空票價 Map，不影響班次列表的正常顯示

#### Scenario: 票價與班次並行查詢
- **WHEN** 呼叫 `getDailyTimetable` 時
- **THEN** 系統以 `Future.wait` 同時發出時刻表與 ODFare 兩支 API，不序列等待

### Requirement: 取得台鐵車站列表
系統 SHALL 在首次啟動時從 TDX API 取得完整車站列表並快取於本地端，供站點搜尋使用。

#### Scenario: 取得車站列表
- **WHEN** 呼叫 `GET /api/basic/v3/Rail/TRA/Station` 成功時
- **THEN** 系統回傳所有台鐵車站列表，包含站名（中文）與站代碼

#### Scenario: 使用快取車站列表
- **WHEN** 車站列表已快取時
- **THEN** 系統直接使用快取資料，不重新請求 API

### Requirement: envied 憑證管理
系統 SHALL 使用 `envied` 套件管理 TDX Client ID 與 Client Secret，於編譯期混淆，不以明文存於 binary 中。

#### Scenario: 憑證從 .env 讀取
- **WHEN** 應用程式啟動時
- **THEN** `Env.tdxClientId` 與 `Env.tdxClientSecret` 提供正確憑證值，供 `TdxAuthInterceptor` 使用

#### Scenario: .env 檔案不在版本控制中
- **WHEN** 查看 git tracked 檔案
- **THEN** `.env` 與 `lib/core/env/env.g.dart` 均在 `.gitignore` 中，不被追蹤

### Requirement: Retrofit API Interface 型別安全
所有 TDX API 呼叫 SHALL 透過 Retrofit 定義的 type-safe interface 進行，不得直接使用裸 Dio 呼叫。

#### Scenario: Retrofit interface 定義
- **WHEN** 呼叫 TRA 相關 API 時
- **THEN** 使用 `TdxTraApiService` 以 `@RestApi` 注釋的 abstract class，由 `retrofit_generator` code generation 產生 `_TdxTraApiService` 實作

#### Scenario: DTO 使用 json_serializable
- **WHEN** Retrofit 反序列化 TDX API 回應時
- **THEN** `TdxTrainTimetableDto` 與 `TdxStationDto` 皆有 `@JsonSerializable` 注釋，`MultilingualName` 巢狀類別處理多語系欄位

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
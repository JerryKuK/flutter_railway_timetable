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
系統 SHALL 透過 TDX API 查詢指定日期、出發站與到達站之間的所有班次。

#### Scenario: 成功取得班次列表
- **WHEN** 呼叫 `GET /api/basic/v3/Rail/TRA/DailyTrainTimetable/OD/{Origin}/{Destination}/{TrainDate}` 成功時
- **THEN** 系統回傳班次列表，包含車次號碼、出發時間、抵達時間、票價資訊

#### Scenario: 無班次資料
- **WHEN** API 回傳空列表時
- **THEN** Repository 回傳空列表，不拋出例外

#### Scenario: API 請求失敗
- **WHEN** HTTP 請求回傳非 2xx 狀態碼時
- **THEN** Repository 拋出對應 DomainException，由 BLoC 處理並更新為錯誤狀態

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
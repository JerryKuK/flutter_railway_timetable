## ADDED Requirements

### Requirement: envied 憑證管理
系統 SHALL 使用 `envied` 套件管理 TDX Client ID 與 Client Secret，於編譯期混淆，不以明文存於 binary 中。

#### Scenario: 憑證從 .env 讀取
- **WHEN** 應用程式啟動時
- **THEN** `Env.tdxClientId` 與 `Env.tdxClientSecret` 提供正確憑證值，供 `TdxAuthInterceptor` 使用

#### Scenario: .env 檔案不在版本控制中
- **WHEN** 查看 git tracked 檔案
- **THEN** `.env` 與 `lib/core/env/env.g.dart` 均在 `.gitignore` 中，不被追蹤

## MODIFIED Requirements

### Requirement: Retrofit API Interface 型別安全
所有 TDX API 呼叫 SHALL 透過 Retrofit 定義的 type-safe interface 進行，不得直接使用裸 Dio 呼叫。

#### Scenario: Retrofit interface 定義
- **WHEN** 呼叫 TRA 相關 API 時
- **THEN** 使用 `TdxTraApiService` 以 `@RestApi` 注釋的 abstract class，由 `retrofit_generator` code generation 產生 `_TdxTraApiService` 實作

#### Scenario: DTO 使用 json_serializable
- **WHEN** Retrofit 反序列化 TDX API 回應時
- **THEN** `TdxTrainTimetableDto` 與 `TdxStationDto` 皆有 `@JsonSerializable` 注釋，`MultilingualName` 巢狀類別處理多語系欄位
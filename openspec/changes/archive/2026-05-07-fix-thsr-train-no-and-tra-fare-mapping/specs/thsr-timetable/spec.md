## MODIFIED Requirements

### Requirement: THSR Repository 以 Retrofit 實作
系統 SHALL 透過 `TdxThsrApiService`（Retrofit abstract class）存取所有 THSR API，並以 `ThsrTimetableRepositoryImpl` 實作 `ThsrTimetableRepository` 介面。

#### Scenario: THSR Retrofit interface 定義
- **WHEN** 呼叫 THSR 相關 API 時
- **THEN** 使用 `TdxThsrApiService` 以 `@RestApi` 注釋的 abstract class，由 `retrofit_generator` code generation 產生實作

#### Scenario: THSR DTO 使用 json_serializable 並正確對應巢狀結構
- **WHEN** Retrofit 反序列化 THSR DailyTimetable OD API 回應時
- **THEN** `TdxThsrDailyTrainDto` 包含 `dailyTrainInfo: TdxThsrDailyTrainInfoDto?` 欄位（對應 JSON 的 `DailyTrainInfo`），`TdxThsrDailyTrainInfoDto` 包含 `TrainNo`（`String`）與 `TrainTypeName`（`TdxThsrMultilingualName?`）

#### Scenario: TrainNo 正確填入 Train entity
- **WHEN** `ThsrTimetableRepositoryImpl.getDailyTimetable` 將 DTO 轉換為 `Train` entity 時
- **THEN** `Train.trainNo` 填入 `dto.dailyTrainInfo?.trainNo ?? ''`，`Train.trainTypeName` 填入 `dto.dailyTrainInfo?.trainTypeName?.zhTw ?? '高鐵'`，使班次卡片顯示如「高鐵 #0601」

### Requirement: ThsrTimetableRepository 單元測試
`ThsrTimetableRepositoryImpl` 的所有公開方法 SHALL 有對應單元測試，覆蓋成功、空結果、失敗降級情境。

#### Scenario: getDailyTimetable 成功情境測試
- **WHEN** mock `TdxThsrApiService` 回傳有效時刻表資料時（`DailyTrainInfo` 巢狀包含 `TrainNo`）
- **THEN** 測試驗證 `ThsrTimetableRepositoryImpl.getDailyTimetable` 回傳正確 `List<Train>`，且 `Train.trainNo` 與 `Train.trainTypeName` 均非空字串

#### Scenario: getDailyTimetable 票價失敗降級測試
- **WHEN** mock `TdxThsrApiService.getODFare` 拋出例外時
- **THEN** 測試驗證 `getDailyTimetable` 仍回傳班次列表，`fare` 為 0

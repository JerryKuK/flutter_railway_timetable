## ADDED Requirements

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

## MODIFIED Requirements

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
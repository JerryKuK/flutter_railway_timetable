## Why

時刻表頁面的班次卡片已定義顯示票價（格式 NT$ XXX）的需求，但目前實作中票價欄位為空白或缺失，因為 TDX v3 的 `DailyTrainTimetable` API 本身不包含票價資料，需要額外呼叫 OD Fare 端點才能取得。

## What Changes

- 新增 Retrofit 端點定義：`GET /v2/Rail/TRA/ODFare/{OriginStationID}/to/{DestinationStationID}`
- 新增 `TdxODFareDto` DTO 及其 JSON 序列化
- 更新 `TimetableRepository`，在取得班次列表的同時也查詢票價，並將票價對應至每個班次
- 更新 `TrainSchedule` Domain Model，確保 `fare` 欄位從 OD Fare API 填入
- 更新時刻表頁面班次卡片，正確顯示票價（格式 NT$ XXX）

## Capabilities

### New Capabilities

_無_

### Modified Capabilities

- `tdx-api-integration`：新增 `ODFare` API endpoint 至 `TdxTraApiService`，新增對應 DTO，Repository 層需同步呼叫班次與票價兩支 API
- `timetable-screen`：班次卡片需從 Domain Model 正確讀取票價並顯示，補足現有規格中已定義但未實作的「票價（格式 NT$ XXX）」需求

## Impact

- **新增檔案**：`TdxODFareDto`（DTO）、對應 `.g.dart` generated file
- **修改檔案**：`TdxTraApiService`（Retrofit interface）、`TimetableRepository`（資料層）、`TrainSchedule`（domain model，若 fare 欄位尚未存在）、時刻表班次卡片 Widget
- **API 版本**：OD Fare 使用 v2 端點（`/api/basic/v2/Rail/TRA/ODFare/...`），與現有 v3 班次查詢並存
- **依賴**：無新套件需求，沿用現有 Retrofit + json_serializable + Dio 架構
- **測試**：使用superpowers來遵循 TDD 開發流程，每個 use case 和 BLoC 需有對應單元測試
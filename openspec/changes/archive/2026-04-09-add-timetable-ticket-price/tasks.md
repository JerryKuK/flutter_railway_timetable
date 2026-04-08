## 1. DTO 層：新增 ODFare 資料模型

- [x] 1.1 在 `lib/features/timetable/data/dto/tdx_response_dto.dart` 新增 `TdxODFareResponseDto`、`TdxODFareItemDto`、`TdxFareDto` 三個 class，加上 `@JsonSerializable` 注釋與對應 JSON Key mapping
- [x] 1.2 執行 `dart run build_runner build --delete-conflicting-outputs` 重新產生 `tdx_response_dto.g.dart`

## 2. API 層：新增 Retrofit 端點

- [x] 2.1 在 `TdxTraApiService` 新增 `getODFare` 方法：`GET /api/basic/v2/Rail/TRA/ODFare/{originStationId}/to/{destinationStationId}`，回傳 `Future<List<TdxODFareItemDto>>`
- [x] 2.2 執行 `dart run build_runner build --delete-conflicting-outputs` 重新產生 `tdx_tra_api_service.g.dart`

## 3. TDD：Repository 單元測試

- [x] 3.1 在 `test/features/timetable/data/repository/` 新增或更新 `timetable_repository_impl_test.dart`，新增測試案例：「getDailyTimetable 成功時 fare 欄位帶有 ODFare 回傳值」
- [x] 3.2 新增測試案例：「ODFare API 失敗時，班次仍正常回傳，fare 為 0」
- [x] 3.3 確認測試在實作前失敗（Red 階段）

## 4. Repository 層：整合票價查詢

- [x] 4.1 在 `TimetableRepositoryImpl.getDailyTimetable` 中，使用 `Future.wait` 並行呼叫 `_apiService.getDailyTimetable` 與 `_apiService.getODFare`
- [x] 4.2 將 ODFare 呼叫包在 try-catch 中，失敗時回傳空 Map（降級處理）
- [x] 4.3 從 ODFare 回應建立 `Map<int, int>`（TrainType → Price），只取 AdultFare / TicketType == "1" 的全票金額
- [x] 4.4 在 `Train` 建構時，透過 `trainInfo.trainTypeID`（或對應欄位）查 fare Map 取得真實票價，找不到時預設 0
- [x] 4.5 執行步驟 3 的測試，確認全部通過（Green 階段）

## 5. TDD：BLoC 單元測試

- [x] 5.1 在 `test/features/timetable/presentation/bloc/` 確認現有 BLoC 測試涵蓋票價資料的狀態傳遞，若無則補充測試案例

## 6. 驗收測試

- [x] 6.1 在 iOS Simulator 上啟動 App，選擇出發站與目的站查詢時刻表，確認班次卡片顯示非零票價（格式 NT$ XXX）
- [x] 6.2 確認 ODFare 失敗降級情境下（可暫時 mock 錯誤）班次列表仍正常顯示，票價顯示 NT$ 0

## 1. THSR DTO 修正（TDD）

- [x] 1.1 撰寫失敗單元測試：mock `TdxThsrDailyTrainDto.fromJson` 使用含 `DailyTrainInfo` 巢狀結構的 JSON，驗證 `trainNo` 非空（TDD 紅燈）
- [x] 1.2 在 `tdx_thsr_response_dto.dart` 新增 `TdxThsrDailyTrainInfoDto`（含 `TrainNo: String`、`TrainTypeName: TdxThsrMultilingualName?`，加上 `@JsonSerializable` 注釋）
- [x] 1.3 更新 `TdxThsrDailyTrainDto`：移除頂層 `trainNo` 與 `trainTypeName`，改新增 `@JsonKey(name: 'DailyTrainInfo') final TdxThsrDailyTrainInfoDto? dailyTrainInfo`
- [x] 1.4 執行 `flutter pub run build_runner build --delete-conflicting-outputs` 重新產生 `tdx_thsr_response_dto.g.dart`
- [x] 1.5 更新 `ThsrTimetableRepositoryImpl.getDailyTimetable`：將 `t.trainNo` 改為 `t.dailyTrainInfo?.trainNo ?? ''`，`t.trainTypeName?.zhTw` 改為 `t.dailyTrainInfo?.trainTypeName?.zhTw ?? '高鐵'`
- [x] 1.6 確認步驟 1.1 的測試通過（TDD 綠燈）

## 2. THSR 單元測試更新

- [x] 2.1 更新 THSR repository 測試中所有 mock `TdxThsrDailyTrainDto`：補上 `DailyTrainInfo` 巢狀 Map（含 `TrainNo`、`TrainTypeName`）
- [x] 2.2 新增測試情境：驗證 `getDailyTimetable` 回傳的 `Train.trainNo` 等於 mock 資料中的 `TrainNo` 值
- [x] 2.3 執行所有 THSR repository 測試，確認全部通過

## 3. TRA 票價對應修正（TDD）

- [x] 3.1 撰寫失敗單元測試：呼叫 `_trainTypeAbbr('區間快')`，驗證回傳 `'復'`（目前回傳 `'普'`，TDD 紅燈）
- [x] 3.2 撰寫失敗單元測試：呼叫 `_trainTypeAbbr('區間')`，驗證回傳 `'復'`
- [x] 3.3 修改 `TimetableRepositoryImpl._trainTypeAbbr()`：將 `區間快` 和 `區間` 的回傳值從 `'普'` 改為 `'復'`
- [x] 3.4 確認步驟 3.1、3.2 的測試通過（TDD 綠燈）
- [x] 3.5 執行所有 TRA repository 測試，確認全部通過

## 4. 模擬器驗證

- [x] 4.1 在模擬器上查詢高鐵時刻表，確認班次卡片顯示完整車號（如「高鐵 #0601」）
- [x] 4.2 在模擬器上查詢台鐵時刻表，確認區間與區間快班次票價顯示「成復」對應金額（非「成普」）

## 5. 網路錯誤處理修正（測試過程中發現）

- [x] 5.1 將 `DioClient` 的 `connectTimeout` 與 `receiveTimeout` 從 10s 增至 30s，解決 THSR DailyTimetable 端點偶發逾時問題
- [x] 5.2 修正 `TimetableBloc`：連線逾時（`connectionTimeout` / `receiveTimeout` / `sendTimeout`）由顯示 `empty`（查無班次）改為顯示 `error`（「連線逾時，請檢查網路後重試」）
- [x] 5.3 在 `ThsrTimetableRepositoryImpl` 與 `TimetableRepositoryImpl` 加入 HTTP 429 處理：攔截後拋出含「API 請求頻率超限，請稍後再試」訊息的 `DioException`，讓使用者看到明確提示而非靜默失敗

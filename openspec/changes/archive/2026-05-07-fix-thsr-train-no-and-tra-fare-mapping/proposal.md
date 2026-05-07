## Why

高鐵時刻表每筆班次顯示「高鐵 #」而非實際車號（如「高鐵 #0601」），原因是 `TdxThsrDailyTrainDto` 在頂層解析 `TrainNo`，但 TDX THSR DailyTimetable OD v2 API 實際將 `TrainNo` 與 `TrainTypeName` 巢狀於 `DailyTrainInfo` 物件內，導致永遠拿到空字串。此外，台鐵時刻表的 `區間` 與 `區間快` 車種票價對應至「成普」，但正確應對應「成復」。

## What Changes

- **新增 `TdxThsrDailyTrainInfoDto`**：包含 `TrainNo`（`String`）與 `TrainTypeName`（`TdxThsrMultilingualName?`），對應 API 回應中的 `DailyTrainInfo` 巢狀物件
- **更新 `TdxThsrDailyTrainDto`**：移除頂層 `TrainNo` 與 `TrainTypeName` 欄位，改以 `dailyTrainInfo: TdxThsrDailyTrainInfoDto?` 欄位取代
- **更新 `ThsrTimetableRepositoryImpl`**：從 `t.dailyTrainInfo?.trainNo` 與 `t.dailyTrainInfo?.trainTypeName?.zhTw` 取值
- **重新產生 `tdx_thsr_response_dto.g.dart`**：執行 `build_runner` 以反映 DTO 結構變更
- **修正 `TimetableRepositoryImpl._trainTypeAbbr()`**：將 `區間` 與 `區間快` 從回傳 `'普'` 改為回傳 `'復'`

## Capabilities

### New Capabilities
<!-- 無新能力，此 change 為 bug fix -->

### Modified Capabilities
- `thsr-timetable`：修正 DTO 解析結構，使 `Train.trainNo` 能正確反映 API 回應的 `DailyTrainInfo.TrainNo` 欄位
- `tdx-api-integration`：修正 TRA 票價對應邏輯，`區間` 與 `區間快` 車種應使用「成復」票種而非「成普」

## Impact

- `lib/features/timetable/data/dto/tdx_thsr_response_dto.dart`：新增 `TdxThsrDailyTrainInfoDto`，重構 `TdxThsrDailyTrainDto`
- `lib/features/timetable/data/dto/tdx_thsr_response_dto.g.dart`：需重新產生
- `lib/features/timetable/data/repository/thsr_timetable_repository_impl.dart`：更新存取路徑
- `lib/features/timetable/data/repository/timetable_repository_impl.dart`：修正 `_trainTypeAbbr()` 對應
- 相關單元測試需更新 mock 資料結構以反映 `DailyTrainInfo` 巢狀
- **測試**：使用superpowers來遵循 TDD 開發流程，每個 use case 和 BLoC 需有對應單元測試
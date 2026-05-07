## Context

### THSR TrainNo 未顯示

TDX THSR DailyTimetable OD v2 API 的回應結構為：

```json
{
  "TrainDate": "2026-05-07",
  "DailyTrainInfo": {
    "TrainNo": "0601",
    "TrainTypeName": { "Zh_tw": "高鐵", "En": "THSR" }
  },
  "OriginStopTime": { "DepartureTime": "...", "ArrivalTime": "..." },
  "DestinationStopTime": { "DepartureTime": "...", "ArrivalTime": "..." }
}
```

現有 `TdxThsrDailyTrainDto` 把 `TrainNo` 和 `TrainTypeName` 定義為頂層 `@JsonKey`，導致 `json_serializable` 產生的解析碼在頂層找不到這兩個欄位，永遠回傳預設空字串。`OriginStopTime` 與 `DestinationStopTime` 則在頂層，解析正確。

### TRA 票種對應錯誤

`TimetableRepositoryImpl._trainTypeAbbr()` 將 `區間` 和 `區間快` 映射至 `'普'`（對應「成普」票種）。但 TDX ODFare API 對這兩種車型的正確票種為「成復」（key `'復'`）。

## Goals / Non-Goals

**Goals:**
- 修正 `TdxThsrDailyTrainDto` 以正確解析 `DailyTrainInfo` 巢狀物件中的 `TrainNo` 與 `TrainTypeName`
- 修正 `_trainTypeAbbr()` 使 `區間` 與 `區間快` 對應 `'復'`

**Non-Goals:**
- 不修改其他車種的票種對應
- 不調整 UI 元件或顯示格式
- 不更動 THSR ODFare 或 Station API 邏輯

## Decisions

### 決策 1：新增 `TdxThsrDailyTrainInfoDto` wrapper DTO

**選擇**：新增一個 `TdxThsrDailyTrainInfoDto` 類別（包含 `TrainNo`、`TrainTypeName`），並在 `TdxThsrDailyTrainDto` 中以 `@JsonKey(name: 'DailyTrainInfo')` 對應。

**替代方案考慮**：
- ❌ 手動修改 `.g.dart`：產生的檔案不應手動編輯，下次 `build_runner` 執行會覆蓋
- ❌ 使用 `@JsonKey(fromJson:)` 自訂解析函式：增加複雜性，且違反 `json_serializable` 慣例
- ✅ 新增巢狀 DTO：與現有 `TdxThsrStopTimeDto` 模式一致，build_runner 自動產生解析碼

### 決策 2：直接修改 `_trainTypeAbbr()` 回傳值

**選擇**：在 `TimetableRepositoryImpl._trainTypeAbbr()` 裡，將 `區間` 和 `區間快` 從回傳 `'普'` 改為回傳 `'復'`。

**替代方案考慮**：
- ❌ 建立票種對應 Map 取代 if-else：改動範圍超出 bug fix 需要
- ✅ 直接修改：最小變動，影響範圍僅此函式

## Risks / Trade-offs

- **[Risk] build_runner 未執行**：若修改 DTO 後忘記跑 `flutter pub run build_runner build --delete-conflicting-outputs`，`.g.dart` 仍是舊版，編譯會失敗
  → Mitigation：tasks.md 明確列出 build_runner 步驟

- **[Risk] 其他 OD 路線的 ODFare API 可能無「成復」票種**：若特定路線沒有 `'復'` key，`fareMap['復']` 回傳 null，票價顯示為 0
  → Mitigation：現有降級邏輯（fare = 0）已處理此情境，行為與修改前一致

- **[Risk] 現有單元測試的 mock 資料**：THSR repository 測試的 mock DTO 須更新為包含 `DailyTrainInfo` 巢狀結構
  → Mitigation：tasks.md 明確列出測試更新步驟

## Migration Plan

1. 更新 `TdxThsrDailyTrainInfoDto` 與 `TdxThsrDailyTrainDto`
2. 執行 `build_runner` 重新產生 `.g.dart`
3. 更新 `ThsrTimetableRepositoryImpl` 存取路徑
4. 更新相關單元測試 mock 資料
5. 修改 `_trainTypeAbbr()` 對應
6. 在模擬器上驗證高鐵車號顯示與台鐵票價
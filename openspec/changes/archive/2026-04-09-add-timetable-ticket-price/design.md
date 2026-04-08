## Context

`Train` entity 已有 `fare: int` 欄位，`TrainCardWidget` 也已有 `'NT\$ ${train.fare}'` 的顯示邏輯，但 `TimetableRepositoryImpl.getDailyTimetable` 直接 hardcode `fare: 0`。

TDX v3 的 `DailyTrainTimetable` API 不含票價資料，需另呼叫 TDX v2 的 ODFare endpoint：
`GET /api/basic/v2/Rail/TRA/ODFare/{OriginStationID}/to/{DestinationStationID}`

此端點回傳出發站至到達站之間的票價清單，每筆包含 `TicketType`（兩字中文代碼，如 `成自`、`成莒`）與 `Price`。`TicketType` 首字為票種（`成`=成人）、次字為車種縮寫（`自`=自強、`莒`=莒光、`復`=復興、`普`=普快/區間）。

## Goals / Non-Goals

**Goals:**
- 從 TDX ODFare API 取得真實票價並顯示於時刻表班次卡片
- 票價查詢與班次查詢並行執行，不增加整體等待時間
- 依列車種類縮寫（TicketType 次字元）對應票價至各班次

**Non-Goals:**
- 不顯示學生票、兒童票等非全票（AdultFare）票種
- 不依座位等級（對號/自由座）區分票價
- 不快取票價資料（每次查詢時重新取得）

## Decisions

### 決策 1：並行呼叫 API（`Future.wait`）

在 `TimetableRepositoryImpl.getDailyTimetable` 中，使用 `Future.wait` 同時發出時刻表與票價兩支 API，避免序列呼叫增加延遲。`_fetchODFareMap` 內部已捕捉所有例外並回傳空 Map，確保 `Future.wait` 不因票價失敗而中止整體查詢。

**替代方案**：序列呼叫（先票價後班次） — 放棄，因為會讓頁面載入時間倍增。

### 決策 2：以 TicketType 字串次字元對應票價

TDX ODFare v2 實際回應的 `TicketType` 為兩字中文代碼（如 `成自`、`成莒`），**沒有**整數 TrainType 欄位（初始設計假設有誤，已根據實際 API 回應修正）。

**實作策略**：
1. 篩選 `TicketType.length == 2 && startsWith('成')` 的全票，取 `ticketType[1]` 為車種縮寫 key，建立 `Map<String, int>`（如 `{'自': 480, '莒': 380, '復': 280, '普': 167}`）
2. 透過 `_trainTypeAbbr(trainTypeName)` 將列車名稱（如 `自強(3000)(EMU3000 型電車)`）對應至縮寫字元

車種對應規則：
- `自強`、`太魯閣`、`普悠瑪`、`EMU`、`TEMU` → `自`
- `莒光` → `莒`
- `復興` → `復`
- `普快`、`普通`、`區間快`、`區間` → `普`

**放棄整數代碼**：TDX ODFare v2 回應中不存在 `TrainType` 整數欄位；`TicketType` 字串次字元方案更直接且不依賴推導映射。

### 決策 3：票價找不到時降級為 0

若某班次的車種縮寫在 ODFare 回應中找不到對應票價（例如特殊加班車），`fare` 維持 0，UI 顯示 `NT\$ 0`（現有行為不變）。不拋出例外，確保票價失敗不影響班次顯示。

### 決策 4：新增 DTO 至現有 `tdx_response_dto.dart`

ODFare 的 DTO（`TdxODFareResponseDto`、`TdxODFareDto`、`TdxFareDto`）加入現有的 `tdx_response_dto.dart`，維持單一 DTO 檔案的架構慣例，不新增獨立檔案。

## Risks / Trade-offs

- **[Risk] ODFare API 結構不確定** → 首次整合需實際測試 TDX 回應確認欄位名稱，DTO 欄位需與實際 JSON Key 對齊。降低方式：保守使用 nullable 欄位（`?`），避免解析失敗崩潰。
- **[Risk] 並行呼叫其中一個失敗** → `Future.wait` 若任一 Future 拋出例外會整體失敗。降低方式：將 ODFare 呼叫包在 try-catch，失敗時回傳空 Map，不影響班次顯示。
- **[Trade-off] 不快取票價** → 每次查詢都呼叫 ODFare API，略增 API 呼叫次數。但票價資料相對靜態，未來可考慮加快取，此次不過度設計。

## Open Questions

~~- TDX ODFare v2 回應的確切 JSON Key 名稱（`TrainType`、`FareClass`、`Price` 等），需實際呼叫確認後調整 DTO。~~
**已解決**：實際回應只有 `TicketType`（中文字串）與 `Price`（整數），無 `FareClass` 或整數 `TrainType`。DTO 已對應調整。
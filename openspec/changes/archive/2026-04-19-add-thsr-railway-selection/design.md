## Context

App 目前僅有 TRA（台鐵）時刻表功能。`TimetableRepository` 和 `TdxTraApiService` 皆以台鐵 API 設計，`HomeBloc` 的車站清單與查詢流程只有單一鐵路系統。

Claude Design 設計稿定義了「高鐵 / 台鐵」分段切換器的視覺規格：毛玻璃 segmented control 放置在 header 頂部，台鐵=藍色系、高鐵=橘金色系，切換時整體配色同步更新。

## Goals / Non-Goals

**Goals:**
- 在首頁加入高鐵 / 台鐵切換，UI 配色隨系統切換
- 以 Retrofit 新增 `TdxThsrApiService`，涵蓋 THSR 車站、時刻表、票價 API
- 新增 `ThsrTimetableRepository`，不修改既有 `TimetableRepository`
- `HomeBloc` 新增 `railwayType` 狀態，車站清單依系統分別快取
- 時刻表頁面依 `railwayType` route param 路由至正確 repository
- 每個新 use case 與 BLoC 變更皆有對應單元測試（TDD 流程）

**Non-Goals:**
- 高鐵座位選擇、訂票、會員整合
- 離線快取（超出本次範圍）
- 即時到站資訊

## Decisions

### 1. 分離 Repository 而非共用介面

**決策：** 新增獨立的 `ThsrTimetableRepository` 介面與 `ThsrTimetableRepositoryImpl`，不修改現有 `TimetableRepository`。

**理由：** THSR API 回應結構與 TRA 差異明顯（DailyTimetable vs DailyTrainTimetable、票種命名不同），若共用介面需在實作層做大量條件判斷，降低可讀性。分離 repository 符合 ISP 原則，也避免對現有 TRA 功能引入回歸風險。

**替代方案：** 在 `TimetableRepository` 加入 `railwayType` 參數 → 拒絕，會讓介面語意不清，且 DI 的 `@LazySingleton` 無法區分兩種實作。

### 2. HomeState 使用 enum RailwayType

**決策：** 新增 `enum RailwayType { tra, hsr }`，`HomeState` 的 `railwayType` 欄位使用此 enum，並分別維護 `traStations` 和 `hsrStations` 兩個清單。

**理由：** 用 enum 而非字串可以讓編譯器在所有 switch 處檢查窮舉，避免打字錯誤。分開快取兩組車站可以讓切換後立即顯示，不需重新 API 請求。

**替代方案：** 單一 `stations` 清單，切換時重新載入 → 拒絕，切換體驗差，且 TRA 有 500+ 站切換回來需重載。

### 3. 時刻表頁面透過 route extra 接收 railwayType

**決策：** `HomeBloc` 在 search 時將 `railwayType` 放入 `GoRouter` 的 `extra` map；`AppRouter` 在 `/timetable` route 中從 extra 解析 `railwayType`，並傳入 `TimetablePage` 建構式；`TimetablePage` 依此選擇注入 `ThsrTimetableRepository` 或 `TimetableRepository`。

**理由：** route extra 是導航當下的快照，保證 TimetablePage 使用的 repository 與查詢時的選擇一致，不受頁面停留期間 global state 變動影響。UI 配色仍透過 `RailwayTypeCubit` 驅動，維持頁面標題/漸層可響應 cubit 的彈性。

**替代方案：** `TimetableBloc` 內部持有兩個 repository，依 type 切換 → 拒絕，讓 BLoC 承擔 DI 責任。

### 4. THSR 票價對應

**決策：** THSR ODFare API 回傳 `TicketType`（商務/標準/幼兒等），取「商務車廂」與「標準車廂」的成人票價填入 `Train.fare`。列車類型以 `DailyTimetable.DailyTrainInfo.TrainTypeName` 對應（目前高鐵只有單一車種，fare 由 seat class 區分）。

**理由：** 高鐵票價依座位等級而非列車種類，與台鐵邏輯不同，需在 mapper 層明確處理。

### 5. 配色以 RailwayTheme static factory 傳遞

**決策：** 新增 `RailwayTheme` data class（包含 `headerGradient`、`accent`、`accentSoft` 等），以 `RailwayTheme.of(railwayType)` 靜態工廠取得對應主題，並以參數傳遞給需要配色的 widget。

**理由：** 靜態工廠比 `ThemeExtension` 更輕量、無需在所有 widget 測試中設定 `MaterialApp` 的 `ThemeExtension`。`StationInputWidget`、`SearchButton` 等 widget 直接接收 `RailwayTheme` 物件，不需感知 `railwayType` enum，符合單一職責。

**替代方案：** `Theme.of(context).extension<RailwayTheme>()` → 拒絕，在 widget 測試中需額外補上 extension 設定，增加測試負擔。

## Risks / Trade-offs

- **THSR DailyTimetable v2 回應結構未完整驗證** → 先以 TDX 文件為準撰寫 DTO，上線前以真實 API 回應驗證 JSON key 名稱。
- **THSR 車站數少（12 站）無城市分組 UI** → Station Picker 高鐵模式不顯示城市 chips（或僅顯示縣市作為 label），避免 UI 過度複雜。
- **`ThemeExtension` 在現有 widget 測試中不存在** → widget 測試需在 `MaterialApp` 中補上 `ThemeExtension` 預設值。

## Migration Plan

1. 新增 THSR DTO、Retrofit service、repository（不影響現有代碼）
2. 更新 DI 模組，執行 `flutter pub run build_runner build`
3. 新增 `RailwayType` enum，更新 `HomeState` / `HomeBloc` / `HomeEvent`
4. 更新 `HomePage` UI（加入 segmented control、`RailwayTheme`）
5. 更新 `AppRouter`：`/timetable` extra 加入 `railwayType`，`BlocProvider.create` 依值選擇 repository
6. 更新 iOS/Android App 名稱
7. 更新 README.md

回滾：feature flag 不適用；若發布後發現問題，透過 hotfix 將 `railwayType` 預設值鎖定為 `tra`。

## Open Questions

- THSR `DailyTimetable` v2 端點是否需要 `$top` 參數限制筆數？（TRA v3 不需要）
- 高鐵「商務 / 標準」票價是否應分兩行顯示在車次卡片，或只顯示標準票價？

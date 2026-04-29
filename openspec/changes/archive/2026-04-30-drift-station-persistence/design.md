## Context

目前 `SharedPreferencesRecentSearchRepository` 將所有查詢紀錄序列化為 JSON 字串列表，所有鐵路類型混存在同一個 key。`clearAll()` 無法按類型清除，首頁站台選擇完全不持久化（每次回到預設值）。這次以 Drift（SQLite）取代 SharedPreferences，提供結構化查詢與兩張獨立資料表。

---

## Goals / Non-Goals

**Goals:**
- 用 Drift 取代 SharedPreferences 作為唯一本地儲存層
- `RecentSearches` 表以 `railwayType` 欄位隔離 TRA / HSR，支援按類型清除
- `LastStationSelections` 表以 `railwayType` 為主鍵，持久化各系統出發／到達站
- 首頁 BLoC 初始化時從 DB 讀取上次選擇的站台（取代寫死預設值）
- 切換鐵路類型時載入對應系統的上次選擇站台

**Non-Goals:**
- 將舊 SharedPreferences 資料遷移至 Drift（捨棄，使用者重新累積）
- 離線時刻表快取（另一個 feature）
- 跨裝置同步

---

## Decisions

### 1. 資料庫 Schema：兩張獨立表格

```
RecentSearches
  id               INTEGER  PK autoincrement
  departureStation TEXT
  arrivalStation   TEXT
  departureStationId TEXT
  arrivalStationId TEXT
  railwayType      TEXT     ('tra' | 'hsr')
  searchedAt       DATETIME

LastStationSelections
  railwayType      TEXT     PK ('tra' | 'hsr')
  departureStation TEXT
  arrivalStation   TEXT
  departureStationId TEXT
  arrivalStationId TEXT
```

**為何不用單一表格**：LastStationSelections 是 upsert 語意（每種類型只保留最新一筆），與 RecentSearches 的 append-and-trim 語意不同，分開表格避免查詢複雜化。

**DataClassName 衝突處理**：Drift 預設把 `RecentSearches` 表的 row class 命名為 `RecentSearch`，與現有 Freezed entity 衝突。解法：在表格定義上標注 `@DataClassName('RecentSearchRow')`，repository 內部轉換為 domain entity。

### 2. RecentSearchRepository 介面擴充，不拆分

在現有 `RecentSearchRepository` 新增三個方法：
- `clearByRailwayType(String railwayType)`
- `Future<Map<String, String>?> getLastStationSelection(String railwayType)`
- `Future<void> saveLastStationSelection({required String railwayType, ...})`

**為何不拆成兩個 Repository**：功能都是「Home Screen 的本地持久化」，拆分會多出一個介面 + 實作 + DI 繫結，邊際效益低。

### 3. `_onSwitchRailwayType` 改為非同步

切換類型時 BLoC handler 先查 `LastStationSelections`，再 emit 新 state。若 DB 無紀錄則 fallback 硬寫預設值。

**為何不在 init 預先載入兩種類型**：不需要在 HomeState 加額外欄位，SQLite 讀取速度足夠，保持 state 精簡。

### 4. 站台選擇存檔時機

在以下 BLoC handlers 呼叫 `saveLastStationSelection`（使用更新後的 state）：
- `_onSwitchRailwayType`（切換前先儲存舊類型的當前選擇，確保切回時能正確還原）
- `_onSelectDepartureStation`
- `_onSelectArrivalStation`
- `_onSwapStations`
- `_onSelectRecentSearch`

**為何不只存在 Search 時**：使用者可能選好站台後離開 App 而不查詢，應保留最後選擇。

### 5. ClearHistory event 攜帶 railwayType

`ClearHistory` 由 `const factory HomeEvent.clearHistory()` 改為 `const factory HomeEvent.clearHistory({required String railwayType})`，home_page.dart 傳入 `state.railwayType.name`。

---

## Risks / Trade-offs

| 風險 | 緩解 |
|------|------|
| 現有使用者升級後近期查詢清空 | 可接受：新功能（站台記憶）補償損失，無需顯示 migration notice |
| build_runner 多個 generator 衝突 | 執行時加 `--delete-conflicting-outputs` |
| Drift DB 檔案首次建立略慢 | 影響僅第一次冷啟動 < 50ms，可忽略 |
| 未來 schema 變更需 migration | 在 `AppDatabase.migration` 預留 `MigrationStrategy`，schemaVersion 從 1 開始 |

---

## Migration Plan

1. 更新 `pubspec.yaml`，執行 `flutter pub get`
2. 建立 `lib/core/database/app_database.dart` 與 `app_database.g.dart`（由 build_runner 產生）
3. 執行 `dart run build_runner build --delete-conflicting-outputs`
4. 依序更新 repository 介面 → 實作 → BLoC events → BLoC → UI
5. 刪除舊 `SharedPreferencesRecentSearchRepository` 類別（injectable 自動解除綁定）
6. 執行全部測試確認無 regression

**Rollback**：git revert 即可，SharedPreferences 資料未被刪除（只是未讀取）。

---

## Open Questions

- 無

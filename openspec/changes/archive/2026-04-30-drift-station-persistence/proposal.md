## Why

目前以 `shared_preferences` 儲存查詢記錄時，所有鐵路類型的資料混放在同一 JSON 列表，`clearAll()` 會一次清除台鐵與高鐵的所有紀錄；同時首頁站台每次開啟 App 都回到寫死的預設值，無法記住使用者上次選擇的車站。改用 Drift（SQLite）可以精確按鐵路類型篩選並提供持久化。

## What Changes

- 新增 `drift` 套件取代 `shared_preferences` 作為本地儲存層
- 新增 `AppDatabase`（Drift）包含 `RecentSearches` 與 `LastStationSelections` 兩張資料表
- 重寫 `SharedPreferencesRecentSearchRepository` → `DriftRecentSearchRepository`
- `RecentSearchRepository` 介面新增 `clearByRailwayType(String)` 與 `getLastStationSelection` / `saveLastStationSelection`
- `ClearHistory` event 新增 `railwayType` 欄位，只清除對應類型的查詢記錄
- `HomeBloc` 初始化與切換鐵路類型時從 DB 讀取上次選擇的出發／到達站
- 選擇車站（departure/arrival）、互換站台、點選近期查詢時自動儲存目前選擇

## Capabilities

### New Capabilities
- `station-persistence`：用 Drift 持久化各鐵路類型的出發／到達站選擇，以及各類型的近期查詢；提供按類型隔離清除的 API

### Modified Capabilities
- `home-screen`：「顯示預設站點」要求變更為「顯示上次選擇站點，首次開啟才用預設值」；「清除全部近期查詢」變更為「只清除當前鐵路類型的查詢記錄」；「切換鐵路類型時重設站點」變更為「切換時載入該類型上次選擇的站點，若無歷史才用預設值」

## Impact

- `pubspec.yaml`：新增 `drift`、`drift_flutter`；dev 新增 `drift_dev`
- `lib/core/database/app_database.dart`：新建 Drift DB 與兩張表
- `lib/core/di/app_module.dart`：注冊 `AppDatabase` singleton
- `lib/features/home/data/repository/recent_search_repository_impl.dart`：完整重寫
- `lib/features/home/domain/repository/recent_search_repository.dart`：介面新增方法
- `lib/features/home/presentation/bloc/home_event.dart`：`ClearHistory` 加 `railwayType`
- `lib/features/home/presentation/bloc/home_bloc.dart`：讀寫 last selection 邏輯
- `lib/features/home/presentation/page/home_page.dart`：傳入 railwayType 至 clearHistory
- **測試**：使用superpowers的skill工具來遵循 TDD 開發流程，每個 use case 和 BLoC 需有對應單元測試
- `README.md`：更新功能說明，加入「站台記憶」與「分類清除近期查詢」兩項新功能描述
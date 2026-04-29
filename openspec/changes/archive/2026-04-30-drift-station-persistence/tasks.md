## 1. 依賴套件與 Drift 資料庫建立

- [x] 1.1 在 `pubspec.yaml` 新增 `drift`、`drift_flutter` dependencies，並在 dev_dependencies 新增 `drift_dev`
- [x] 1.2 建立 `lib/core/database/app_database.dart`，定義 `RecentSearches`（含 `@DataClassName('RecentSearchRow')`）與 `LastStationSelections` 兩張 Table，以及 `AppDatabase` class（schemaVersion: 1）
- [x] 1.3 執行 `dart run build_runner build --delete-conflicting-outputs` 產生 `app_database.g.dart`

## 2. Repository 介面與實作（TDD）

- [x] 2.1 撰寫 `DriftRecentSearchRepository` 的單元測試，涵蓋：`getRecentSearches`、`saveSearch`（dedup + max 5）、`clearByRailwayType`、`getLastStationSelection`、`saveLastStationSelection`
- [x] 2.2 在 `RecentSearchRepository` 介面新增 `clearByRailwayType`、`getLastStationSelection`、`saveLastStationSelection` 三個方法
- [x] 2.3 新建 `DriftRecentSearchRepository`（`@LazySingleton(as: RecentSearchRepository)`）實作上述介面；`saveSearch` 須過濾同路線重複並保留最新 5 筆（以 `searchedAt` 排序）
- [x] 2.4 刪除舊 `SharedPreferencesRecentSearchRepository` 類別（含 `dart:convert`、`shared_preferences` 引用）

## 3. DI 注冊

- [x] 3.1 在 `AppModule` 新增 `@lazySingleton AppDatabase get appDatabase => AppDatabase()`
- [x] 3.2 執行 `dart run build_runner build --delete-conflicting-outputs` 重新產生 `injection.config.dart`

## 4. BLoC 事件與邏輯更新（TDD）

- [x] 4.1 撰寫 `HomeBloc` 測試，覆蓋：初始化從 DB 載入上次站台、切換類型載入對應站台（有/無歷史兩案例）、選站後寫入 DB、`ClearHistory` 只清除當前類型
- [x] 4.2 修改 `home_event.dart`：`ClearHistory` 加入 `required String railwayType` 欄位，執行 build_runner 重新產生 `home_event.freezed.dart`
- [x] 4.3 修改 `HomeBloc._onLoadRecentSearches`：同時呼叫 `getLastStationSelection(state.railwayType.name)`，若有歷史則覆蓋預設站台後 emit
- [x] 4.4 修改 `HomeBloc._onSwitchRailwayType`：改為 async，先儲存當前選擇，再 `getLastStationSelection` 載入新類型歷史（或 fallback 預設）
- [x] 4.5 修改 `HomeBloc._onSelectDepartureStation`、`_onSelectArrivalStation`、`_onSwapStations`、`_onSelectRecentSearch`：emit 後呼叫 `saveLastStationSelection`
- [x] 4.6 修改 `HomeBloc._onClearHistory`：改呼叫 `clearByRailwayType(event.railwayType)`，再重新載入剩餘紀錄 emit

## 5. UI 更新

- [x] 5.1 修改 `home_page.dart`：`onClearAll` 傳入 `HomeEvent.clearHistory(railwayType: state.railwayType.name)`

## 6. 清理與 README

- [x] 6.1 從 `pubspec.yaml` 移除 `shared_preferences`（確認無其他功能使用後再移除）
- [x] 6.2 更新 `README.md`：在功能清單加入「站台記憶（Drift 持久化）」與「分類清除近期查詉」兩項說明

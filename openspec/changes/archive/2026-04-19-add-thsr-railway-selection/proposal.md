## Why

目前 App 僅支援台鐵（TRA）時刻表查詢，無法查詢台灣高鐵（THSR）班次。根據 Claude Design 設計稿，透過在首頁加入「高鐵 / 台鐵」分段切換器，讓使用者能在同一 App 查詢兩種鐵路系統，切換時配色與資料來源同步切換。

## What Changes

- 首頁 header 加入分段切換器（高鐵 HSR / 台鐵 TR），採 Liquid Glass 毛玻璃風格
- 台鐵維持藍色系（accent `#2E72B8`），高鐵改為橘金色系（accent `#C86820`），切換時整體配色（header 漸層、按鈕、accent）隨之改變
- 新增 THSR Retrofit API service：車站列表（`/v2/Rail/THSR/Station`）、OD 時刻表（`/v2/Rail/THSR/DailyTimetable/OD/{Origin}/to/{Destination}/{TrainDate}`）、OD 票價（`/v2/Rail/THSR/ODFare/{Origin}/to/{Destination}`）
- 車站選擇器依所選系統顯示不同車站清單，高鐵顯示 12 站
- `HomeState` 新增 `railwayType` 欄位（`tra` / `hsr`），影響車站清單來源與查詢路由
- 近期查詢紀錄依 `railwayType` 分流儲存與顯示
- `TimetablePage` 依 `railwayType` 路由至對應 repository（TRA 或 THSR）
- App 名稱從「臺鐵時刻表」更新為「鐵路時刻表」（iOS Info.plist、Android strings.xml）
- README.md 加入 Claude Design 工具說明段落

## Capabilities

### New Capabilities
- `thsr-timetable`: 高鐵班次查詢功能，包含 THSR 車站列表、OD 時刻表、OD 票價的 TDX API 整合，以及對應的 Repository、DTO、Entity

### Modified Capabilities
- `home-screen`: 加入鐵路類型切換器（RailwayType segmented control），HomeState / HomeBloc 新增雙系統狀態管理，車站選擇器與近期查詢依系統分流
- `tdx-api-integration`: 加入 THSR API endpoints，`TdxThsrApiService` 以 Retrofit 定義，DTO 使用 json_serializable

## Impact

- `lib/features/timetable/data/datasource/` — 新增 `tdx_thsr_api_service.dart`（Retrofit）
- `lib/features/timetable/data/dto/` — 新增 THSR 時刻表與票價 DTO
- `lib/features/timetable/data/repository/` — 新增 `thsr_timetable_repository_impl.dart`
- `lib/features/timetable/domain/repository/` — 新增 `thsr_timetable_repository.dart` interface
- `lib/features/home/presentation/bloc/` — `HomeState` 加入 `railwayType`，`HomeBloc` 加入切換 event，`HomeEvent` 加入 `switchRailwayType`
- `lib/features/home/presentation/page/home_page.dart` — 加入 SystemSegment widget，配色依 railwayType 動態套用
- `lib/features/home/presentation/widget/` — 新增 `railway_type_segment_widget.dart`
- `lib/core/di/app_module.dart` — 注入 THSR repository
- `ios/Runner/Info.plist`、`android/app/src/main/res/values/strings.xml` — 更新 App 名稱
- `README.md` — 加入 Claude Design 說明
- **測試**：使用superpowers來遵循 TDD 開發流程，每個 use case 和 BLoC 需有對應單元測試

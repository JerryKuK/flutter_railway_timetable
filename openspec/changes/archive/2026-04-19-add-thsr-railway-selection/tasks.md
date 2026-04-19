## 1. THSR API 層（Data Layer）

- [x] 1.1 新增 `TdxThsrStationDto`、`TdxThsrTimetableResponseDto`、`TdxThsrODFareItemDto`（含 `@JsonSerializable`），執行 build_runner 產生 `.g.dart`
- [x] 1.2 新增 `TdxThsrApiService`（`@RestApi`）定義三支 THSR API endpoint：Station、DailyTimetable OD、ODFare OD
- [x] 1.3 新增 `ThsrTimetableRepository` 介面（domain layer），定義 `getDailyTimetable`、`getStations` 方法
- [x] 1.4 新增 `ThsrTimetableRepositoryImpl`（`@LazySingleton`）：呼叫 `TdxThsrApiService`，處理票價降級、404 空結果、mapper 邏輯
- [x] 1.5 更新 `AppModule` / `injection.dart`，注入 `TdxThsrApiService` 與 `ThsrTimetableRepository`，執行 build_runner

## 2. THSR Repository 單元測試（TDD）

- [x] 2.1 為 `ThsrTimetableRepositoryImpl.getDailyTimetable` 撰寫單元測試：成功情境（驗證 Train 欄位映射正確）
- [x] 2.2 為 `getDailyTimetable` 撰寫票價 API 失敗降級測試（fare = 0，班次仍回傳）
- [x] 2.3 為 `getDailyTimetable` 撰寫 404 回傳空列表測試
- [x] 2.4 為 `getStations` 撰寫成功與快取命中測試

## 3. HomeState / HomeBloc 擴充

- [x] 3.1 新增 `enum RailwayType { tra, hsr }`
- [x] 3.2 更新 `HomeState`（freezed）：加入 `railwayType`（預設 `tra`）、`hsrStations`、更名或保留 `stations` → `traStations`
- [x] 3.3 執行 build_runner 重新產生 `home_state.freezed.dart`
- [x] 3.4 新增 `HomeEvent.switchRailwayType(RailwayType type)` 並在 `HomeBloc` 處理：切換 type、重設站點預設值、觸發對應車站載入
- [x] 3.5 更新 `HomeBloc._onLoadStations`：初始化時同時載入 TRA 與 THSR 車站（`Future.wait`），分別填入 `traStations` 和 `hsrStations`
- [x] 3.6 更新 `HomeBloc._onSearch`：route extra 加入 `railwayType`

## 4. HomeBloc 單元測試（TDD）

- [x] 4.1 測試 `switchRailwayType` event：驗證 `railwayType` 切換正確、站點重設為對應預設值
- [x] 4.2 測試初始化同時載入 TRA + THSR 車站：mock 兩個 repository，驗證 state 更新正確
- [x] 4.3 測試 `search` event：驗證 `railwayType: hsr` 時 route extra 包含正確值

## 5. 首頁 UI 更新

- [x] 5.1 新增 `RailwayTheme` data class（包含 `headerGradient`、`accent`、`accentSoft`），定義台鐵與高鐵兩套配色常數
- [x] 5.2 新增 `RailwayTypeSegmentWidget`（Stateless Widget）：毛玻璃背景分段切換器，接收 `railwayType` 與 `onChanged` callback
- [x] 5.3 更新 `_buildTopSection`：加入 `RailwayTypeSegmentWidget`，header 漸層依 `railwayType` 套用 `RailwayTheme`
- [x] 5.4 更新 `_buildStationCard`：swap 按鈕與站點 dot 顏色依 `RailwayTheme.accent` 套用
- [x] 5.5 更新 `_buildSearchButton`：按鈕漸層依 `RailwayTheme` 套用
- [x] 5.6 更新 `_openStationPicker`：依 `railwayType` 傳入對應 `stations`（`traStations` 或 `hsrStations`）；高鐵模式傳入 `showCityFilter: false`
- [x] 5.7 更新 `StationPickerModal`：新增 `showCityFilter` 參數，高鐵模式隱藏城市 chips

## 6. 時刻表頁面與路由更新

- [x] 6.1 更新 `AppRouter`：`/timetable` 的 `BlocProvider.create` 依 `extra['railwayType']` 選擇注入 `TimetableRepository`（TRA）或 `ThsrTimetableRepository`（THSR）
- [x] 6.2 更新 `TimetableBloc` 建構函式：使用抽象型別（`TimetableRepository` 或 `ThsrTimetableRepository`），確保兩者 interface 相容；或以 union type 處理

## 7. App 名稱更新

- [x] 7.1 更新 `ios/Runner/Info.plist`：`CFBundleDisplayName` 改為「鐵路時刻表」
- [x] 7.2 更新 `android/app/src/main/res/values/strings.xml`：`app_name` 改為「鐵路時刻表」

## 8. README 與收尾

- [x] 8.1 在 `README.md` 加入 Claude Design 工具說明（UI 設計由 Claude Design 產出）
- [x] 8.2 執行 `flutter analyze` 確認無靜態錯誤
- [x] 8.3 執行 `flutter test` 確認所有測試通過

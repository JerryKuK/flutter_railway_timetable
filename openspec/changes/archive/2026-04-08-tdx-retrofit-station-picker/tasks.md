## 1. 套件與環境設定

- [x] 1.1 在 `pubspec.yaml` 新增 `envied: ^0.5.4`（dependencies）與 `envied_generator: ^0.5.4`（dev_dependencies）
- [x] 1.2 建立專案根目錄 `.env` 檔案，填入 `TDX_CLIENT_ID` 與 `TDX_CLIENT_SECRET`
- [x] 1.3 在 `.gitignore` 新增 `.env` 與 `lib/core/env/env.g.dart`
- [x] 1.4 執行 `flutter pub get`

## 2. envied 憑證管理

- [x] 2.1 建立 `lib/core/env/env.dart`，定義 `@Envied` abstract class `Env`，包含 `tdxClientId` 與 `tdxClientSecret`（`obfuscate: true`）
- [x] 2.2 執行 `dart run build_runner build` 產生 `env.g.dart`（先驗證 envied 設定正確）

## 3. json_serializable DTOs

- [x] 3.1 建立 `lib/features/timetable/data/dto/tdx_response_dto.dart`，包含：`MultilingualName`、`TdxStationDto`（StationID, StationName, City）、`TdxTrainTimetableDto`（TrainNo, TrainTypeName, DepartureTime, ArrivalTime, TravelTime, Fare）
- [x] 3.2 為 `TdxStationDto` 與 `TdxTrainTimetableDto` 寫單元測試（`fromJson` 驗證多語系欄位正確解析）

## 4. Retrofit API Interface

- [x] 4.1 將 `lib/features/timetable/data/datasource/tdx_tra_api_service.dart` 改為 `@RestApi` abstract class，定義 `getDailyTimetable` 與 `getStations` 方法
- [x] 4.2 執行 `dart run build_runner build --delete-conflicting-outputs` 產生 Retrofit 實作
- [x] 4.3 更新 `lib/core/di/app_module.dart`：使用 `Env.tdxClientId`/`Env.tdxClientSecret` 取代 `String.fromEnvironment`，並以 `TdxTraApiService(dio)` Retrofit factory 建立服務

## 5. Repository 與 Domain 更新

- [x] 5.1 更新 `lib/features/timetable/domain/entity/station.dart`，加入 `@Default('') String city` 欄位（重新產生 freezed）
- [x] 5.2 更新 `lib/features/timetable/data/repository/timetable_repository_impl.dart`，使用新 DTO 欄位（`dto.trainTypeName?.zhTw`、`dto.stationName?.zhTw`、`dto.city`）
- [x] 5.3 為 `TimetableRepositoryImpl` 更新/補充單元測試

## 6. HomeBloc 車站選擇邏輯

- [x] 6.1 更新 `lib/features/home/presentation/bloc/home_event.dart`，新增 `loadStations`、`selectDepartureStation(Station)`、`selectArrivalStation(Station)` events
- [x] 6.2 更新 `lib/features/home/presentation/bloc/home_state.dart`，新增 `stations: List<Station>`、`isLoadingStations: bool`、`stationsError: String?` 欄位
- [x] 6.3 重新產生 freezed（`dart run build_runner build --delete-conflicting-outputs`）
- [x] 6.4 更新 `lib/features/home/presentation/bloc/home_bloc.dart`：注入 `TimetableRepository`，新增 `loadStations`/`selectDepartureStation`/`selectArrivalStation` handlers，初始化時發出 `loadStations`
- [x] 6.5 更新 `lib/core/di/injection.config.dart` 使 HomeBloc 注入 `TimetableRepository`（重新執行 injectable_generator）
- [x] 6.6 為 HomeBloc 新事件寫單元測試（使用 `bloc_test`）

## 7. Station Picker Modal UI

- [x] 7.1 建立 `lib/features/home/presentation/widget/station_picker_modal.dart`，實作：標題列（動態標題 + 關閉按鈕）、搜尋框（即時篩選）、城市 FilterChip tabs（「全部」+ 動態城市）、車站 ListView（含已選勾選標記）、載入中 indicator、錯誤狀態
- [x] 7.2 更新 `lib/features/home/presentation/page/home_page.dart`：`StationInputWidget` 的 `onTap` 改為呼叫 `showModalBottomSheet` 開啟 `StationPickerModal`，並在選擇後 dispatch 對應 event

## 8. 整合驗證

- [x] 8.1 執行 `flutter analyze` 確認無分析錯誤
- [x] 8.2 執行 `flutter test` 確認所有測試通過
- [x] 8.3 在 iOS 模擬器手動驗證：選擇出發站/到達站、搜尋車站、城市篩選、查詢班次完整流程
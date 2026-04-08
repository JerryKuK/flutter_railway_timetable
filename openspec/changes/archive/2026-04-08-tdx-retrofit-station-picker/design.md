## Context

目前 `TdxTraApiService` 以手動 Dio 呼叫實作，未使用 Retrofit code generation，違反 api/spec.md 規範。TDX 憑證以 `String.fromEnvironment` 明文傳入。首頁站點欄位 `onTap: null`，使用者無法選擇車站。Pencil 設計稿已有 Station Picker Modal 原型（含搜尋框、城市篩選 tabs、清單）。

## Goals / Non-Goals

**Goals:**
- 將 `TdxTraApiService` 改為 `@RestApi` Retrofit interface，符合 api spec
- 以 `envied` 管理 TDX 憑證，compile-time 混淆
- 建立 `json_serializable` DTOs（含多語系欄位處理）
- 實作 Station Picker Modal 供首頁選站使用
- HomeBloc 加入車站載入與選擇事件，遵循 TDD（superpowers）

**Non-Goals:**
- 離線快取車站清單到磁碟（記憶體快取已足夠）
- 多語系切換（只顯示中文 Zh_tw）
- 票價詳細分艙位計算

## Decisions

### 1. Retrofit interface 回傳型別

- **Station API（v2）**：`/Rail/TRA/Station` 直接回傳 JSON array，Retrofit method 回傳 `Future<List<TdxStationDto>>`，無需 wrapper。
- **Timetable API（v3）**：遷移至 `/v3/Rail/TRA/DailyTrainTimetable/OD/{origin}/to/{destination}/{date}` 後，回應格式改為 `{"TrainTimetables": [...]}` wrapper 物件，故 Retrofit method 改為回傳 `Future<TdxTimetableResponseDto>`，由 `TdxTimetableResponseDto.trainTimetables` 取得班次列表。

**v2 → v3 遷移原因**：v2 OD 端點在查無班次時回傳 404（非空陣列），且資料結構以 `OriginStopTime`/`DestinationStopTime` 扁平欄位呈現；v3 改以 `StopTimes[]` 陣列呈現所有停靠站，更易擴充。404 視為空結果（`DioException.statusCode == 404` → 回傳 `[]`）。

### 2. `MultilingualName` 使用 `@JsonSerializable` 巢狀類別
TDX `StationName`、`TrainTypeName` 等欄位格式為 `{"Zh_tw": "...", "En": "..."}` object。使用獨立 `MultilingualName` class 搭配 `json_serializable`，Repository 層取 `.zhTw`。

**Alternative considered**: JsonConverter custom class → 較繁瑣，巢狀 class 更易維護。

### 3. envied `obfuscate: true`
Client ID/Secret 以數字陣列儲存於 `env.g.dart`（gitignored），避免字串搜索工具直接找到憑證。`.env` 檔案同樣 gitignored。

### 4. Station Picker Modal 為 `showModalBottomSheet`
依 Pencil 設計稿，以底部半頁 Modal 顯示，包含：標題列（「選擇出發站」/「選擇到達站」）+ 關閉按鈕、搜尋框、城市 FilterChip tabs、車站 ListView。城市資料從 `TdxStationDto.city` 欄位動態分組。

### 5. HomeBloc 注入 `TimetableRepository` 取得車站清單
`TimetableRepository.getStations()` 已有記憶體快取邏輯，HomeBloc 直接重用，不重複建立資料層。在 `HomeBloc` 初始化時立即發出 `loadStations` event。

### 6. `Station` entity 加入 `city` 欄位（`@Default('')`）
讓 Station Picker 能依城市分組篩選，不影響既有使用 Station 的程式碼（有預設值）。

## Risks / Trade-offs

- **TDX `City` 欄位存在性**: TDX TRA Station API v2 應有 `City` 欄位，若 API 不回傳則城市分組顯示「其他」→ 以 `@Default('')` 和空值判斷處理。
- **Retrofit `List<T>` 與 dio 5.x**: retrofit_generator 9.x 對 List 回傳已支援，但需確保 DTO 有 `fromJson` factory → 由 json_serializable 產生，無風險。
- **build_runner 衝突**: 同時有 freezed、injectable、retrofit、json_serializable、envied 五個 generator → 一次執行 `--delete-conflicting-outputs` 解決。

## Migration Plan

1. 新增 pubspec 依賴（envied）→ `flutter pub get`
2. 建立 `.env`、`lib/core/env/env.dart`
3. 建立新 DTOs、Retrofit interface
4. 更新 `TimetableRepositoryImpl`、`AppModule`、`Station` entity
5. 更新 `HomeEvent`、`HomeState`、`HomeBloc`
6. 建立 `StationPickerModal` widget
7. 更新 `HomePage`
8. 執行 `dart run build_runner build --delete-conflicting-outputs`
9. 跑測試驗證

**Rollback**: 因均為同一 feature branch，回滾即 revert commits。

## Resolved Questions

- **TDX Station API 縣市欄位名稱**：確認為 `"LocationCity"`（純字串，如 `"臺北市"`），非 NameType 物件，亦非 `"City"`。已更新 `TdxStationDto` 的 `@JsonKey(name: 'LocationCity')`。
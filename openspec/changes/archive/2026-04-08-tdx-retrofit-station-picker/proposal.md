## Why

目前 `TdxTraApiService` 直接使用裸 Dio 呼叫，違反 api spec 規定的 Retrofit type-safe interface 要求；TDX 憑證以明文 `String.fromEnvironment` 傳入缺乏保護；首頁站點輸入欄位的 `onTap` 為 null，使用者無法選擇車站。

## What Changes

- 將 `TdxTraApiService` 從手動 Dio 呼叫改為 `@RestApi` Retrofit 注釋 interface（由 code generation 產生實作）
- 建立 `json_serializable` DTOs（含 `MultilingualName` 處理 TDX 多語系欄位）取代手動 `fromJson`
- 使用 `envied` 套件將 TDX Client ID／Secret 儲存於 `.env`，編譯期混淆為數字陣列
- 新增 Station Picker Modal，依照 Pencil 設計稿實作：搜尋框 + 城市篩選 tabs + 車站清單
- 首頁出發站／到達站點擊後開啟 Station Picker Modal
- `HomeBloc` 加入載入車站清單與選擇車站的事件

## Capabilities

### New Capabilities
- `station-picker`: 車站選擇 Modal，包含搜尋、城市篩選、清單展示與選擇邏輯

### Modified Capabilities
- `tdx-api-integration`: 將 Retrofit interface 由空殼實作改為真正 `@RestApi` code generation；新增 envied 憑證管理
- `home-screen`: 新增站點選擇互動（點擊開啟 Modal、選擇後回填站名與站代碼）

## Impact

- **依賴異動**: 新增 `envied ^0.5.4`（runtime）、`envied_generator ^0.5.4`（dev）
- **新增檔案**: `.env`、`lib/core/env/env.dart`、`lib/features/timetable/data/dto/tdx_response_dto.dart`、`lib/features/home/presentation/widget/station_picker_modal.dart`
- **修改檔案**: `TdxTraApiService`（改為 abstract Retrofit interface）、`TimetableRepositoryImpl`（使用新 DTO）、`AppModule`（使用 Env）、`HomeEvent`/`HomeState`/`HomeBloc`（加入車站相關邏輯）、`Station` entity（加入 `city` 欄位）
- **Code generation**: 需重跑 `dart run build_runner build --delete-conflicting-outputs`
- **測試**：使用superpowers來遵循 TDD 開發流程，每個 use case 和 BLoC 需有對應單元測試
## Context

這是一個全新的 Flutter 台鐵時刻表 App，從零開始建立。專案使用 Clean Architecture 分層、BLoC 狀態管理、Retrofit API 層、get_it 依賴注入、freezed 資料模型，並依 TDD 開發流程撰寫測試。時刻表資料來源為 TDX（運輸資料流通服務平台）台鐵 API。

## Goals / Non-Goals

**Goals:**
- 實作首頁搜尋、時刻表結果、我的車票（假資料）、我的頁面（假資料）四個主要畫面
- 整合 TDX OAuth2 Token 取得及台鐵班次時刻表 API
- 以 Clean Architecture 分層：`data` / `domain` / `presentation`
- 用 BLoC 管理各頁面狀態，go_router 管理路由
- 符合 TDD 開發流程，use case 與 BLoC 有對應單元測試

**Non-Goals:**
- 不實作真實購票功能（我的車票為假資料）
- 不實作使用者登入/註冊（我的頁面為假資料）
- 不實作推播通知

## Decisions

### 1. 狀態管理：BLoC（flutter_bloc）
選用 BLoC 而非 Provider 或 Riverpod，原因是與 Clean Architecture 的 use case 邊界契合，且利於測試（BlocTest）。每個頁面各有獨立 BLoC：`HomeBloc`、`TimetableBloc`、`MyTicketsBloc`、`ProfileBloc`。

### 2. 網路層：Dio（取代 Retrofit）
原計畫使用 Retrofit + code generation 產生型別安全的 API interface，但實作時發現 Retrofit 與 freezed 3.x 的 code generation 存在相容性問題（`invalid_annotation_target` 警告、DTO constructor 無法正確產生）。最終改為直接使用 Dio，以手寫 plain Dart class（`TdxTraApiService`）封裝 API 呼叫，並以手動 `fromJson` 解析 DTO。此方式無需 code generation、更易維護。TDX OAuth2 token 仍透過 Dio interceptor（`TdxAuthInterceptor`）自動管理。

### 3. 依賴注入：get_it
使用 get_it service locator 管理 Repository、UseCase、BLoC 的生命週期，搭配 injectable code generation。

### 4. 資料模型：freezed
用 freezed 定義不可變（immutable）的 domain entity 與 data DTO，並以 json_serializable 處理 JSON 序列化。

### 5. 路由：go_router
以 go_router 管理底部導航的 ShellRoute 與各頁面路由，支援 deep link 擴展。

### 6. 目錄結構

```
lib/
  core/
    di/           # get_it 依賴注入設定
    network/      # Dio client, TDX auth interceptor
    router/       # go_router 設定
  features/
    home/
      data/       # repository_impl, datasource, dto
      domain/     # entity, repository interface, use_case
      presentation/ # bloc, page, widget
    timetable/
      data/
      domain/
      presentation/
    my_tickets/
      presentation/ # bloc, page, widget（假資料）
    profile/
      presentation/ # bloc, page, widget（假資料）
```

### 7. TDX API 端點
- **Token 取得**：`POST /auth/realms/TDXConnect/protocol/openid-connect/token`
- **車站列表**：`GET /api/basic/v2/Rail/TRA/Station`
- **時刻表查詢**：`GET /api/basic/v2/Rail/TRA/DailyTrainTimetable/OD/{Origin}/{Destination}/{TrainDate}`

## Risks / Trade-offs

- **TDX API 需要 Client ID/Secret** → 使用 `.env` 或 `--dart-define` 注入，不 hardcode 進程式碼
- **班次資料量可能較大** → 在 use case 層加入分頁或筆數限制（`$top` 參數）
- **Freezed/Retrofit code generation 初次設置複雜** → 在 `pubspec.yaml` 統一管理 `build_runner` 依賴，提供清楚的生成指令
- **假資料頁面未來需真實化** → my_tickets 與 profile 的假資料以 Repository interface + fake implementation 封裝，方便日後替換

## Open Questions

- TDX Client ID / Client Secret 的存放方式（環境變數 vs `--dart-define`），實作時需與使用者確認
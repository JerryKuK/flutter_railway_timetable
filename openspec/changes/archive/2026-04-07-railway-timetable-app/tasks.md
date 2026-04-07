## 1. 專案基礎設置

- [x] 1.1 在 `pubspec.yaml` 新增所有依賴套件：`flutter_bloc`、`go_router`、`retrofit`、`dio`、`get_it`、`injectable`、`freezed`、`json_serializable`、`shared_preferences`
- [x] 1.2 新增 dev dependencies：`build_runner`、`freezed_annotation`、`injectable_generator`、`retrofit_generator`、`mockito`、`bloc_test`
- [x] 1.3 建立目錄結構：`lib/core/`（di、network、router）與 `lib/features/`（home、timetable、my_tickets、profile）
- [x] 1.4 設定 `go_router`：定義底部導航的 `ShellRoute`，四個 Tab 路由（/home、/timetable、/my-tickets、/profile）
- [x] 1.5 設定 `get_it` + `injectable`：建立 `injection.dart` 並設定 `configureDependencies()`
- [x] 1.6 建立底部導航 `AppShell` widget，含四個 Tab（首頁、時刻表、我的車票、我的）
- [x] 1.7 在 `main.dart` 初始化 DI 並啟動 App，設定 `MaterialApp.router`

## 2. TDX API 整合

- [x] 2.1 建立 `lib/core/network/tdx_auth_interceptor.dart`：實作 Dio interceptor，自動取得並快取 TDX Bearer token（client_credentials flow）
- [x] 2.2 建立 `lib/core/network/dio_client.dart`：設定 Dio instance，掛載 `TdxAuthInterceptor`
- [x] 2.3 建立 `lib/features/timetable/data/datasource/tdx_tra_api_service.dart`：Retrofit interface，定義 `getStations` 與 `getDailyTimetable` 兩個 API 方法
- [x] 2.4 執行 `flutter pub run build_runner build` 產生 Retrofit 與 freezed 程式碼
- [x] 2.5 建立 `TrainDto`、`StationDto` freezed DTO 類別（含 `fromJson`）
- [x] 2.6 建立 `Train`、`Station` domain entity（freezed）
- [x] 2.7 定義 `TimetableRepository` interface（domain 層）
- [x] 2.8 實作 `TimetableRepositoryImpl`（data 層），將 DTO 轉換為 domain entity
- [x] 2.9 建立 `GetDailyTimetableUseCase`（domain 層）
- [x] 2.10 寫 `TimetableRepositoryImpl` 單元測試（mock API service，測試成功與失敗情境）
- [x] 2.11 寫 `GetDailyTimetableUseCase` 單元測試

## 3. 首頁（Home Screen）

- [x] 3.1 建立 `HomeState`（freezed）：包含 `departureStation`、`arrivalStation`、`date`、`time`、`recentSearches` 欄位
- [x] 3.2 建立 `HomeEvent`（freezed）：`SwapStations`、`UpdateDate`、`UpdateTime`、`Search`、`ClearHistory`、`SelectRecentSearch`
- [x] 3.3 實作 `HomeBloc`，處理所有 event 並更新 state
- [x] 3.4 建立 `RecentSearchRepository` interface 與 `SharedPreferencesRecentSearchRepository` 實作，儲存近期查詢
- [x] 3.5 建立 `HomePage` widget，組合站點輸入、日期時間選擇、查詢按鈕、近期查詢列表
- [x] 3.6 建立 `StationInputWidget`：出發站/到達站輸入欄（點擊顯示站點搜尋對話框）
- [x] 3.7 建立 `DateTimeRowWidget`：日期與時間選擇器行
- [x] 3.8 建立 `RecentSearchListWidget`：近期查詢列表，含清除全部按鈕
- [x] 3.9 寫 `HomeBloc` 單元測試（BlocTest）：測試交換站點、清除歷史、查詢觸發
- [x] 3.10 寫 `HomePage` widget 測試：測試交換按鈕、查詢按鈕、近期查詢顯示

## 4. 時刻表頁（Timetable Screen）

- [x] 4.1 建立 `TimetableState`（freezed）：`initial`、`loading`、`loaded(trains)`、`empty`、`error(message)` 狀態
- [x] 4.2 建立 `TimetableEvent`（freezed）：`LoadTimetable(origin, destination, date)`、`Retry`
- [x] 4.3 實作 `TimetableBloc`，呼叫 `GetDailyTimetableUseCase` 並映射到 state
- [x] 4.4 建立 `TimetablePage` widget，根據 state 顯示 loading / 班次列表 / 空狀態 / 錯誤
- [x] 4.5 建立 `TrainCardWidget`：顯示單張班次卡片（車次、時間、行駛時間、票價）
- [x] 4.6 建立 `TimetableEmptyStateWidget`：空狀態畫面，含圖示、說明文字、重新查詢按鈕
- [x] 4.7 寫 `TimetableBloc` 單元測試：測試 loading、loaded、empty、error 各狀態轉換
- [x] 4.8 寫 `TimetablePage` widget 測試：測試不同 state 下的 UI 渲染

## 5. 我的車票頁（My Tickets Screen）

- [x] 5.1 定義 `Ticket` freezed entity（車次、時間、站點、座位、狀態）
- [x] 5.2 建立假資料列表（3 筆）：2 筆「已完成」、1 筆「即將出發」
- [x] 5.3 建立 `MyTicketsState`（freezed）與 `MyTicketsBloc`（直接回傳假資料）
- [x] 5.4 建立 `MyTicketsPage` widget
- [x] 5.5 建立 `TicketCardWidget`：票券卡片，含狀態標籤（即將出發/已完成）
- [x] 5.6 寫 `MyTicketsBloc` 單元測試

## 6. 我的頁面（Profile Screen）

- [x] 6.1 定義 `UserProfile` freezed entity（假資料：姓名、email、里程行、點數、常用路線數）
- [x] 6.2 建立 `ProfileState`（freezed）與 `ProfileBloc`（直接回傳假資料）
- [x] 6.3 建立 `ProfilePage` widget：頭像、統計數字、功能選單、登出按鈕
- [x] 6.4 建立 `ProfileStatsWidget`：三欄統計數字區塊
- [x] 6.5 建立 `ProfileMenuWidget`：功能選單列表
- [x] 6.6 寫 `ProfileBloc` 單元測試

## 7. 整合測試與收尾

- [x] 7.1 確認 go_router 四個 Tab 切換正常，底部導航列高亮狀態正確
- [x] 7.2 驗證首頁查詢 → 時刻表頁導航流程（帶入正確查詢參數）
- [x] 7.3 驗證近期查詢儲存與讀取（SharedPreferences）
- [x] 7.4 執行所有單元測試，確認全數通過（`flutter test`）
- [x] 7.5 執行 `flutter analyze` 確認無靜態分析錯誤
- [x] 7.6 用 Agent Device 在 iOS 模擬器錄製各功能測試，儲存至 `./workflows/railway-timetable-app.ad`
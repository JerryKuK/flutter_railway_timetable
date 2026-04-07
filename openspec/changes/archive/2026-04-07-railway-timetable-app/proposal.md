## Why

目前專案尚無任何功能實作，需要從零開始建立一個完整的台鐵時刻表 Flutter App，讓使用者可以快速查詢台鐵班次、管理車票資訊與個人設定。

## What Changes

- 新增首頁（Home Screen）：包含出發站/到達站選擇、日期時間選擇、查詢班次按鈕、近期查詢紀錄
- 新增時刻表頁（Timetable Screen）：顯示查詢結果班次列表，包含車次號碼、出發/抵達時間、行駛時間、票價；無班次時顯示空狀態畫面
- 新增我的車票頁（My Tickets Screen）：顯示使用者購買的車票卡片，標示即將出發/已完成狀態（假資料）
- 新增我的頁面（Profile Screen）：顯示使用者頭像、統計數據（里程/累積點數/常用路線）與功能選單（假資料）
- 新增底部導航列：首頁、時刻表、我的車票、我的（四個 Tab）
- 整合 TDX 台鐵 API（`https://tdx.transportdata.tw`）查詢班次時刻表資料，使用 Retrofit
- 功能都完成後, 再用 Agent Device 開啟ios模擬器幫我錄製這次的多個需求測試，存到 ./workflows/`$需求`.ad

## Capabilities

### New Capabilities

- `home-screen`：首頁搜尋表單，包含出發站/到達站輸入、日期時間選擇、查詢按鈕、近期查詢歷史紀錄
- `timetable-screen`：時刻表結果頁面，顯示班次列表卡片與無資料時的空狀態，資料來源為 TDX API
- `tdx-api-integration`：TDX 台鐵 API 整合層，使用 Retrofit 定義 API interface，含 OAuth2 認證 token 管理
- `my-tickets-screen`：我的車票頁面，以假資料展示票券卡片（車次、時間、車站、座位）及狀態標籤
- `profile-screen`：我的頁面，以假資料展示使用者資訊、統計數據、功能選單列表及登出按鈕

### Modified Capabilities

（無現有規格需修改）

## Impact

- **Flutter 套件依賴**：新增 `flutter_bloc`、`retrofit`、`dio`、`get_it`、`freezed`、`json_serializable`、`go_router`
- **API 依賴**：TDX 台鐵時刻表 API（需申請 Client ID / Client Secret）
- **架構**：依 Clean Architecture 分層（data / domain / presentation），BLoC 管理狀態
- **測試**：使用superpowers來遵循 TDD 開發流程，每個 use case 和 BLoC 需有對應單元測試
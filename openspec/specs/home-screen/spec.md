## Requirements

### Requirement: 顯示出發站與到達站輸入欄位
首頁 SHALL 顯示兩個站點輸入欄位（出發站、到達站），並提供交換按鈕可互換兩站內容。點擊任一欄位時 SHALL 開啟 Station Picker Modal 供使用者選擇車站。

#### Scenario: 使用者點擊交換按鈕
- **WHEN** 使用者點擊出發站與到達站之間的交換按鈕
- **THEN** 出發站與到達站的值互換

#### Scenario: 顯示預設站點
- **WHEN** 首頁載入時
- **THEN** 出發站顯示「台北」（站代碼 1020），到達站顯示「高雄」（站代碼 3300）

#### Scenario: 點擊站點欄位開啟選擇 Modal
- **WHEN** 使用者點擊出發站或到達站輸入欄位
- **THEN** 系統開啟 Station Picker Modal（參見 station-picker spec）

#### Scenario: 選擇車站後更新欄位
- **WHEN** 使用者在 Station Picker Modal 選擇車站
- **THEN** 對應欄位更新為所選車站名稱，站代碼更新為所選車站 ID

### Requirement: 日期與時間選擇
首頁 SHALL 提供日期選擇器與時間選擇器，預設為當日日期與當前時間。

#### Scenario: 顯示預設日期時間
- **WHEN** 首頁載入時
- **THEN** 日期欄位顯示今日日期（格式 YYYY/MM/DD），時間欄位顯示當前時間（格式 HH:mm）

#### Scenario: 使用者選擇日期
- **WHEN** 使用者點擊日期欄位並選擇新日期
- **THEN** 日期欄位更新為選擇的日期

### Requirement: 查詢班次按鈕
首頁 SHALL 提供「查詢班次」按鈕，點擊後導航至時刻表頁面。

#### Scenario: 使用者點擊查詢班次
- **WHEN** 使用者填入出發站、到達站、日期並點擊「查詢班次」
- **THEN** 系統導航至時刻表頁面，並帶入查詢參數

#### Scenario: 出發站或到達站為空
- **WHEN** 使用者未填入出發站或到達站即點擊查詢
- **THEN** 系統不導航，顯示提示訊息要求填入站點

### Requirement: 近期查詢紀錄
首頁 SHALL 顯示最多 5 筆近期查詢紀錄，每筆顯示出發站 → 到達站與查詢日期。

#### Scenario: 顯示近期查詢
- **WHEN** 使用者曾經查詢過班次時
- **THEN** 首頁顯示最近查詢紀錄列表，最新的在最上方

#### Scenario: 點擊近期查詢快速填入
- **WHEN** 使用者點擊某筆近期查詢紀錄
- **THEN** 出發站與到達站欄位自動填入該紀錄的站點資訊

#### Scenario: 清除全部近期查詢
- **WHEN** 使用者點擊「清除全部」
- **THEN** 近期查詢列表清空

### Requirement: 首頁載入車站清單
首頁 SHALL 在初始化時從 TDX API 載入車站清單，供 Station Picker Modal 使用。

#### Scenario: 首頁初始化載入車站
- **WHEN** 首頁 BLoC 初始化時
- **THEN** 系統發出 `loadStations` event，非同步載入車站清單至 state

#### Scenario: 車站清單載入完成
- **WHEN** 車站清單從 API 載入成功
- **THEN** `HomeState.stations` 包含完整車站清單，`isLoadingStations` 為 false
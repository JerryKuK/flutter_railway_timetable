## MODIFIED Requirements

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

## ADDED Requirements

### Requirement: 首頁載入車站清單
首頁 SHALL 在初始化時從 TDX API 載入車站清單，供 Station Picker Modal 使用。

#### Scenario: 首頁初始化載入車站
- **WHEN** 首頁 BLoC 初始化時
- **THEN** 系統發出 `loadStations` event，非同步載入車站清單至 state

#### Scenario: 車站清單載入完成
- **WHEN** 車站清單從 API 載入成功
- **THEN** `HomeState.stations` 包含完整車站清單，`isLoadingStations` 為 false
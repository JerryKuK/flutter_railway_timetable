## ADDED Requirements

### Requirement: 鐵路類型切換器
首頁 SHALL 在 header 頂部顯示「高鐵 / 台鐵」分段切換器（Segmented Control），預設選擇台鐵。

#### Scenario: 顯示分段切換器
- **WHEN** 首頁載入時
- **THEN** header 頂部顯示「高鐵」與「台鐵」兩個選項的分段切換器，台鐵預設選中

#### Scenario: 切換至高鐵
- **WHEN** 使用者點擊「高鐵」選項
- **THEN** `HomeState.railwayType` 更新為 `hsr`，header 漸層改為橘金色系（`#F2A85C → #D97A2A`），查詢按鈕顏色、accent 色同步切換

#### Scenario: 切換至台鐵
- **WHEN** 使用者點擊「台鐵」選項
- **THEN** `HomeState.railwayType` 更新為 `tra`，UI 配色恢復藍色系（`#5FA6E0 → #2E72B8`）

### Requirement: 依鐵路類型顯示對應車站清單
首頁 SHALL 在切換鐵路類型時，車站選擇器顯示對應系統的車站清單。

#### Scenario: 台鐵模式開啟車站選擇器
- **WHEN** `railwayType` 為 `tra` 且使用者點擊出發站或到達站
- **THEN** Station Picker 顯示台鐵車站清單，含城市分組 chips

#### Scenario: 高鐵模式開啟車站選擇器
- **WHEN** `railwayType` 為 `hsr` 且使用者點擊出發站或到達站
- **THEN** Station Picker 顯示高鐵車站清單（12 站），不顯示城市分組 chips

#### Scenario: 切換鐵路類型時重設站點
- **WHEN** 使用者切換 railwayType
- **THEN** 出發站重設為該系統的預設出發站（台鐵：台北 1000，高鐵：南港 0990），到達站重設為預設到達站（台鐵：高雄 3300，高鐵：左營 9900）

### Requirement: 依鐵路類型查詢班次並導航
首頁 SHALL 在使用者點擊查詢班次時，將 `railwayType` 傳入時刻表頁面的 route extra。

#### Scenario: 高鐵查詢導航
- **WHEN** `railwayType` 為 `hsr` 且使用者點擊查詢班次
- **THEN** 系統導航至 `/timetable`，route extra 包含 `railwayType: 'hsr'` 以及高鐵站代碼

#### Scenario: 台鐵查詢導航（不受影響）
- **WHEN** `railwayType` 為 `tra` 且使用者點擊查詢班次
- **THEN** 系統導航至 `/timetable`，route extra 包含 `railwayType: 'tra'`，行為與現有一致

### Requirement: 依鐵路類型載入對應車站
首頁 SHALL 在初始化時同時載入台鐵與高鐵車站清單，切換時無需重新請求。

#### Scenario: 初始化同時載入兩系統車站
- **WHEN** 首頁 BLoC 初始化時
- **THEN** 同時發出 `loadStations` event（涵蓋 TRA 與 THSR），兩組車站清單分別儲存於 `traStations` 和 `hsrStations`

#### Scenario: 切換後立即顯示車站
- **WHEN** 使用者切換鐵路類型且車站已載入
- **THEN** 車站選擇器立即顯示對應清單，無載入動畫

## MODIFIED Requirements

### Requirement: 首頁載入車站清單
首頁 SHALL 在初始化時從 TDX API 載入台鐵與高鐵車站清單，分別供 Station Picker Modal 使用。

#### Scenario: 首頁初始化載入車站
- **WHEN** 首頁 BLoC 初始化時
- **THEN** 系統同時發出台鐵與高鐵 `loadStations` events，非同步載入兩組車站清單至 state

#### Scenario: 台鐵車站清單載入完成
- **WHEN** 台鐵車站清單從 API 載入成功時
- **THEN** `HomeState.traStations` 包含完整台鐵車站清單，`isLoadingStations` 為 false

#### Scenario: 高鐵車站清單載入完成
- **WHEN** 高鐵車站清單從 API 載入成功時
- **THEN** `HomeState.hsrStations` 包含完整高鐵車站清單（12 站）

# home-screen Delta Specification

## MODIFIED Requirements

### Requirement: 顯示出發站與到達站輸入欄位
首頁 SHALL 顯示兩個站點輸入欄位（出發站、到達站），並提供交換按鈕可互換兩站內容。點擊任一欄位時 SHALL 開啟 Station Picker Modal 供使用者選擇車站。選擇或互換車站後 SHALL 立即將新選擇持久化至 `LastStationSelections`。

#### Scenario: 使用者點擊交換按鈕
- **WHEN** 使用者點擊出發站與到達站之間的交換按鈕
- **THEN** 出發站與到達站的值互換，並將互換結果儲存至 DB

#### Scenario: 顯示上次選擇站點（有歷史）
- **WHEN** 首頁載入時，`LastStationSelections` 中有當前鐵路類型的紀錄
- **THEN** 出發站與到達站顯示上次選擇的車站，而非系統預設值

#### Scenario: 顯示預設站點（無歷史）
- **WHEN** 首頁載入時，`LastStationSelections` 中無當前鐵路類型的紀錄
- **THEN** 出發站顯示「台北」（站代碼 1000），到達站顯示「高雄」（站代碼 3300）

#### Scenario: 點擊站點欄位開啟選擇 Modal
- **WHEN** 使用者點擊出發站或到達站輸入欄位
- **THEN** 系統開啟 Station Picker Modal（參見 station-picker spec）

#### Scenario: 選擇車站後更新欄位並儲存
- **WHEN** 使用者在 Station Picker Modal 選擇車站
- **THEN** 對應欄位更新為所選車站名稱，站代碼更新為所選車站 ID，並立即寫入 DB

### Requirement: 近期查詢紀錄
首頁 SHALL 顯示當前鐵路類型的最多 5 筆近期查詢紀錄，每筆顯示出發站 → 到達站。

#### Scenario: 顯示近期查詢（依鐵路類型過濾）
- **WHEN** 使用者曾以當前鐵路類型查詢過班次時
- **THEN** 首頁顯示該類型的最近查詢紀錄列表，最新的在最上方

#### Scenario: 點擊近期查詢快速填入並儲存
- **WHEN** 使用者點擊某筆近期查詢紀錄
- **THEN** 出發站與到達站欄位自動填入該紀錄的站點資訊，並將選擇儲存至 DB

#### Scenario: 清除當前鐵路類型的近期查詢
- **WHEN** 使用者點擊「清除全部」
- **THEN** 僅清除當前鐵路類型的近期查詢列表，另一類型的紀錄不受影響

### Requirement: 依鐵路類型切換時載入對應站台
首頁 SHALL 在切換鐵路類型時，從 DB 讀取對應類型上次選擇的站台；若無歷史則使用該類型的預設站台。

#### Scenario: 切換至高鐵（有歷史紀錄）
- **WHEN** 使用者點擊「高鐵」segment，DB 有高鐵上次選擇的站台
- **THEN** 出發站與到達站更新為高鐵上次選擇的車站，header 色系改為橘金色

#### Scenario: 切換至高鐵（無歷史紀錄）
- **WHEN** 使用者點擊「高鐵」segment，DB 無高鐵上次選擇的站台
- **THEN** 出發站重設為「南港」（0990），到達站重設為「左營」（9900）

#### Scenario: 切換至台鐵
- **WHEN** 使用者點擊「台鐵」segment
- **THEN** 出發站與到達站更新為台鐵上次選擇（或預設：台北 → 高雄），UI 配色恢復藍色系

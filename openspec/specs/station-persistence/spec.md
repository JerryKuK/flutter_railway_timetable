# station-persistence Specification

## Requirements

### Requirement: 持久化各鐵路類型的出發／到達站選擇
系統 SHALL 以 Drift（SQLite）`LastStationSelections` 資料表儲存台鐵（TRA）與高鐵（HSR）各自最後一次選擇的出發站與到達站，應用程式重啟後仍保留。

#### Scenario: 首次安裝無歷史紀錄
- **WHEN** 使用者首次安裝 App 且 `LastStationSelections` 資料表為空
- **THEN** 首頁顯示系統預設站台（台鐵：台北 → 高雄；高鐵：南港 → 左營）

#### Scenario: 選擇出發站後關閉 App 重新開啟
- **WHEN** 使用者選擇出發站後關閉 App，重新開啟首頁
- **THEN** 出發站欄位顯示上次選擇的車站，而非系統預設值

#### Scenario: 選擇到達站後關閉 App 重新開啟
- **WHEN** 使用者選擇到達站後關閉 App，重新開啟首頁
- **THEN** 到達站欄位顯示上次選擇的車站，而非系統預設值

#### Scenario: 互換站台後關閉 App 重新開啟
- **WHEN** 使用者按下互換按鈕後關閉 App，重新開啟首頁
- **THEN** 出發站與到達站欄位顯示互換後的站台

#### Scenario: 點選近期查詢後關閉 App 重新開啟
- **WHEN** 使用者點選近期查詢後關閉 App，重新開啟首頁
- **THEN** 出發站與到達站欄位顯示該次近期查詢的站台

### Requirement: 切換鐵路類型時載入對應歷史站台
系統 SHALL 在使用者切換鐵路類型時，從 `LastStationSelections` 讀取對應類型的上次選擇站台；若無歷史則 fallback 至該系統的預設站台。

#### Scenario: 從台鐵切換至高鐵（高鐵有歷史紀錄）
- **WHEN** 使用者點擊高鐵 segment，`LastStationSelections` 有 `railwayType='hsr'` 的紀錄
- **THEN** 出發站與到達站更新為高鐵上次選擇的車站

#### Scenario: 從台鐵切換至高鐵（高鐵無歷史紀錄）
- **WHEN** 使用者點擊高鐵 segment，`LastStationSelections` 無 `railwayType='hsr'` 的紀錄
- **THEN** 出發站顯示「南港」（0990），到達站顯示「左營」（9900）

#### Scenario: 從高鐵切換回台鐵
- **WHEN** 使用者切換回台鐵 segment，`LastStationSelections` 有 `railwayType='tra'` 的紀錄
- **THEN** 出發站與到達站恢復為台鐵上次選擇的車站

### Requirement: 近期查詢以鐵路類型隔離儲存
系統 SHALL 在 `RecentSearches` 資料表中以 `railwayType` 欄位區分台鐵與高鐵查詢紀錄，每種類型最多保留 5 筆，依查詢時間倒序排列。

#### Scenario: 台鐵查詢儲存不影響高鐵查詢列表
- **WHEN** 使用者以台鐵系統執行查詢
- **THEN** 台鐵近期查詢列表新增一筆，高鐵近期查詢列表不受影響

#### Scenario: 超過 5 筆時自動移除最舊紀錄
- **WHEN** 台鐵近期查詢已有 5 筆，使用者再執行一次不同路線的台鐵查詢
- **THEN** 最舊一筆台鐵查詢被移除，新查詢排在最上方

### Requirement: 按鐵路類型清除近期查詢
系統 SHALL 提供 `clearByRailwayType(String railwayType)` 方法，只刪除指定類型的查詢紀錄，不影響另一類型的資料。

#### Scenario: 清除台鐵近期查詢
- **WHEN** 使用者在台鐵模式下點擊「清除全部」
- **THEN** 台鐵近期查詢列表清空，高鐵近期查詢列表保持不變

#### Scenario: 清除高鐵近期查詢
- **WHEN** 使用者在高鐵模式下點擊「清除全部」
- **THEN** 高鐵近期查詢列表清空，台鐵近期查詢列表保持不變

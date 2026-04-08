## ADDED Requirements

### Requirement: 顯示車站選擇 Modal
系統 SHALL 在使用者點擊首頁出發站或到達站輸入欄位時，以底部 Modal 顯示車站選擇介面。

#### Scenario: 點擊出發站開啟 Modal
- **WHEN** 使用者點擊首頁「出發站」輸入欄位
- **THEN** 系統開啟 Modal，標題顯示「選擇出發站」

#### Scenario: 點擊到達站開啟 Modal
- **WHEN** 使用者點擊首頁「到達站」輸入欄位
- **THEN** 系統開啟 Modal，標題顯示「選擇到達站」

#### Scenario: 點擊關閉按鈕
- **WHEN** 使用者點擊 Modal 右上角關閉（×）按鈕
- **THEN** Modal 關閉，出發站與到達站維持原值不變

### Requirement: 車站搜尋功能
Modal SHALL 提供搜尋框，讓使用者輸入站名關鍵字篩選車站清單。

#### Scenario: 輸入搜尋關鍵字
- **WHEN** 使用者在搜尋框輸入關鍵字（如「台北」）
- **THEN** 車站清單即時篩選，只顯示站名包含該關鍵字的車站

#### Scenario: 清空搜尋框
- **WHEN** 使用者清空搜尋框
- **THEN** 車站清單恢復顯示當前城市篩選下的所有車站

### Requirement: 城市篩選 Tabs
Modal SHALL 顯示城市篩選 tabs，依城市分組篩選車站清單。

#### Scenario: 顯示城市 tabs
- **WHEN** Modal 開啟，車站清單載入完成後
- **THEN** 顯示依城市分組的 FilterChip tabs，包含「全部」及各城市名稱

#### Scenario: 點擊城市 tab
- **WHEN** 使用者點擊某城市 tab（如「台北市」）
- **THEN** 車站清單篩選為該城市的車站，搜尋關鍵字同步套用

#### Scenario: 選擇「全部」tab
- **WHEN** 使用者點擊「全部」tab
- **THEN** 車站清單顯示所有車站（搜尋關鍵字仍套用）

### Requirement: 選擇車站並回填
使用者 SHALL 能從清單中點選車站，系統將所選站名與站代碼回填至對應輸入欄位。

#### Scenario: 選擇車站
- **WHEN** 使用者點擊清單中某車站（如「台北車站」）
- **THEN** Modal 關閉，對應欄位（出發站或到達站）更新為所選車站名稱與站代碼

#### Scenario: 顯示目前已選車站
- **WHEN** Modal 開啟時，該欄位已有選定車站
- **THEN** 目前已選車站旁顯示勾選標記（✓）

### Requirement: 載入車站清單狀態
Modal SHALL 在車站資料尚未載入時顯示載入中狀態，載入失敗時顯示錯誤提示。

#### Scenario: 車站載入中
- **WHEN** Modal 開啟，車站清單尚未從 API 載入完成
- **THEN** 顯示載入中 indicator

#### Scenario: 車站載入失敗
- **WHEN** 車站 API 請求失敗
- **THEN** 顯示錯誤訊息，提供重試按鈕
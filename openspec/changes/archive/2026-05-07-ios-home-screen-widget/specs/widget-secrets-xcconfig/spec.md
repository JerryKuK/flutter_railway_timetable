## ADDED Requirements

### Requirement: Secrets.xcconfig 注入 TDX 憑證
系統 SHALL 使用 `Secrets.xcconfig` 提供 Widget Extension 所需的 TDX Client ID 與 Client Secret，不以明文存於版本控制中。

#### Scenario: Secrets.xcconfig 存在且包含必要鍵值
- **WHEN** Developer 在本機建立 `ios/RailwayWidget/Secrets.xcconfig`
- **THEN** 檔案包含 `TDX_CLIENT_ID = <實際值>` 與 `TDX_CLIENT_SECRET = <實際值>` 兩行；Widget Extension target 的 Build Settings 引用此 xcconfig

#### Scenario: Secrets.xcconfig 不入版控
- **WHEN** 查看 git tracked 檔案
- **THEN** `ios/RailwayWidget/Secrets.xcconfig` 在 `ios/.gitignore` 中，不被追蹤


### Requirement: Info.plist 橋接 xcconfig 變數
Widget Extension 的 `Info.plist` SHALL 定義對應鍵值，將 xcconfig 變數橋接至可由 Swift runtime 讀取的 `Bundle.main.infoDictionary`。

#### Scenario: Info.plist 包含 TDX 鍵值
- **WHEN** Widget Extension target 的 `Info.plist` 載入
- **THEN** 包含 `TDX_CLIENT_ID` 鍵，值為 `$(TDX_CLIENT_ID)`；包含 `TDX_CLIENT_SECRET` 鍵，值為 `$(TDX_CLIENT_SECRET)`

#### Scenario: Swift 側正確讀取憑證
- **WHEN** `TDXAuthManager` 初始化時呼叫 `Bundle.main.infoDictionary`
- **THEN** 成功取得非空字串的 `TDX_CLIENT_ID` 與 `TDX_CLIENT_SECRET`

#### Scenario: 憑證缺失時明確錯誤
- **WHEN** `Bundle.main.infoDictionary["TDX_CLIENT_ID"]` 回傳 nil、空字串或未展開的佔位值 `$(TDX_CLIENT_ID)`
- **THEN** `TDXAuthManager.init()` 拋出 `TDXAuthError.missingCredentials`；`RefreshTimetableIntent.perform()` 捕獲後寫入 `widget_last_error`，Widget 顯示錯誤狀態而不崩潰

---

### Requirement: README 設定指引
專案 `README.md` SHALL 包含 Widget Extension 的 secrets 設定步驟，讓新 developer 能在 10 分鐘內完成本地設定。

#### Scenario: README 包含 xcconfig 設定步驟
- **WHEN** Developer 閱讀 README 中「Widget Extension 本地設定」區段
- **THEN** 看到以下步驟：(1) 在 `ios/RailwayWidget/` 手動建立 `Secrets.xcconfig`；(2) 填入 TDX Client ID / Secret；(3) 確認 Xcode target Build Settings 引用 xcconfig

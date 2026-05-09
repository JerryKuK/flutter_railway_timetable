## ADDED Requirements

### Requirement: local.properties 存放 TDX 憑證
系統 SHALL 使用 `android/local.properties` 提供 Android Widget 所需的 TDX Client ID 與 Client Secret，不以明文存於版本控制中（對稱 iOS `Secrets.xcconfig` 機制）。

#### Scenario: local.properties 包含必要鍵值
- **WHEN** Developer 在本機 `android/local.properties` 設定憑證
- **THEN** 檔案包含 `TDX_CLIENT_ID=<實際值>` 與 `TDX_CLIENT_SECRET=<實際值>` 兩行；`build.gradle.kts` 透過 `rootProject.file("local.properties")` 讀取並以 `buildConfigField` 注入 `BuildConfig.TDX_CLIENT_ID` 與 `BuildConfig.TDX_CLIENT_SECRET`

#### Scenario: local.properties 不入版控
- **WHEN** 查看 git tracked 檔案
- **THEN** `android/local.properties` 在 `android/.gitignore` 中（Flutter 預設已包含），不被追蹤；CI 環境透過環境變數或 secrets 注入

---

### Requirement: BuildConfig 橋接憑證至 Kotlin Runtime
`build.gradle.kts` SHALL 讀取 `local.properties` 的 TDX 鍵值，透過 `buildConfigField` 定義為 `BuildConfig` string field，供 `KotlinTdxAuthManager` runtime 讀取。

#### Scenario: BuildConfig 包含 TDX 鍵值
- **WHEN** `./gradlew assembleDebug` 完成
- **THEN** `BuildConfig.TDX_CLIENT_ID` 與 `BuildConfig.TDX_CLIENT_SECRET` 為非空字串；`KotlinTdxAuthManager` 初始化時能正確取得憑證

#### Scenario: local.properties 缺少憑證時 BuildConfig 為空字串
- **WHEN** `local.properties` 未包含 `TDX_CLIENT_ID` 鍵
- **THEN** `BuildConfig.TDX_CLIENT_ID` 為空字串 `""`；`KotlinTdxAuthManager.getValidToken()` 偵測空值後拋出 `WidgetAuthException("ERR_NO_CREDENTIALS")`，Widget 顯示錯誤狀態而不崩潰

---

### Requirement: README 設定指引
專案 `README.md` SHALL 包含 Android Widget 的 credentials 設定步驟，讓新 developer 能在 5 分鐘內完成本地設定（對稱 iOS `widget-secrets-xcconfig` README 要求）。

#### Scenario: README 包含 Android Widget 設定步驟
- **WHEN** Developer 閱讀 README 中「Android Widget 本地設定」區段
- **THEN** 看到以下步驟：(1) 開啟 `android/local.properties`；(2) 加入 `TDX_CLIENT_ID=你的ID` 與 `TDX_CLIENT_SECRET=你的Secret`；(3) 確認 `local.properties` 已在 `android/.gitignore`
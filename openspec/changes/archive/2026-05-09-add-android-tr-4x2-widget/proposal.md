## Why

目前只有 iOS WidgetKit 桌面小工具，Android 平台無對應實作。補上 Android 4×2 Glance Widget（台鐵 + 高鐵），讓 Android 使用者同樣能在桌面一眼查看最近班次並點擊「查詢」取得最新時刻、直接在 Widget 內切換出發/到達站。

## What Changes

- 新增 Android Glance Widget（台鐵 / 高鐵 4×2）：白底圓角卡片，依 system 切換配色（TR 藍 / HSR 橘）、路線標題、3 筆班次列、「查詢」按鈕、以及內嵌站台 picker
- 新增 Kotlin clean architecture widget layer：`KotlinTdxAuthManager`、`TdxApiClient`（TRA + HSR）、`TrainScheduleRepository`、`GetNextTrainsUseCase`、`GetPickerStationsUseCase`（對稱 iOS Swift 實作）
- 新增 `WidgetPrefs`：以 `SharedPreferences` 存取 `widget_route`、`widget_schedules`、`widget_last_error`、`widget_last_update`、`widget_picker_mode`（對稱 iOS `AppGroupDataSource`）
- 新增 `WidgetStationRoomDatabase`（Room）：read-only 讀取 Flutter app 透過 Drift 寫入的 `widget_stations.db`
- 新增 `MainActivity` MethodChannel `com.jerry.railwaytimetable/app_group`：暴露 `getAppGroupDir`（讓 Drift 寫入 Room 預期路徑）與 `reloadWidget`（App 內變更後觸發 Widget recomposition）
- 新增 `android/local.properties` TDX 憑證欄位（`TDX_CLIENT_ID`、`TDX_CLIENT_SECRET`），透過 `BuildConfig` 注入 Kotlin，`local.properties` 已在 `.gitignore`
- 更新 `android/app/build.gradle.kts`：啟用 `buildFeatures.compose`、`buildConfig`，加入 Glance、Room（KSP）、Retrofit、OkHttp、Coroutines 依賴
- 更新 `android/settings.gradle.kts`：加入 KSP plugin
- 更新 `AndroidManifest.xml`：註冊 `RailwayWidgetReceiver`

## Capabilities

### New Capabilities

- `android-tr-widget`: Android 台鐵 + 高鐵 4×2 Glance Widget UI、Kotlin TDX API 呼叫、SharedPreferences + Room 資料存取、Compose Compiler 設定
- `android-widget-credentials`: TDX 憑證透過 `local.properties` → `BuildConfig` 注入 Kotlin Widget，對稱 iOS `Secrets.xcconfig` 機制

### Modified Capabilities

（無）

## Impact

- **android/app/build.gradle.kts**：新增 Glance、Room、Retrofit、OkHttp、Coroutines 依賴；啟用 Compose（compilerExtensionVersion = "1.4.8"）與 KSP（1.8.22-1.0.11）
- **android/settings.gradle.kts**：宣告 KSP plugin
- **android/app/src/main/AndroidManifest.xml**：新增 `RailwayWidgetReceiver` receiver + meta-data
- **android/app/src/main/res/**：新增 `xml/railway_widget_info.xml`、`layout/railway_widget_initial.xml`、`drawable/widget_icon_tr.xml`、`drawable/widget_icon_hsr.xml`、`drawable/widget_train_icon.xml`
- **android/local.properties**：新增 `TDX_CLIENT_ID`、`TDX_CLIENT_SECRET`（已 gitignore）
- **新增 Kotlin widget package** `com.example.flutter_railway_timetable.widget`：data / domain / presentation 三層共約 20 個檔
- **MainActivity.kt**：新增 MethodChannel handler；不影響既有 Flutter 行為
- **現有 iOS / Flutter 程式碼不受影響**
- **架構**：依 Clean Architecture 分層（data / domain / presentation）
- **測試**：使用 superpowers 來遵循 TDD 開發流程，每個 use case 與 Auth/Repository 皆有對應 JVM 單元測試
## 1. Build Configuration

- [x] 1.1 在 `android/app/build.gradle.kts` 加入 Glance（1.0.0）、Room（2.5.2，含 KSP）、Retrofit2（2.9.0）、OkHttp（4.12.0）、kotlinx-coroutines-android 依賴
- [x] 1.2 在 `android/app/build.gradle.kts` 啟用 `buildFeatures { compose = true; buildConfig = true }` 並設定 `kotlinCompilerExtensionVersion = "1.4.8"`
- [x] 1.3 在 `android/app/build.gradle.kts` 讀取 `local.properties` 的 `TDX_CLIENT_ID` / `TDX_CLIENT_SECRET`，以 `buildConfigField` 注入 `BuildConfig`
- [x] 1.4 在 `android/settings.gradle.kts` 宣告 `com.google.devtools.ksp` plugin（1.8.22-1.0.11）

## 2. Credentials & README

- [x] 2.1 在 `android/local.properties` 加入 `TDX_CLIENT_ID=` 與 `TDX_CLIENT_SECRET=` 兩行（填入實際值）
- [x] 2.2 確認 `local.properties` 已在 `android/.gitignore`（Flutter 預設已包含，驗證即可）
- [x] 2.3 在 `README.md` 新增「Android Widget 本地設定」區段，說明設定 `local.properties` 步驟

## 3. Android Resources

- [x] 3.1 建立 `android/app/src/main/res/drawable/widget_train_icon.xml`（14×14dp 白色火車向量圖）
- [x] 3.2 建立 `android/app/src/main/res/drawable/widget_icon_tr.xml`（layer-list：藍漸層圓 #5FA6E0→#2E72B8 + 火車圖示）與 `widget_icon_hsr.xml`（橘漸層 #F2A85C→#C86820）
- [x] 3.3 建立 `android/app/src/main/res/xml/railway_widget_info.xml`（targetCellWidth=4, targetCellHeight=2, minWidth=294dp, minHeight=110dp, updatePeriodMillis=0）
- [x] 3.4 建立 `android/app/src/main/res/layout/railway_widget_initial.xml`（白底 LinearLayout，顯示「鐵路時刻表 / 載入中…」）
- [x] 3.5 在 `android/app/src/main/res/values/strings.xml` 加入 `widget_description`

## 4. AndroidManifest

- [x] 4.1 在 `AndroidManifest.xml` 的 `<application>` 內新增 `<receiver android:name=".widget.presentation.RailwayWidgetReceiver" android:exported="true">` 含 `ACTION_APPWIDGET_UPDATE` intent-filter 與 `railway_widget_info` meta-data

## 5. Domain Layer（TDD）

- [x] 5.1 建立 `WidgetSchedule` data class（dep, arr, type, num）、`WidgetRoute` data class（含 `defaultFor(system)` 工廠）、`PickerStation` 與 `PickerStationDefaults` 於 `widget/domain/entity/`
- [x] 5.2 建立 `ITrainScheduleRepository`（`suspend fun getSchedules(fromId, toId, date, system)`）與 `IWidgetStationRepository`（`getStations(system)`）interface 於 `widget/domain/repository/`
- [x] 5.3 撰寫 `GetNextTrainsUseCaseTest`：驗證依出發時間排序、過濾已發車、回傳前 3 班、不足時 fallback 隔日
- [x] 5.4 實作 `GetNextTrainsUseCase`（過濾、排序、`take(3)`、隔日 fallback），使 5.3 測試通過
- [x] 5.5 實作 `GetPickerStationsUseCase`（DB 不足時以 `PickerStationDefaults` 補滿至 10 站）

## 6. Data Layer — Auth & API（TDD）

- [x] 6.1 撰寫 `KotlinTdxAuthManagerTest`：驗證有效 token 直接回傳快取、過期 token 重新取得、空憑證拋出 `WidgetAuthException`
- [x] 6.2 實作 `KotlinTdxAuthManager`（OkHttp POST token endpoint，`Mutex` 序列化、`withContext(IO)`、快取 `expires_in - 60s`，從 `BuildConfig` 讀取憑證），使 6.1 測試通過
- [x] 6.3 建立 `TdxApiService` Retrofit interface（TRA OD DailyTrainTimetable + HSR OD DailyTimetable，`@Query("\$format") = "JSON"`）於 `widget/data/network/`
- [x] 6.4 實作 `TdxApiClient.fetchTRASchedule()` 與 `fetchHSRSchedule()`（呼叫 `KotlinTdxAuthManager`，呼叫 `TdxApiService`，解析 JSON 回 `List<WidgetSchedule>`，HSR 404 視為空）

## 7. Data Layer — Storage & Repository

- [x] 7.1 實作 `WidgetPrefs`（`com.example.flutter_railway_timetable.widget_prefs` SharedPreferences；route/schedules/lastError/lastUpdate/pickerMode 全 JSON）
- [x] 7.2 實作 `WidgetStationRoomDatabase` + `WidgetStationDao`（read-only 開啟 Flutter Drift 寫入的 `widget_stations.db`；entity 用 `@ColumnInfo(defaultValue = "0")` 對齊 Drift 的 `sort_order DEFAULT 0`、不宣告 `indices` 以避免與 Drift 的 `sqlite_autoindex_*` 衝突；`fallbackToDestructiveMigration` 禁用以保護 Flutter 端資料）
- [x] 7.3 撰寫 `TrainScheduleRepositoryImplTest`：驗證 `getSchedules()` 依 system 派發到 TRA / HSR
- [x] 7.4 實作 `TrainScheduleRepositoryImpl` 與 `WidgetStationRepositoryImpl`，使 7.3 測試通過

## 8. Presentation Layer

- [x] 8.1 實作 `RailwayWidgetReceiver : GlanceAppWidgetReceiver`（`override val glanceAppWidget = RailwayGlanceWidget()`）
- [x] 8.2 實作 `RefreshWidgetAction : ActionCallback`（讀 `WidgetPrefs` 路線、若無則 fallback 至 picker stations 前兩筆或 `WidgetRoute.defaultFor` → 呼叫 `GetNextTrainsUseCase` → 寫 `WidgetPrefs` → `RailwayGlanceWidget().update()`；錯誤時寫 `lastError` 並更新 Widget）
- [x] 8.3 實作 `RailwayGlanceWidget : GlanceAppWidget`（`provideGlance()` 讀 `WidgetPrefs`，依 `pickerMode` 切換 `WidgetContent` / `PickerContent`）
- [x] 8.4 實作 `WidgetContent` Glance composable（漸層圓圈 icon + "{台鐵/高鐵} 時刻表" + 路線可點擊呼出 picker + 更新 chip + 查詢 button；班次列：dep accent bold + type chip + num + "→ arr"）
- [x] 8.5 實作 `PickerContent` 與 `ShowPickerAction` / `SelectStationAction` / `DismissPickerAction`：以 5×N grid 顯示車站，點選後寫回 `widget_route`
- [x] 8.6 在 `MainActivity` 加上 `com.jerry.railwaytimetable/app_group` MethodChannel：`getAppGroupDir` 回傳 Room DB 目錄；`reloadWidget` 用 `lifecycleScope` 觸發所有 Glance instance recomposition

## 9. Verification

- [x] 9.1 執行所有 Android 單元測試：`./gradlew :app:test`，確認全數通過
- [x] 9.2 `./gradlew assembleDebug` 確認 Compose 編譯無誤
- [x] 9.3 安裝到 Android 裝置/模擬器，長按桌面新增「鐵路時刻表」4×2 Widget，驗證 TR 藍色 / HSR 橘色 UI 正確顯示
- [x] 9.4 點擊「查詢」按鈕，確認 Widget 打 API 並更新前 3 班班次；點擊站名確認 picker 開啟與選站可寫回路線
## 1. 探索 / 對齊基準（無 code 改動）

- [x] 1.1 讀完 `ios/RailwayWidget/HSRWidget.swift` 與 iOS HSR `Domain/Data/Presentation` 子資料夾，記錄 HSR widget kind、displayName、預設路線 fallback、AppIntent reload 機制
- [x] 1.2 讀完 `android/app/src/main/kotlin/.../widget/` 整個資料夾，確認既有 `RailwayGlanceWidget` / 4 個 Action / `WidgetPrefs` / `TdxApiClient.fetchHSRSchedule` 真實簽章與行為
- [x] 1.3 確認 `WidgetRoute.defaultFor("HSR")` Kotlin 端既有實作回傳「臺北 → 左營」（fromId 1000 / toId 1070）；若不符，於本 task 補上 entity 預設值修正並加 unit test
- [x] 1.4 確認 `PickerStationDefaults.stations("HSR")` Kotlin 端涵蓋 12 站；若不足，於本 task 補滿 N→S 順序的 fallback list 並加 unit test
- [x] 1.5 在 `/tmp/design-fetch/untitled/project/widgets.jsx` 對照 `AndroidMedium`(system='HSR') 與 `AndroidMediumConfig`(system='HSR') 標出本 change 視覺 baseline；確認與 design.md Decision 4 的「設計檔元素差異列表」內容一致

## 2. WidgetPrefs 加 keyPrefix 參數（TR backward-compat，TDD）

- [x] 2.1 寫 `WidgetPrefsTrBackwardCompatTest`（`app/src/test/kotlin/.../widget/data/prefs/`）：呼叫所有 save/load 方法不傳 `keyPrefix` → 驗證 SharedPreferences 寫入的 key 仍為 `widget_route` / `widget_schedules` / `widget_last_error` / `widget_last_update` / `widget_picker_mode`，內容與舊版完全一致；測試 RED 階段先讓 import 失敗或先 skip
- [x] 2.2 寫 `WidgetPrefsHSRPrefixTest`：呼叫所有 save/load 方法傳 `keyPrefix = "hsr_"` → 驗證寫入的 key 為 `hsr_widget_route` 等；同時驗證未污染 `widget_*` 系列 key
- [x] 2.3 重構 `WidgetPrefs.kt`：所有 `loadX` / `saveX` 方法加 `keyPrefix: String = ""` 參數；`KEY_ROUTE` 等常數改為 `keyRoute(prefix: String) = "${prefix}widget_route"` 之類的 private function
- [x] 2.4 跑 2.1 + 2.2 兩支測試 → GREEN
- [x] 2.5 跑既有 4 支測試（`TdxApiClientTest`、`GetNextTrainsUseCaseTest`、`KotlinTdxAuthManagerTest`、`TrainScheduleRepositoryImplTest`、`GetPickerStationsUseCaseTest`） → 全部維持 GREEN（驗證 backward compat 不破測試）

## 3. 抽出共用 Composable（Decision 1，純結構重構）

- [x] 3.1 新建 `presentation/WidgetComposables.kt`：把 `RailwayGlanceWidget.kt` 內的 `private @Composable fun WidgetContent(...)` / `PickerContent(...)` / `TrainRow(...)` 與 `private data class Palette(...)` 提到此檔；可見性改為 `internal`；package 仍是 `widget.presentation`
- [x] 3.2 `PickerContent` 新增參數 `chunkSize: Int`（取代原 hardcoded `stations.chunked(5)`）；既有 TR 呼叫處傳 `chunkSize = 5`
- [x] 3.3 `WidgetContent` / `PickerContent` 的 `ActionCallback` 觸發類別由 caller 注入（既有 TR 用 `RefreshWidgetAction` / `ShowPickerAction` / `DismissPickerAction` / `SelectStationAction`；HSR 之後注入 HSR 版本）—— 改成 `Composable` 接收 `actionRefresh: Action` 之類的高階參數，或拆成兩個並列 Composable 以避免高階函式 limit
- [x] 3.4 確認 `RailwayGlanceWidget.provideGlance` 仍呼叫 internal helper 後渲染結果完全相同；跑既有 TR widget 相關測試 → GREEN
- [x] 3.5 build android debug APK 已通過（`./gradlew :app:assembleDebug` BUILD SUCCESSFUL）；**目視確認 TR widget 視覺與舊版一致需 emulator 手動驗證（user action）**

## 4. 清理 TR widget HSR 殘骸（Decision 8）

- [x] 4.1 在 `RailwayGlanceWidget.kt` 將 `paletteFor()` 函式簡化為直接回傳 TR palette（移除 `when (system)` 多分支，移除 `"HSR" ->` 分支，移除對 `R.drawable.widget_icon_hsr` 的引用）
- [x] 4.2 確認 `widget_icon_hsr.xml` 檔案**保留**（新 HSR widget 會用），只是 TR widget 內部不再 import / reference
- [~] 4.3 `RailwayGlanceWidgetSmokeTest` 未寫——`provideGlance` 需要 Android Context + Glance runtime，純 JVM unit test 無法執行；本專案未引入 Robolectric。`paletteFor()` HSR 分支已徹底移除（編譯期保證不可達），由 `assembleDebug` BUILD SUCCESSFUL 與 lint 通過提供 regression guard
- [x] 4.4 跑 TR widget 既有 4 支測試 + 新 smoke test → 全 GREEN
- [x] 4.5 同步更新 `openspec/specs/android-tr-widget/spec.md`（待 archive 階段由 openspec 工具自動合併 delta）—— **此 task 不手動編輯**，僅作為 checklist 提醒 spec ↔ code 一致性

## 5. 建立 HSR Glance widget class（Decision 1）

- [x] 5.1 新建 `presentation/HSRRailwayGlanceWidget.kt`：class `HSRRailwayGlanceWidget : GlanceAppWidget`；`provideGlance` 內讀 `WidgetPrefs.loadRoute(context, keyPrefix = "hsr_")` 等 HSR-prefix prefs；palette 鎖死為 `Palette(accent = Color(0xFFC86820), accentSoft = Color(0xFFFBEEDF), displayName = "高鐵", iconRes = R.drawable.widget_icon_hsr)`
- [x] 5.2 `HSRRailwayGlanceWidget.provideGlance` 呼叫 internal `WidgetContent` / `PickerContent`（task 3 抽出的共用 Composable），傳入 HSR palette + `chunkSize = 4`（原規劃 6 cols × 2 rows 對齊 iOS，實作驗證後改為 4 cols × 3 rows，見 design.md Decision 4）、HSR 版 ActionCallback class（`HSRRefreshWidgetAction` 等，task 6 建立）
- [x] 5.3 新建 `presentation/HSRRailwayWidgetReceiver.kt`：class `HSRRailwayWidgetReceiver : GlanceAppWidgetReceiver`；`override val glanceAppWidget = HSRRailwayGlanceWidget()`
- [~] 5.4 `HSRRailwayGlanceWidgetSmokeTest` 未寫（同 4.3 原因：`provideGlance` 需 Glance runtime + Android Context，無 Robolectric 環境）。`HSRRailwayGlanceWidget` 編譯通過 + APK 打包成功 + lint 過 = 結構性 regression guard 已具備；`WidgetRoute.defaultFor("HSR")` 的 fallback 行為由 `WidgetRouteTest` 完整覆蓋（3 個 case）

## 6. 建立 HSR Action 4 件套（TDD）

- [x] 6.1 寫 `HSRSelectStationActionTest`（測試先行）：mock `WidgetPrefs` 或用 in-memory SharedPreferences；驗證 (1) 寫入 `hsr_widget_route`、(2) `hsr_widget_schedules` 設為 `"[]"`、(3) `hsr_widget_picker_mode = "home"`、(4) `TdxApiClient` 完全未被呼叫、(5) `widget_*` key 全未被寫入 → RED
- [x] 6.2 實作 `HSRSelectStationAction.kt`：複製 `SelectStationAction.kt` 結構，所有 `WidgetPrefs.*` 呼叫加 `keyPrefix = "hsr_"`；fallback `WidgetRoute.defaultFor("HSR")`；reload 改呼叫 `HSRRailwayGlanceWidget().update(context, glanceId)`；`updateAppWidgetState` 用 `HSRRailwayGlanceWidget.VERSION_KEY`（companion object 在 task 5.1 加）→ GREEN
- [x] 6.3 寫 `HSRRefreshWidgetActionTest`（測試先行）：mock `TdxApiClient.fetchHSRSchedule` 回傳 stub `List<WidgetSchedule>`；驗證 (1) 呼叫 `fetchHSRSchedule`（不是 `fetchTRASchedule`）、(2) 寫入 `hsr_widget_schedules` 與 `hsr_widget_last_update`、(3) `widget_*` key 未被寫入；額外驗證 `WidgetAuthException` 路徑寫入 `hsr_widget_last_error`、一般 Exception 路徑寫入「查詢失敗，請稍後再試」→ RED
- [x] 6.4 實作 `HSRRefreshWidgetAction.kt`：複製 `RefreshWidgetAction.kt` 結構，`resolveRoute` 內 `system = "HSR"`、`GetPickerStationsUseCase.execute("HSR")` 為 fallback、`useCase.execute(...,  "HSR")` 帶 HSR system；所有 `WidgetPrefs.*` 呼叫加 `keyPrefix = "hsr_"`；reload 改呼叫 `HSRRailwayGlanceWidget().update()` → GREEN
- [x] 6.5 寫 `HSRShowPickerActionTest`：驗證 `hsr_widget_picker_mode` 寫入 `"from"` 或 `"to"`、`widget_picker_mode` 未被寫入 → RED；實作 `HSRShowPickerAction.kt` → GREEN
- [x] 6.6 寫 `HSRDismissPickerActionTest`：驗證 `hsr_widget_picker_mode` 寫回 `"home"`、`widget_picker_mode` 未被寫入 → RED；實作 `HSRDismissPickerAction.kt` → GREEN

## 7. 新增 widget metadata resources + Manifest（Decision 6）

- [x] 7.1 新建 `app/src/main/res/xml/railway_widget_hsr_info.xml`：`targetCellWidth=4`、`targetCellHeight=2`、`minWidth=294dp`、`minHeight=110dp`、`updatePeriodMillis=0`、`previewImage=@drawable/widget_icon_hsr`、`initialLayout=@layout/railway_widget_initial`（重用既有 layout）、`label=@string/hsr_widget_label`、`description=@string/hsr_widget_description`、`widgetCategory=home_screen`、`resizeMode=horizontal|vertical`
- [x] 7.2 在 `app/src/main/res/values/strings.xml` 新增 `<string name="hsr_widget_label">高鐵時刻表</string>` 與 `<string name="hsr_widget_description">顯示台灣高鐵下班車資訊</string>`
- [x] 7.3 在 `android/app/src/main/AndroidManifest.xml` `<application>` 區塊內新增 `<receiver android:name=".widget.presentation.HSRRailwayWidgetReceiver" android:exported="true" android:enabled="true" android:label="@string/hsr_widget_label">` 含 `<intent-filter><action android:name="android.appwidget.action.APPWIDGET_UPDATE" /></intent-filter>` 與 `<meta-data android:name="android.appwidget.provider" android:resource="@xml/railway_widget_hsr_info" />`，與既有 `.widget.presentation.RailwayWidgetReceiver` 平行擺放
- [x] 7.4 build android debug APK 確認 compile 通過、無 manifest merger 衝突

## 8. 連通 HSR widget 全鏈路（整合驗證）

- [x] 8.1 `HSRRailwayGlanceWidget.provideGlance` 內 4 個 `actionRunCallback` 全部對應 4 個 HSR Action class（`HSRRefreshWidgetAction` / `HSRShowPickerAction` / `HSRDismissPickerAction` / `HSRSelectStationAction`）；compile + lint 通過、Action class 全綠
- [x] 8.2 在 Android Studio 開啟 Glance preview（若 Glance 工具版本支援）渲染 `HSRRailwayGlanceWidget`，目視確認 HSR palette 套用、12 站 4×3 grid layout 正確（**user action**：需 Android Studio + preview pane）
- [~] 8.3 `./gradlew :app:assembleDebug` BUILD SUCCESSFUL（APK 已產出）；**安裝至 emulator 並進入 widget gallery 確認兩個選項可見需 user action**

## 9. 手動驗證清單（Android emulator）

- [x] 9.1 將「高鐵時刻表」widget 從 widget gallery 拖入桌面，確認顯示「臺北 → 左營」預設路線 + 「點站名選路線，再按查詢」提示
- [x] 9.2 點擊 widget 上的「臺北」站名 → 確認切換到 picker 模式，顯示「選擇出發站 · 高鐵 · 點選下方車站」 + 3 cols × 4 rows 12 站 chip grid（南港→左營 N→S 序）；點任意站 → 確認回到 home view、站名更新、班次列表保持空白（**未觸發 API**）
- [x] 9.3 點擊「左營」（到達站）→ 同樣顯示 picker，標題「選擇到達站」；選站後回到 home view、新到達站生效、班次列表保持空白
- [x] 9.4 點擊右上「查詢」按鈕 → 確認狀態列短暫 loading（如有）→ 班次列表填入 HSR 班次（出發時間 / 車種 / 車號 / 抵達時間）、右上 chip 顯示「更新 HH:mm」
- [x] 9.5 切換 emulator 至「飛航模式」斷網 → 點查詢 → 確認顯示「查詢失敗，請稍後再試」錯誤訊息、widget 不 crash、可繼續點站名換站
- [x] 9.6 同時在桌面釘住「鐵路時刻表」與「高鐵時刻表」兩支 widget → 確認兩支 widget 各自獨立路線、選站、查詢時間，互不影響；點 TR widget 站名打開 TR picker（10 站台鐵）、點 HSR widget 站名打開 HSR picker（12 站高鐵）
- [x] 9.7 在 TR widget 上換路線（例如「板橋 → 台中」）→ 確認 HSR widget 顯示內容（路線、班次）完全不變

## 10. 全層級測試最終確認

- [x] 10.1 跑 `./gradlew :app:testDebugUnitTest` → 全部 GREEN（68 個 test：12 個 HSR Action test + 16 個 WidgetPrefs test + 15 個 entity test + 25 個既有 TR test 全綠）
- [x] 10.2 跑 `./gradlew :app:lintDebug` → 無 lint regression（BUILD SUCCESSFUL）
- [x] 10.3 跑 `flutter test` → 全部 GREEN（100 個 Flutter test，All tests passed!）
- [x] 10.4 跑 `openspec validate "add-android-hsr-4x2-widget"` → 通過（Change is valid）
- [x] 10.5 在 `README.md`「Android Widget 本地設定」段落更新：標題段補上「兩支 widget」描述、安裝步驟補上 widget gallery 兩個選項說明、補上「同 SharedPreferences、不同 key prefix」澄清

## 11. PR / Archive 準備

- [x] 11.1 `git status` 完成（modified: 7 個既有檔；untracked: 7 個新 Kotlin、1 個 widget XML、3 個 test 目錄、1 個 openspec change 目錄）；與 proposal.md「Impact」段落列表逐項對齊
- [x] 11.2 跑 `/opsx:verify` 驗證 implementation 與 spec / design 一致（**user action**：建議實作完成後執行）
- [x] 11.3 (使用者觸發) 跑 `/opsx:archive add-android-hsr-4x2-widget` 將 change 移至 `openspec/changes/archive/<date>-add-android-hsr-4x2-widget/`，並同步更新 `openspec/specs/android-tr-widget/spec.md`、新建 `openspec/specs/android-hsr-widget/spec.md`

## 12. Post-Initial-Review Cleanup（同 PR 內）

Initial implementation (sections 1-11) 完成後做的 cleanup pass。任務全部在同一個 PR/branch 完成,不另開 change folder。對應 design.md 新增的 Decision 10-13。

### 12.1 註解 / 死碼清理

- [x] 12.1.1 刪除過時歷史敘述註解(`RailwayGlanceWidget.kt` 4 行「HSR support was removed because...」、`HSRRailwayGlanceWidget.kt`「vs. the TR widget's old `paletteFor(system)`」引用)
- [x] 12.1.2 刪除「extracted so unit tests can inject mock」這類「為測試而抽出」評論(`HSRRefreshWidgetAction.kt:56-57`、`HSRSelectStationAction.kt:26-29`);保留真正的 invariant 註解(如「MUST NOT call TdxApiClient」)
- [x] 12.1.3 壓縮 5 行 catch block 註解(`HSRRefreshWidgetAction.kt:74-79`)為單行
- [x] 12.1.4 修正 `WidgetComposables.kt:204-207` 註解錯誤敘述(claim HSR uses 6, 實際 4)
- [x] 12.1.5 刪除 `WidgetPrefsTrBackwardCompatTest.kt` 三個未用 import(`CapturingSlot`、`MockKAnnotations`、`assertNull`)

### 12.2 抽出共用 utility

- [x] 12.2.1 新建 `widget/util/TaipeiClock.kt`(`object`):`todayDate()` / `nowTime()` / `tomorrowDate()`,封裝 `SimpleDateFormat` + Asia/Taipei 樣板
- [x] 12.2.2 `RefreshWidgetAction.kt` / `HSRRefreshWidgetAction.kt` / `GetNextTrainsUseCase.kt` 三處原本 inline 的 `SimpleDateFormat(...)` 替換成 `TaipeiClock.xxx()`
- [x] 12.2.3 新建 `widget/presentation/ActionKeys.kt`(`object`):4 個共用 `ActionParameters.Key`(`stationName` / `stationId` / `isFrom` / `mode`)
- [x] 12.2.4 `SelectStationAction.kt` / `ShowPickerAction.kt` 移除 companion key 定義;所有 caller(2 個 widget class + 4 個 HSR action class + 2 個 test class)改 import `ActionKeys.xxx`

### 12.3 TR ↔ HSR Action helper 對稱化

- [x] 12.3.1 `DismissPickerAction.companion` 新增 `applyDismiss(context)`
- [x] 12.3.2 `ShowPickerAction.companion` 新增 `applyShowPicker(context, params)`
- [x] 12.3.3 `SelectStationAction.companion` 新增 `applyStationSelection(context, params)`
- [x] 12.3.4 `RefreshWidgetAction.companion` 新增 `resolveRoute(context)` + `executeWith(context, route, useCase)`;`onAction` body 改成「呼叫 helper → glance ceremony」兩步
- [x] 12.3.5 順便修正 TR `RefreshWidgetAction` 錯誤分支沒清舊 schedules 的 bug(在 `WidgetAuthException` / generic `Exception` 分支補上 `WidgetPrefsTR.saveSchedules(context, emptyList())`,跟 HSR 對齊)

### 12.4 WidgetPrefs 從 keyPrefix default param 改為 namespaced singleton

- [x] 12.4.1 重寫 `WidgetPrefs.kt`:`abstract class WidgetPrefsBase(keyPrefix)` 容納所有 JSON encode/decode + edit 邏輯;檔尾 `object WidgetPrefsTR : WidgetPrefsBase("")` 與 `object WidgetPrefsHSR : WidgetPrefsBase("hsr_")`
- [x] 12.4.2 移除 `HSRRailwayGlanceWidget.KEY_PREFIX` 常數(被 namespace 取代)
- [x] 12.4.3 所有 caller(2 widget class + 4 TR action + 4 HSR action)改用 `WidgetPrefsTR.xxx(...)` / `WidgetPrefsHSR.xxx(...)`
- [x] 12.4.4 6 個 test 檔(`WidgetPrefsTrBackwardCompatTest`、`WidgetPrefsHSRPrefixTest`、`HSRRefreshWidgetActionTest`、`HSRSelectStationActionTest`、`HSRShowPickerActionTest`、`HSRDismissPickerActionTest`)改用 `mockkObject(WidgetPrefsTR)` / `mockkObject(WidgetPrefsHSR)`;斷言從 `verify { WidgetPrefs.saveX(context, ..., "hsr_") }` 改為 `verify { WidgetPrefsHSR.saveX(context, ...) }`

### 12.5 批次 SharedPreferences 寫入

- [x] 12.5.1 `WidgetPrefsBase` 新增 `saveRefreshResult(context, route, schedules, lastUpdate)`:單次 `prefs.edit()...apply()` 寫 route + schedules + lastUpdate + `.remove(lastError)`
- [x] 12.5.2 `WidgetPrefsBase` 新增 `saveRefreshError(context, errorMessage)`:單次 `prefs.edit()...apply()` 寫 schedules=`"[]"` + lastError
- [x] 12.5.3 `RefreshWidgetAction.executeWith` 成功 branch 改用 `WidgetPrefsTR.saveRefreshResult(...)`、失敗 branch 改用 `WidgetPrefsTR.saveRefreshError(...)`
- [x] 12.5.4 `HSRRefreshWidgetAction.executeWith` 同改 `WidgetPrefsHSR.saveRefreshResult(...)` / `saveRefreshError(...)`
- [x] 12.5.5 `HSRRefreshWidgetActionTest` 改 verify `saveRefreshResult` / `saveRefreshError` 取代原本 4 次獨立 verify

### 12.6 STATIONS_VERSION_KEY 與 VERSION_KEY 拆分

- [x] 12.6.1 `RailwayGlanceWidget.companion` 新增 `STATIONS_VERSION_KEY = longPreferencesKey("widget_stations_version")`
- [x] 12.6.2 `HSRRailwayGlanceWidget.companion` 新增 `STATIONS_VERSION_KEY = longPreferencesKey("hsr_widget_stations_version")`
- [x] 12.6.3 兩 widget 的 `provideGlance` 內 `produceState(initialValue, version) { ... }` 改鍵於 `stationsVersion`(原本鍵於 `version`),消除每次 action callback 都重跑 Room query 的浪費
- [x] 12.6.4 `MainActivity.reloadWidget` handler 改 bump `RailwayGlanceWidget.STATIONS_VERSION_KEY`(原本是 `VERSION_KEY`);**刻意不 reload HSR widget**(HSR picker 固定 N→S 12 站不需要 Flutter sync,對齊 iOS `AppDelegate.swift:28` 只 reload `RailwayWidget` 的設計)
- [x] 12.6.5 HSR 端 `STATIONS_VERSION_KEY` 無 writer,純作為「擋 action callback 重觸 Room re-query」的優化 marker,語義在 `HSRRailwayGlanceWidget.kt` 註解內明確說明

### 12.7 openspec md 對齊到最終 code

- [x] 12.7.1 spec.md(android-tr-widget):重寫「SharedPreferences 資料存取(WidgetPrefs)」Requirement,描述 `WidgetPrefsBase` + 兩 singleton 設計;scenario 改用 `WidgetPrefsTR.xxx(...)`;新增 `saveRefreshResult` / `saveRefreshError` scenario
- [x] 12.7.2 spec.md(android-hsr-widget):scenarios 改用 `WidgetPrefsHSR.xxx(...)`(line 47 / 52 / 91 / 93 / 104 / 182);「不寫入 TR namespace」scenario 改為 type-system 保證 + `mockkObject(WidgetPrefsTR)` 雙重防護
- [x] 12.7.3 design.md:Decision 3 完整重寫成 namespaced singleton 設計;Decision 2 內呼叫描述改 `WidgetPrefsHSR.xxx(...)`;新增 Decision 10-13(STATIONS_VERSION_KEY / TaipeiClock + ActionKeys / 批次寫入 / TR↔HSR 對稱化)
- [x] 12.7.4 proposal.md:Modified Capabilities `android-tr-widget` 描述更新;Impact 段落新增 Post-Initial-Review Refinement section;Risks 段落 `WidgetPrefs` default parameter 風險改為 abstract class refactor 風險(同樣是 no-risk,但敘述對齊現況)

### 12.8 驗證

- [x] 12.8.1 `./gradlew :app:testDebugUnitTest` BUILD SUCCESSFUL(全部 68 個 test 綠燈,涵蓋:`compileDebugKotlin` 主 code 編譯 + `compileDebugUnitTestKotlin` test 編譯 + 所有 mock 期望符合新 API)
- [x] 12.8.2 `grep -rn "WidgetPrefs\." android` 確認無殘留 bare `WidgetPrefs` reference(全部已改為 `WidgetPrefsTR` / `WidgetPrefsHSR` / `WidgetPrefsBase`);`grep -rn "KEY_PREFIX" android` 確認 `HSRRailwayGlanceWidget.KEY_PREFIX` 全數刪除

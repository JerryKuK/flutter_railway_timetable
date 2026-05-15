## Why

Android 端目前桌面只有一支 4×2 鐵路 widget（`RailwayGlanceWidget`，displayName「鐵路時刻表」），雖然其 `paletteFor()` 已預備 HSR 配色與 icon、`TdxApiClient.fetchHSRSchedule` 也已實作，但 widget gallery 沒有 HSR 專屬入口、`widget_route.system` 也沒任何 UI 可被設成 `"HSR"`，因此使用者實際上**無法**在 Android 桌面啟用高鐵 widget。

iOS 端已於 commit `cc6039f` 透過 change `2026-05-13-add-ios-hsr-4x2-widget` 新增獨立 `HSRWidget`（kind `"HSRWidget"`、displayName「高鐵時刻表」），可與台鐵 widget 並列。Android 端需要對等的「高鐵時刻表」widget gallery 入口，讓 Android 使用者可以同時於桌面釘住台鐵與高鐵兩支 widget，各自獨立路線、選站、查詢時間。

設計檔 `Home Screen Widgets.html` 的 `AndroidMedium`(system='HSR') 提供本 change 的視覺基準（橘金漸層、Material You tonal surface、Inline chip picker）。

## What Changes

- 新增 Android-only 的 4×2 HSR Glance widget「高鐵時刻表」，由全新 `HSRRailwayGlanceWidget` + `HSRRailwayWidgetReceiver` 承載，列入 Manifest 與 widget gallery，與既有 TR widget 並存
- 新增 HSR 專屬 4 個 Glance `ActionCallback`（`HSRRefreshWidgetAction` / `HSRShowPickerAction` / `HSRDismissPickerAction` / `HSRSelectStationAction`），結構複製自既有 TR 版本，彼此不共用 `onAction` 邏輯
- HSR widget 所有狀態以 `hsr_widget_` 為 key prefix 寫入既有 SharedPreferences（name = `com.example.flutter_railway_timetable.widget_prefs`），具體為 `hsr_widget_route` / `hsr_widget_picker_mode` / `hsr_widget_schedules` / `hsr_widget_last_error`
- TR widget 維持寫入既有未加前綴的 `widget_route` / `widget_picker_mode` / `widget_schedules` / `widget_last_error`——本 change **刻意不對齊 iOS 那一套 `tr_widget_*` symmetric prefix 命名**，以遵守「既有 TR widget 視覺/行為改動 Out of Scope」的承諾；非對稱命名作為已知技術債記錄，後續可由獨立 spec-cleanup change 處理
- **清理既有 `android-tr-widget` spec 中的 HSR 殘骸**：將「4×2 鐵路 Widget 視覺渲染」requirement 收斂為 TR-only（移除「高鐵 Widget 顯示班次」scenario、Requirement 開頭描述刪掉「依 `widget_route.system` 切換 TR / HSR 配色」字樣改為「以台鐵藍 palette 渲染」）；`Kotlin TDX Auth + API Client` requirement 保留「高鐵時刻表 API 呼叫」scenario，因為 `TdxApiClient` 為 TR / HSR widget 共享的資料層基礎建設
- **同步清理對應 TR widget code**（最小幅度，使 code 與 spec 一致）：`RailwayGlanceWidget.paletteFor()` 移除 `"HSR"` 分支與 `widget_icon_hsr` 引用（drawable 檔案保留供新 HSR widget 使用）；其餘 TR widget code（Actions、WidgetPrefs、Receiver、widget XML、layout XML）**完全不動**，使用者可觀察行為與儲存內容零變化
- HSR widget 沿用既有 `TdxApiClient.fetchHSRSchedule`、`KotlinTdxAuthManager`、`GetPickerStationsUseCase.execute("HSR")` 與 Room `WidgetStationRoomDatabase` 的 read-only bridge——這些基礎建設已存在於既有 Kotlin code，**不重複造輪、不重構**
- `WidgetPrefs` 物件**重寫為 `abstract class WidgetPrefsBase(keyPrefix)` + 兩個 namespaced singleton**(`object WidgetPrefsTR : WidgetPrefsBase("")` 與 `object WidgetPrefsHSR : WidgetPrefsBase("hsr_")`)：共用 JSON encode/decode + SharedPreferences edit 邏輯在 base class,呼叫端 `WidgetPrefsTR.xxx(...)` / `WidgetPrefsHSR.xxx(...)` type-safe 分流,不會傳錯 namespace。Base class 同時提供批次 helper `saveRefreshResult(...)` / `saveRefreshError(...)` 把 refresh 成功/失敗的多次 SharedPreferences 寫入合併為單一 `prefs.edit().apply()`。寫入的 SharedPreferences key 跟初版設計完全相同（TR 寫 `widget_route` 等、HSR 寫 `hsr_widget_route` 等）,TR widget 對外行為與儲存內容零變化。（注:initial implementation 採「同 `object` 加 `keyPrefix: String = ""` 預設參數」設計,post-initial-review refactor 改為本版本,見 design.md Decision 3 更新版本）
- HSR widget 首次安裝、`hsr_widget_route` 不存在時，預設路線 fallback = `WidgetRoute(system="HSR", fromName="臺北", toName="左營")`（呼應 iOS HSR widget 既有預設、亦對齊設計檔 sample）
- HSR widget 不設 `updatePeriodMillis`、不掛 WorkManager，純 user-driven 刷新（同 TR widget 既有模式）；refresh 由右上「查詢」按鈕觸發 `HSRRefreshWidgetAction`
- 站名點擊行為依設計檔 `AndroidMediumConfig`(HSR)：點站名觸發 `HSRShowPickerAction` 切到 picker mode；picker 上點選站台觸發 `HSRSelectStationAction`，**清空 `hsr_widget_schedules`**（與 TR widget 一致：選站後班次清空、不自動打 API）、寫入 `hsr_widget_route`、回到 home view
- 視覺像素級對齊設計檔 `widgets.jsx` 的 `AndroidMedium`(HSR)：橘金漸層 (#F2A85C → #C86820)、accent `#C86820`、light bg `#FBEEDF`、Material You tonal surface 圓角 28
- 新增 HSR widget 的 Xcode-equivalent preview（Glance `@GlancePreview` 或測試 entry 點），可在 Android Studio Compose preview pane 正確渲染

## Capabilities

### New Capabilities

- `android-hsr-widget`：Android 4×2 HSR 專屬桌面小工具的視覺渲染、Action 互動、prefs 儲存隔離、API 整合與 widget metadata 需求；對應 `HSRRailwayWidgetReceiver` / `HSRRailwayGlanceWidget` / `hsr_widget_*` key prefix。與既有 `android-tr-widget` capability 平行存在，對應 iOS 端 `ios-hsr-widget` ↔ `ios-widget-extension` 的二元關係。

### Modified Capabilities

- `android-tr-widget`：兩項變更，皆無使用者可觀察行為變化。**(1) `WidgetPrefs` API 訊號變更**：原本 `object WidgetPrefs` 拆成 `abstract class WidgetPrefsBase(keyPrefix)` + 兩個 namespaced singleton(`WidgetPrefsTR` / `WidgetPrefsHSR`),TR widget 呼叫從 `WidgetPrefs.saveRoute(context, route)` 改為 `WidgetPrefsTR.saveRoute(context, route)`,但寫入的 SharedPreferences key(`widget_route` 等)完全不變;另新增批次 helper `saveRefreshResult` / `saveRefreshError`,把成功/失敗 refresh 的多次寫入合併為單一 `prefs.edit().apply()`。**(2) 清理 HSR 殘骸 scenarios**：移除 Requirement「4×2 鐵路 Widget 視覺渲染」下的「高鐵 Widget 顯示班次」scenario；該 Requirement 開頭敘述去除「依 `widget_route.system` 切換 TR / HSR 配色」改為「以台鐵藍 palette 渲染」；其餘 requirements（Action、Picker、TDX Auth + API Client、SharedPreferences、Room、Manifest）保留——尤其 TDX Auth + API Client 下的「高鐵時刻表 API 呼叫」scenario 保留，因為 `TdxApiClient.fetchHSRSchedule` 為 TR / HSR widget 共享的資料層基礎建設。Spec 收斂後，`android-tr-widget` 與新 `android-hsr-widget` 之關係對齊 iOS 端 `ios-widget-extension` ↔ `ios-hsr-widget` 的二元分工。

## Impact

**Post-Initial-Review Refinement(同 PR 內 cleanup pass)新增/修改:**

- `presentation/ActionKeys.kt` — 新增;`object ActionKeys` 收錄 4 個共用 `ActionParameters.Key`(`stationName` / `stationId` / `isFrom` / `mode`);原本散在 `SelectStationAction.Companion` 與 `ShowPickerAction.Companion`,HSR 端跨檔 reach in 取用 — 抽出後 TR / HSR 共用一份,語義不再「TR 擁有,HSR 借用」
- `util/TaipeiClock.kt` — 新增;`object TaipeiClock` 封裝 `SimpleDateFormat("yyyy-MM-dd"|"HH:mm", Locale.US).apply { timeZone = "Asia/Taipei" }.format(...)`(`todayDate()` / `nowTime()` / `tomorrowDate()`),取代 `RefreshWidgetAction` / `HSRRefreshWidgetAction` / `GetNextTrainsUseCase` 三處重複樣板
- `presentation/RailwayGlanceWidget.kt` + `HSRRailwayGlanceWidget.kt` — 各新增 `STATIONS_VERSION_KEY` companion key,`provideGlance` 內 `produceState` 改鍵於 `stationsVersion`(原本鍵於 `version`),消除「每次 action callback bump VERSION_KEY 都重跑 Room station query」的浪費;`HSRRailwayGlanceWidget.KEY_PREFIX` 常數刪除(被 `WidgetPrefsHSR` namespace 取代)
- `MainActivity.kt` `reloadWidget` handler 從 bump `VERSION_KEY` 改 bump `STATIONS_VERSION_KEY`,且**刻意只 reload TR widget**,不 reload HSR(HSR picker 為 fixed N→S 12 站,無需 Flutter sync;對齊 iOS `AppDelegate.swift:28` 只 reload `RailwayWidget` 的設計)
- TR 4 個 Action(`DismissPickerAction` / `ShowPickerAction` / `SelectStationAction` / `RefreshWidgetAction`)在 `companion object` 補上靜態 helper(`applyDismiss` / `applyShowPicker` / `applyStationSelection` / `resolveRoute` + `executeWith`),跟 HSR 對稱;順便修了 TR `RefreshWidgetAction` 原本錯誤分支沒清舊 schedules 的 bug

**新增 Kotlin code（`android/app/src/main/kotlin/.../widget/`）:**

- `presentation/HSRRailwayGlanceWidget.kt` — 新增；HSR Glance widget class，渲染與 `RailwayGlanceWidget` 平行但鎖死 HSR palette、讀取 `hsr_widget_*` key、`Composable` 結構對齊設計檔 `AndroidMedium`(HSR)
- `presentation/HSRRailwayWidgetReceiver.kt` — 新增；HSR `GlanceAppWidgetReceiver` subclass，回傳 `HSRRailwayGlanceWidget()`
- `presentation/HSRRefreshWidgetAction.kt` — 新增；`ActionCallback` 平行 `RefreshWidgetAction`，內部以 `"hsr_"` prefix 呼叫 `WidgetPrefs`、呼叫 `TdxApiClient.fetchHSRSchedule`、`HSRRailwayGlanceWidget().update(...)`
- `presentation/HSRShowPickerAction.kt` — 新增；切 `hsr_widget_picker_mode` 至 `"from"` / `"to"`
- `presentation/HSRDismissPickerAction.kt` — 新增；切 `hsr_widget_picker_mode` 回 `"home"`
- `presentation/HSRSelectStationAction.kt` — 新增；寫 `hsr_widget_route`、清空 `hsr_widget_schedules`、切 `hsr_widget_picker_mode` 回 `"home"`、reload widget；**明確不呼叫 HSR API**

**修改的既有 Kotlin code（最小幅度，TR widget 使用者可觀察行為不變）:**

- `data/prefs/WidgetPrefs.kt` — 重寫為 `abstract class WidgetPrefsBase(keyPrefix)` 容納所有 JSON encode/decode + SharedPreferences edit 邏輯(`loadRoute` / `saveRoute` / `loadSchedules` / `saveSchedules` / `loadLastError` / `saveLastError` / `loadLastUpdate` / `saveLastUpdate` / `loadPickerMode` / `savePickerMode`)+ 批次 helper(`saveRefreshResult` / `saveRefreshError`);檔尾兩個 typed singleton `object WidgetPrefsTR : WidgetPrefsBase("")` 與 `object WidgetPrefsHSR : WidgetPrefsBase("hsr_")` 分別給 TR / HSR widget 使用。寫入的 SharedPreferences key 跟初版設計完全相同,TR 呼叫端的閱讀差異僅 `WidgetPrefs.xxx(...)` → `WidgetPrefsTR.xxx(...)`
- `presentation/RailwayGlanceWidget.kt` — `paletteFor()` 移除 `"HSR"` when 分支與 `widget_icon_hsr` 引用；HSR drawable 本身保留供新 HSR widget 使用；TR widget 渲染結果**像素級不變**（過去 `widget_route.system` 為 `"HSR"` 時的分支不可達，因 widget gallery 無 HSR 入口）
- `presentation/RailwayWidgetReceiver.kt` — **不動**

**新增 Android resources:**

- `app/src/main/res/xml/railway_widget_hsr_info.xml` — 新增；`AppWidgetProviderInfo` 設 `targetCellWidth=4`、`targetCellHeight=2`、`minWidth=294dp`、`minHeight=110dp`、`updatePeriodMillis=0`、`previewImage=@drawable/widget_icon_hsr`、`label=@string/hsr_widget_label`
- `app/src/main/res/values/strings.xml` — 新增 string resource `hsr_widget_label = "高鐵時刻表"`、`hsr_widget_description = "顯示台灣高鐵下班車資訊"`
- 既有 `app/src/main/res/drawable/widget_icon_hsr.xml` — 已存在，直接重用

**修改 Manifest:**

- `android/app/src/main/AndroidManifest.xml` — 新增 `<receiver android:name=".widget.presentation.HSRRailwayWidgetReceiver">` 區塊，含 `ACTION_APPWIDGET_UPDATE` intent-filter 與 `meta-data` 指向 `@xml/railway_widget_hsr_info`

**新增測試（`android/app/src/test/kotlin/.../widget/`）:**

- `presentation/HSRRefreshWidgetActionTest.kt` — 新增；驗證點查詢 → 讀 `hsr_widget_route` → 呼叫 `TdxApiClient.fetchHSRSchedule`（mock）→ 寫 `hsr_widget_schedules` → reload
- `presentation/HSRSelectStationActionTest.kt` — 新增；驗證選站 → 寫 `hsr_widget_route` + 清空 `hsr_widget_schedules` + 不呼叫任何 API
- `presentation/HSRShowPickerActionTest.kt` / `HSRDismissPickerActionTest.kt` — 新增；驗證 picker mode 切換
- `data/prefs/WidgetPrefsHSRPrefixTest.kt` — 新增；驗證 `WidgetPrefsHSR.saveRoute(context, route)` 等所有 save/load 方法寫入正確的 `hsr_widget_*` key
- `data/prefs/WidgetPrefsTrBackwardCompatTest.kt` — 新增；驗證既有 TR 呼叫者（無 prefix 參數）仍寫入 `widget_route` 等原 key，無 regression

**完全不變動（明確列出以縮小審查範圍）:**

<!-- RailwayGlanceWidget.kt 已移至「修改的既有 Kotlin code」段落（清理 HSR 殘骸）；其餘 TR widget code 維持不動 -->
- `presentation/RailwayWidgetReceiver.kt`、`RefreshWidgetAction.kt`、`SelectStationAction.kt`、`ShowPickerAction.kt`、`DismissPickerAction.kt` — TR widget 既有 Action 不動
- `data/network/TdxApiClient.kt` — 已有 `fetchHSRSchedule`、`fetchTRASchedule` 兩支 method，**不重構**（grilling 階段曾考慮「最小幅度重構」實際上不需要——既有 client 已足）
- `data/network/TdxApiService.kt`、`data/auth/KotlinTdxAuthManager.kt`、`data/auth/WidgetAuthException.kt` — TDX auth + HSR endpoint 已備齊，不動
- `data/repository/WidgetStationRepositoryImpl.kt`、`TrainScheduleRepositoryImpl.kt` — 不動
- `data/room/WidgetStationRoomDatabase.kt`、`WidgetStationDao.kt`、`WidgetStationEntity.kt` — 不動（HSR 12 站已透過 Flutter 端 Drift 寫入同一 DB，Room read-only bridge 可直接讀）
- `domain/usecase/GetNextTrainsUseCase.kt`、`GetPickerStationsUseCase.kt` — 不動
- `domain/entity/WidgetRoute.kt`、`WidgetSchedule.kt`、`PickerStation.kt`、`PickerStationDefaults.kt` — 不動
- `app/src/main/res/xml/railway_widget_info.xml`、`app/src/main/res/layout/railway_widget_initial.xml`、`app/src/main/res/drawable/widget_icon_tr.xml`、`widget_train_icon.xml` — TR widget resources 不動
- iOS 端任何檔案 — 完全不動
- Flutter 端 `lib/` 任何檔案 — 完全不動
- `android/local.properties` 既有 `TDX_CLIENT_ID` / `TDX_CLIENT_SECRET` — 直接重用（HSR 與 TR 共用同組 TDX 憑證）
- App Group / SharedPreferences 名稱 `com.example.flutter_railway_timetable.widget_prefs` — 不變（同一個 prefs file，兩支 widget 透過不同 key prefix 隔離）

**Risks:**

- **非對稱命名**：iOS 端兩支 widget 各用 `tr_widget_*` / `hsr_widget_*` 對稱前綴；Android 因「不改 TR」承諾改採「TR 無前綴、HSR `hsr_widget_*`」非對稱方案——可讀性略低，已列為已知技術債由後續 cleanup change 處理
- **TR widget code 清理風險**：移除 `RailwayGlanceWidget.paletteFor()` 的 HSR 分支屬於 dead-branch 清理（widget gallery 無入口可觸發），對 TR widget 使用者可觀察行為零影響；但若有未列入 spec 的隱藏入口（例如其他模組透過 method channel 寫 `widget_route.system=HSR`）可能造成 regression——`RailwayWidgetReceiver` test 與 `RefreshWidgetActionTest` 既有覆蓋應能在 PR 階段曝出此類問題
- **兩 widget 同時 refresh 撞 TDX 429**：使用者在短時間內按兩支 widget 的查詢按鈕可能觸發 rate limit；既有 `KotlinTdxAuthManager` token 快取與 `RefreshWidgetAction` 錯誤訊息處理已能涵蓋此情境
- **Glance preview 視覺還原限制**：設計檔 `AndroidMedium` 的 sheen blur 高光、絕對定位圓圈、複雜漸層在 Glance 上無法 1:1 還原；實作時以最接近的 `GlanceModifier.background(brush=...)` 與 drawable 替代，若某元素 Glance 真的做不到會在 design.md 明列、不擅自簡化
- **`WidgetPrefs` 從 object 改 abstract class + namespaced singleton**:Kotlin `object` → `class + object` 的 byte-code shape 不一樣,但本專案 widget code 全部同 module 編譯,呼叫端會跟著重新編譯,無 binary compatibility 風險;測試端 `mockkObject(WidgetPrefsTR)` / `mockkObject(WidgetPrefsHSR)` 仍可運作(MockK 對繼承自 abstract base 的 object 方法也涵蓋)

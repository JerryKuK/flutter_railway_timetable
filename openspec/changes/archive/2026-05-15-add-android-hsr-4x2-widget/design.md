## Context

**現況**：Android 端 `RailwayGlanceWidget`（`com.example.flutter_railway_timetable.widget.presentation`）已實作完整 4×2 widget 功能，含 Glance 渲染、Inline picker、4 個 `ActionCallback`（`RefreshWidgetAction` / `ShowPickerAction` / `DismissPickerAction` / `SelectStationAction`）、`WidgetPrefs` SharedPreferences 層、`TdxApiClient` Retrofit client、`KotlinTdxAuthManager`、Room read-only DB bridge。Code 內 `paletteFor(system)` 已預備 HSR 橘金配色與 `widget_icon_hsr` drawable，`TdxApiClient.fetchHSRSchedule` 也已實作；但 widget gallery 沒有 HSR 入口（`AndroidManifest.xml` 只註冊一個 `RailwayWidgetReceiver`）、`widget_route.system` 沒任何 UI 寫入 HSR 值（`RefreshWidgetAction.resolveRoute` hardcode `system = "TR"`，line 63）— 使用者實際無法啟用 HSR widget。

**驅動因素**：iOS 端於 commit `cc6039f` / change `2026-05-13-add-ios-hsr-4x2-widget` 已新增獨立 `HSRWidget`（kind `"HSRWidget"`、displayName「高鐵時刻表」）與 TR widget 並存。Android 需要對等的入口；同時設計檔 `Home Screen Widgets.html` 的 `AndroidMedium`(HSR) 提供視覺基準（橘金漸層、Material You tonal、Inline chip picker）。

**Constraints**：

- 不能改既有 `RailwayWidgetReceiver` 的 component name / class path，否則 launcher 已釘 widget 會消失（Android 透過 `ComponentName` 識別已釘 widget instance）
- 不能新增 SharedPreferences file（兩支 widget 必須共用既有 `com.example.flutter_railway_timetable.widget_prefs`，避免 multi-process 同步問題與安裝時的權限差異）
- 不能改 Flutter ↔ Kotlin method channel `com.jerry.railwaytimetable/app_group` 簽章（避免動到 Flutter 端 `WidgetDataService`）
- 既有 TR widget 使用者可觀察行為**零變化**：相同的 prefs key（`widget_route` 等四個）、相同的視覺、相同的 picker、相同的查詢按鈕行為
- 必須遵守 `openspec/specs/common/spec.md`（clean code、TDD、freezed-style entity 不適用 Kotlin 但 data class equiv、依賴注入 in spirit）與 `openspec/specs/architecture/spec.md`（Clean Architecture 分層：data / domain / presentation）

**Stakeholders / 受影響角色**：

- Android HSR 重度使用者：升級後可在桌面同時擺台鐵與高鐵兩支 widget，各自獨立路線
- 既有 Android TR widget 使用者：升級後 widget 行為與設定完全不變，零操作
- 既有 iOS 雙 widget 使用者：跨平台 parity 達成，桌面排列邏輯可一致

## Goals / Non-Goals

**Goals:**

- Android widget gallery 多一支「高鐵時刻表」widget；可獨立加入桌面與既有「鐵路時刻表」並存
- HSR widget 狀態（route、picker mode、schedules、last error、last update）以 `hsr_widget_*` key prefix 完全與 TR widget 隔離
- HSR widget 視覺對齊設計檔 `widgets.jsx` 的 `AndroidMedium`(HSR)：橘金漸層 (#F2A85C → #C86820)、accent #C86820、light bg #FBEEDF、Material You tonal surface 圓角 28、Inline chip picker
- TR widget 升級後使用者可觀察行為**完全不變**（同 prefs key、同視覺、同 picker、同查詢行為）
- 既有 `android-tr-widget` spec 中的 HSR 殘骸 scenarios 同步清理，spec 與 code 一致
- 所有新增 / 修改的 Kotlin code 有對應 unit test（依 `openspec/specs/common/spec.md` 的 TDD 要求）

**Non-Goals:**

- Android 4×4 / 4×1 / 2×2 等其他尺寸的 HSR widget（設計檔有，本次不做）
- TR widget 視覺微調（即使設計檔有差異也不動）
- iOS 端任何改動（兩端 widget 平行演化）
- Flutter 端 `lib/` 任何改動（widget 設定流程與 method channel 不變）
- 對齊 iOS 的 `tr_widget_*` symmetric prefix 命名（會 BREAKING TR 使用者既有設定，本次明確不做）
- 對齊設計檔的「右上更新時間 chip」位置改動（既有 TR 已有此 chip，保持兩支 widget 樣式一致）
- TDX API rate limiting 重新設計（既有錯誤訊息處理已足）
- Compose / Glance UI snapshot 測試（Glance 測試工具不成熟，per common spec 的「TDD」採用 client / repo / usecase / action 層 unit test 即可）

## Decisions

### Decision 1：新增獨立 `HSRRailwayGlanceWidget` + `HSRRailwayWidgetReceiver`，**不參數化既有 `RailwayGlanceWidget`**

**選擇**：新增 `HSRRailwayGlanceWidget : GlanceAppWidget` 與 `HSRRailwayWidgetReceiver : GlanceAppWidgetReceiver`，各自為獨立 class。`HSRRailwayGlanceWidget.provideGlance` 內部呼叫共用 `@Composable` helper（`WidgetContent` / `PickerContent` / `TrainRow`）但鎖死 HSR palette 與 `hsr_widget_*` key prefix。

**Why over 替代方案**：

- (A) 參數化既有 `RailwayGlanceWidget`：建構子接 `system: String` 與 `keyPrefix: String`，註冊兩個 receiver 各自 `new RailwayGlanceWidget("HSR", "hsr_")` / `new RailwayGlanceWidget("TR", "")`
- **(B) 採用 — 新增獨立 class，共用 `@Composable` private helper**
- (C) 完全複製成兩份 (`RailwayGlanceWidget` + `HSRRailwayGlanceWidget`)，內部完全獨立

**Rationale**：

1. **Glance `GlanceAppWidget` class 必須對應一個 receiver**：Android 透過 `ComponentName(class)` 識別已釘 widget；要兩個 widget gallery 入口就要兩個 receiver class，每個 receiver 必須回傳一個 widget class。class 必須是兩份。
2. **`@Composable` 函式可以共用**：`WidgetContent` / `PickerContent` / `TrainRow` 三個 `@Composable` 是 stateless，只依參數渲染。把它們從 `RailwayGlanceWidget.kt` 提到 `WidgetComposables.kt`（同 package、internal 可見），兩個 widget class 都呼叫——共用 view 層、各自的 widget class 只負責「讀對的 prefs key、呼叫對的 action」。
3. **既有 `RailwayGlanceWidget.provideGlance` 不動**：移共用 helper 出去後 `provideGlance` 仍直接呼叫它們，外觀行為零變化；HSR widget 則新寫一份 `provideGlance`，讀 `hsr_widget_*` key、鎖 HSR palette。
4. **避免改 receiver class path 風險**：若選 (A) 參數化，既有 `RailwayWidgetReceiver` 註冊的 widget class 必須改寫；class path 改動 = 桌面已釘 widget 消失。獨立 class 路線 zero risk。

**Code 位置**：
- 新增 `presentation/HSRRailwayGlanceWidget.kt`
- 新增 `presentation/HSRRailwayWidgetReceiver.kt`
- 重構：把 `RailwayGlanceWidget.kt` 內的 `@Composable` private helper 與 `Palette` data class 提到 `presentation/WidgetComposables.kt`（package-private `internal` 可見），兩個 widget 共用

### Decision 2：複製 4 個 `ActionCallback` 為 HSR 專屬類別，**錯誤映射與 route resolve 抽出共用 helper**

**選擇**：新增 `HSRRefreshWidgetAction` / `HSRShowPickerAction` / `HSRDismissPickerAction` / `HSRSelectStationAction`，邏輯與既有 4 個 action 平行；既有 TR 4 個 action 維持寫入 `widget_*` key、呼叫 `RailwayGlanceWidget().update()`，**code 不動**（除非必要的 prefix 參數 default fallback）。共用片段（route resolve fallback / time formatting / TDX auth init）原規劃抽到 `presentation/WidgetActionHelpers.kt`；實作期改為放在各 HSR Action 自己的 `companion object`（見下方 Action 對照表「實作差異」），跨 Action 共用的 helper 抽出留待後續 cleanup change 處理。

**Why over 替代方案**：

- (A) 給既有 4 個 action 加 `keyPrefix` parameter，依參數決定讀寫哪組 key + 哪個 widget reload
- **(B) 採用 — 完全複製成 HSR 並行類別，但抽出共用 helper**
- (C) 共用 4 個 action class + 用 Glance `actionParametersOf` 傳 `widgetKind` 參數

**Rationale**：

1. **`ActionCallback` 透過 `actionRunCallback<T>()` 以 KClass 註冊**：Glance 內部以 `T::class` 識別 callback，每個 widget 在 `@Composable` 中綁定特定 class（如 `actionRunCallback<RefreshWidgetAction>()`）。要兩個獨立 widget 響應「按下查詢」按鈕，class 必須是兩份。
2. **TR widget code 維持零改動**：選 (A) 會迫使 `RefreshWidgetAction` 等 4 個檔案加 prefix 參數，引入 `RailwayGlanceWidget().update()` vs `HSRRailwayGlanceWidget().update()` 的條件分支——既有 TR widget 邏輯被污染。選 (B) 新增獨立 class，TR 4 個 action 完全不動，使用者可觀察行為零變化。
3. **共用 helper 是純函式**：`resolveRoute(context)` / `timeNow()` / `currentDate()` / `buildAuthManager()` 等都是 stateless 純函式，沒有「widget kind」狀態，理論上可安全抽出而不破壞 action class 的型別獨立性；實作期評估後決定**先放在各 HSR Action 自己的 companion object** 滿足 unit test 需求，跨 Action 抽出 `WidgetActionHelpers.kt` 推遲到後續 cleanup change（TR ↔ HSR 對稱化同 PR 處理）。
4. **與 Decision 1 (view 層) 一致**：能共用的（`@Composable` helper、`ActionHelper` 純函式）共用，不能共用的（`GlanceAppWidget` class、`ActionCallback` class）保持兩份。

**Action class 對照（TR 既有 vs HSR 新增）**：

| TR (既有，code 不動) | HSR (新增) | 共用 helper |
|----|----|----|
| `RefreshWidgetAction` | `HSRRefreshWidgetAction` | `HSRRefreshWidgetAction.Companion.resolveRoute(context)` / `executeWith(context, route, useCase)` |
| `ShowPickerAction` | `HSRShowPickerAction` | `HSRShowPickerAction.Companion.applyShowPicker(context, params)` |
| `DismissPickerAction` | `HSRDismissPickerAction` | `HSRDismissPickerAction.Companion.applyDismiss(context)` |
| `SelectStationAction` | `HSRSelectStationAction` | `HSRSelectStationAction.Companion.applyStationSelection(context, params)` |

**實作差異**：原本 Decision 2 規劃將共用 helper 抽到 `presentation/WidgetActionHelpers.kt` 跨檔共用，實作期改為將純邏輯放在每個 HSR Action class 的 `companion object` 上（`applyDismiss` / `applyShowPicker` / `applyStationSelection` / `executeWith` + `resolveRoute`），讓 unit test 可直接 inject context 跟參數驗證副作用，不需 Glance runtime。TR 端 4 個 Action 未跟進對稱化、helper 抽出留待後續 cleanup change 處理。

每個 HSR Action 內部呼叫 `WidgetPrefsHSR.xxx(context, ...)` 並以 `HSRRailwayGlanceWidget().update(context, glanceId)` reload（`WidgetPrefsHSR` 為 namespaced singleton,見 Decision 3 更新版本）。

### Decision 3：`WidgetPrefs` 拆成 **`abstract class WidgetPrefsBase(keyPrefix)` + 兩個 namespaced singleton**

**選擇**：`WidgetPrefs.kt` 重寫為 `abstract class WidgetPrefsBase(private val keyPrefix: String)` 容納所有 read/write 邏輯（`loadRoute` / `saveRoute` / `loadSchedules` / `saveSchedules` / `loadLastError` / `saveLastError` / `loadLastUpdate` / `saveLastUpdate` / `loadPickerMode` / `savePickerMode` + 批次 helper `saveRefreshResult` / `saveRefreshError`）；檔尾兩個 typed singleton:

```kotlin
abstract class WidgetPrefsBase(private val keyPrefix: String) {
    private fun keyRoute() = "${keyPrefix}widget_route"
    // ... 共用 JSON encode/decode、SharedPreferences edit 邏輯
}

object WidgetPrefsTR : WidgetPrefsBase("")     // 寫入 widget_route 等
object WidgetPrefsHSR : WidgetPrefsBase("hsr_") // 寫入 hsr_widget_route 等
```

呼叫端 `WidgetPrefsTR.saveRoute(context, route)` / `WidgetPrefsHSR.saveRoute(context, route)`，無需 prefix 參數;type-safe 阻擋「忘記傳 prefix」或「傳錯 prefix」的 bug。

**歷史脈絡（implementation 演進）**:本 Decision 初版（在 task 2 落地時）選擇「同 `object WidgetPrefs` 所有方法加 `keyPrefix: String = ""` 預設參數」方案 — 取 default parameter 的 TR backward-compat。Post-initial-review 重構期間發現 default-parameter 設計兩個缺點:(a) HSR 呼叫端每個方法都要重複傳 `HSRRailwayGlanceWidget.KEY_PREFIX`,容易漏傳;(b) 測試端 `verify { WidgetPrefs.saveRoute(any(), any(), "hsr_") }` 用字串 prefix 比對 namespace,缺型別檢查。改成本版 abstract class + namespaced singleton 後兩個問題都消失,且 `mockkObject(WidgetPrefsTR)` / `mockkObject(WidgetPrefsHSR)` 仍可正常運作（MockK 對 Kotlin `object` 的 mocking 是 byte-code level,繼承自 abstract base 的方法也涵蓋）。

**Why over 替代方案**：

- (A) 新增獨立的 `HSRWidgetPrefs` object，與 `WidgetPrefs` 完全平行 → JSON encode/decode 邏輯複製,未來改動易漂移
- (B) 同 `object WidgetPrefs` 加 `keyPrefix: String = ""` 預設參數 → 上述兩缺點（初版實作,已捨棄）
- **(C) 採用 — `abstract class WidgetPrefsBase(keyPrefix)` + 兩個 namespaced singleton**
- (D) `WidgetPrefs` 改為 class，建構時注入 `keyPrefix`,每個 widget 持有自己的 instance → 需要 DI 容器或 caller 自己 hold instance,複雜度過高

**Rationale**：

1. **JSON encode/decode 邏輯不重複**：abstract base 容納共用實作,兩 singleton 只綁 prefix
2. **Type-safe namespace**：caller 寫 `WidgetPrefsHSR.saveRoute(...)` vs `WidgetPrefsTR.saveRoute(...)`,編譯期就分流,不可能傳錯 prefix
3. **單元測試友善**：兩個測試檔案 `WidgetPrefsHSRPrefixTest`（驗證 `hsr_widget_*` key 寫入正確）與 `WidgetPrefsTrBackwardCompatTest`（驗證 `WidgetPrefsTR` 寫入 `widget_*` key 不變）並行覆蓋兩條路徑;`mockkObject` 對兩 singleton 分別 mock,`never writes TR namespace` 類斷言只要 `verify(exactly = 0) { WidgetPrefsTR.saveXxx(any(), any()) }`,讀者一眼懂語義
4. **與 iOS `AppGroupDataSource(system:)` 邏輯對齊**：iOS 端走的是相同抽象（同一個 datasource class,內部以 system 動態組 key）,Android 此決策維持跨平台心智模型一致

### Decision 4：HSR widget 視覺以**既有 TR widget 結構為骨架**、僅替換 palette + station list；設計檔細節無法 1:1 還原時取最接近 Glance modifier

**選擇**：HSR widget 的 `WidgetContent` / `PickerContent` / `TrainRow` 直接重用 TR widget 的 `@Composable` 函式（Decision 1 已抽出），只替換 `palette` 參數。設計檔 `AndroidMedium`(HSR) 與既有 TR widget 視覺對齊度評估：

| 設計檔元素 | 既有 TR widget | HSR widget 處理 |
|---|---|---|
| 橘金漸層 #F2A85C → #C86820 | 不適用（TR 是藍漸層） | 使用 `palette.accent = #C86820`、淺底 `accentSoft = #FBEEDF`、icon `widget_icon_hsr`（既有 drawable） |
| Material You tonal surface 圓角 28 | 既有 widget 用 `Color.White` 平面卡片 | **保持 TR 一致**（白底卡片），不引入 Material You tonal —— 確保兩支 widget 視覺結構對稱（Material You 動態色在不同 launcher 表現不一致，是 risk） |
| MiniTrainGlyph 圓徽 | 既有用 `widget_icon_hsr.xml` drawable | 直接重用既有 drawable |
| Sheen blur / 絕對定位高光圓 | 不適用 | **不實作**（Glance 不支援 `position: absolute` 與 `filter: blur`，per Decision 1 「Glance 視覺還原限制」） |
| 右上「更新 HH:mm」chip + 「查詢」按鈕 | 既有有 | 直接重用結構，配色改 HSR |
| Inline chip picker 6×2 grid | 既有用 5 cols × 2 rows（chunked(5)） | **改為 4 cols × 3 rows**（HSR 12 站）—— 原 grilling 規劃 6 cols × 2 rows 對齊 iOS，但實作驗證發現 Glance `Row` + 6 個 `defaultWeight()` chip 在 4×2 widget 寬度（~258dp 內容區）下，最後一個 chip 會被擠出可視範圍（user 觀察到只顯示 10 chips，缺位置 6 與 12 的 chip）。Glance 對 weight 的 min-width 處理比 SwiftUI 嚴格，改 chunkSize=4（3 rows × 4 cols）讓每個 chip 約 60dp 寬，所有 12 站可靠渲染。代價：vertical 較長，依賴 `resizeMode=vertical` 讓 widget 展高 |

**Why over 替代方案**：

- (A) 嚴格像素級照設計檔還原（引入 Material You、blur 等）
- **(B) 採用 — 結構對齊 TR widget、palette 替換、layout 微調（6 cols 對齊 iOS HSR）**

**Rationale**：

1. **Glance 不支援設計檔的所有 CSS 特性**：`backdrop-filter: blur()`、`position: absolute`、`background: linear-gradient()` 都需要 fallback。強行還原會引入 ImageProvider drawable 或 ColorProvider 條件分支，code 維護成本高且 launcher 渲染不一致。
2. **像素級對稱對使用者重要**：兩支 widget 同時擺桌面時，視覺對稱（同 padding、同字級、同 chip 形狀）能讓使用者感受「這是同一個 app 的雙鐵路 widget」；palette 切換已足以提供視覺辨識。
3. **HSR picker layout 從 6×2 改為 4×3**：原規劃 6 cols × 2 rows 對齊設計檔 `AndroidMediumConfig`(HSR)，但實作驗證發現 Glance `Row` + 6 個 `defaultWeight()` chip 在 4×2 widget 寬度（~258dp 內容區）下，最後一個 chip 會被擠出可視範圍（user 觀察到只顯示 10 chips，缺位置 6 與 12 的 chip）。Glance 對 weight 的 min-width 處理比 SwiftUI 嚴格，改 `chunkSize = 4`（3 rows × 4 cols ≈ 60dp 每 chip）讓所有 12 站可靠渲染。代價：vertical 較長，依賴 `resizeMode=vertical` 讓 widget 展高。TR 既有 10 站 `chunked(5)` 維持原樣；HSR widget 已鎖死 system="HSR"，直接傳 `chunkSize = 4` 給共用 `@Composable`，picker 內部不再需要條件分支。
4. **設計檔元素差異列表透明化**：上表明列「不實作」項目，讓後續驗證者明確知道哪些差異是設計取捨而非實作疏漏。

### Decision 5：HSR widget 預設站使用「**臺北 → 左營**」（傳統「臺」字，對齊 iOS Decision 5）

**選擇**：`HSRRailwayGlanceWidget.provideGlance` 在 `hsr_widget_route` 不存在或 decode 失敗時 fallback 到 `WidgetRoute(system="HSR", fromName="臺北", fromId="1000", toName="左營", toId="1070")`。`WidgetRoute.defaultFor("HSR")` 已可使用（既有 entity 已支援 system 參數）—— 確認既有實作確實回傳「臺北 → 左營」（如果不是，本 change 同步修正）。

**Why over 替代方案**：

- (A) 預設「臺北 → 板橋」（最短跳）
- (B) 預設「臺北 → 高雄」（沿用 TR 預設文字，但 HSR 沒有「高雄」站，需改為「左營」）
- **(C) 採用 — 「臺北 → 左營」**

**Rationale**：對齊 iOS HSR widget Decision 5、對齊設計檔 `widgets.jsx` 的 `W_PAL.HSR.sample`（雖然設計檔寫「台北」，本專案統一用 TDX API 的「臺北」傳統字）、「臺北 → 左營」是 HSR 全線南北直達示意。

### Decision 6：HSR widget 不設 `updatePeriodMillis`、不掛 WorkManager（對齊 TR widget 既有設定）

**選擇**：`railway_widget_hsr_info.xml` 的 `android:updatePeriodMillis` 設為 `0`（與既有 `railway_widget_info.xml` 一致）；不註冊 WorkManager 週期任務；HSR widget 只在三個 trigger 下刷新：(a) widget receiver onUpdate (initial)、(b) `HSRRefreshWidgetAction` 觸發、(c) `HSRSelectStationAction` 觸發。

**Why**：對齊 grilling 階段的「無定時 refresh，純 user-driven」共識；對齊 TR widget 既有設定（android-tr-widget spec line 134）；對齊 iOS HSR widget 行為。省電、省 TDX API quota、避免閃爍。

### Decision 7：HSR picker 永遠顯示**固定 12 站 N→S 順序**（不走 recency 重排）

**選擇**：`HSRRailwayGlanceWidget.provideGlance` 透過 `GetPickerStationsUseCase.execute("HSR")` 從 Room read-only 取得 HSR 站；既有 Drift 端 `_hsrDefaults` 已按南港→左營 N→S 序 seed 進 `widget_stations.db`，且 iOS HSR change 已實作「`UpdateWidgetStationsUseCase` 對 HSR 短路 early-return 不重排」（per ios-hsr-widget spec line 72）。Android 端 `GetPickerStationsUseCase` 直接讀同一個 DB，行為已自動繼承——**本 change 不需新增任何 picker 排序邏輯**。

**Why**：與 iOS Decision 7 完全對齊；HSR 12 站閉合站集 + 地理直覺優先於個人習慣；既有 Flutter 端 `UpdateWidgetStationsUseCase` 已實作此邏輯（per ios-hsr-widget change archive，無需 Android 重做）。

### Decision 8：TR widget code 清理範圍 — **只移除 `paletteFor()` 的 HSR 分支**，不動 widget rendering 主體

**選擇**：`RailwayGlanceWidget.paletteFor()` 函式從 `when (system)` 多分支簡化為直接回傳 TR palette（移除 `"HSR"` 分支與對 `widget_icon_hsr` 的引用）。其餘 `RailwayGlanceWidget.kt` 內容（`WidgetContent` / `PickerContent` / `TrainRow` 等 `@Composable`）**不動**——這些函式接 `palette: Palette` 參數本身不知道 TR/HSR，沒有 dead code 需清理。

但因 Decision 1 已將 `@Composable` private helper 提到共用 `WidgetComposables.kt`，所以實際 `RailwayGlanceWidget.kt` 改動：(1) 移除 helper 函式定義（已搬出去）、(2) `paletteFor` 簡化、(3) `provideGlance` 改為 import 共用 helper。**最終 `RailwayGlanceWidget.kt` 行數會減少**（搬走的 helper 不再在此檔內），但使用者可觀察行為零變化。

**Why**：

1. spec 收斂為 TR-only 必須有對應 code 收斂（避免 spec ≠ code）
2. `paletteFor("HSR")` 是不可達分支（widget gallery 無 HSR 入口、`RefreshWidgetAction.resolveRoute` hardcode TR），移除是 dead-branch cleanup
3. `widget_icon_hsr` drawable 檔案**不刪**（新 HSR widget 會用），只移除 TR widget 對它的引用

### Decision 9：HSR widget 的 schedules 上限與 TR 一致（**最多 3 班次**）

**選擇**：`HSRRefreshWidgetAction` 呼叫 `GetNextTrainsUseCase.execute(fromId, toId, today, "HSR")`，UseCase 既有實作會回傳前 3 班（不足 3 班則隔日 fetch 補滿，per android-tr-widget spec Requirement 4「GetNextTrainsUseCase 過濾並回傳前 3 班」）。

**Why**：直接重用既有 UseCase 邏輯，HSR 與 TR 對「下班次」的數量定義一致；設計檔 `AndroidMedium` 也是顯示 3 列班次。

## Risks / Trade-offs

- **[Glance `@Composable` helper 抽到共用檔案的 import / package-private 風險]** Decision 1 把 `WidgetContent` 等函式從 `RailwayGlanceWidget.kt` 提出來，若標記為 `private` 會無法跨檔案使用、若 `public` 會無謂暴露 → **Mitigation**：使用 Kotlin `internal` 可見性（同 module 可見，外部 module 不可見）；package 維持 `widget.presentation`；compile-time 即可驗證可見性正確

- **[TR widget 既有測試 regression 風險]** Decision 8 重構 `RailwayGlanceWidget.kt` 把 helper 搬出去，理論上不改行為，但若 import 漏改、Composable 簽章不符會 compile 失敗 → **Mitigation**：既有 `TdxApiClientTest` / `GetNextTrainsUseCaseTest` / `GetPickerStationsUseCaseTest` / `TrainScheduleRepositoryImplTest` / `KotlinTdxAuthManagerTest` 五支測試保持綠燈；新增 `RailwayGlanceWidgetSmokeTest`（驗證 `provideGlance` 能載入既有 prefs 不拋例外）作為 cleanup regression guard

- **[`WidgetPrefs` 加 default parameter 不破壞 binary compatibility]** Kotlin default parameter 對 Java caller 不可見、對 Kotlin caller source-compatible；本專案 widget code 全部 Kotlin 同 module → **Mitigation**：no risk，但在 design 中明記，避免後續若引入 Java module 時觸雷

- **[兩 widget 同時 refresh 撞 TDX 429 rate limit]** 使用者短時間連按兩支 widget 查詢按鈕可能觸發 → **Mitigation**：既有 `KotlinTdxAuthManager` token 快取已減少 token endpoint 呼叫；既有 `RefreshWidgetAction` 對 `Exception` 捕獲後寫入 `widget_last_error` 「查詢失敗，請稍後再試」訊息；HSR 版同 mechanism

- **[Glance Compose preview 限制]** `@GlancePreview` 在 Android Studio 預覽窗格的渲染保真度低（特別是 `@Composable` 內部讀 `WidgetPrefs` 的部分）→ **Mitigation**：本 change 不強制要求 preview 達到設計檔像素級保真；以「能載入不崩潰、palette / layout 結構正確」為通過標準

- **[`GetPickerStationsUseCase("HSR")` 依賴 Drift 已寫入 12 站]** 若使用者首次安裝 app 但尚未開啟主程式（Drift 未 seed），HSR widget picker 會 fallback 至 `PickerStationDefaults.stations("HSR")` → **Mitigation**：既有 `PickerStationDefaults` 已涵蓋 HSR 12 站 fallback（per ios-hsr-widget 已修正），Android 直接重用

- **[Spec ↔ code 一致性新規範]** 本 change 確立「清理 spec 必須同步清理 code」的慣例 → **Mitigation**：在 design.md 與 tasks.md 中明列「spec 收斂與 code 收斂是同一個 PR」，未來 cleanup change 應遵循

## Migration Plan

**升級路徑（自動，無需使用者介入）**：

1. App 升級至含本 change 的版本（Android 同一 APK 包含兩支 widget）
2. 既有 `RailwayGlanceWidget` (TR widget)：第一次 timeline refresh 時讀 `widget_route`（既有舊 key、內容不變）→ 顯示原 TR 路線；既有桌面已釘 widget 不消失（receiver class path 不變、`updatePeriodMillis` 設 0 不觸發系統 reload）
3. 桌面新增「+」進入 widget picker，使用者可拉「高鐵時刻表」到桌面 → 預設 `臺北 → 左營` → 點站名/查詢設定
4. `widget_route.system` 在 TR widget 上維持為 `"TR"`（既有設定不變、`SelectStationAction` 不寫 system 欄位），即使因錯誤途徑被設為 `"HSR"`（不可達路徑），新版 `paletteFor()` 會回 TR palette（cleanup 後不會 crash，只是不切色）

**Rollback strategy**：

- 若 production 後發現 critical bug，回滾 = 釋出舊版本 APK
- 新 key (`hsr_widget_*`) 與舊 key (`widget_*`) 物理上獨立，舊版 binary 仍能讀回舊 TR key（HSR widget 在舊版不存在，已釘 widget 會在 launcher 顯示 placeholder）
- TR widget 行為與資料完全不變，舊版回滾後 TR 使用者體驗 zero impact
- HSR widget 使用者回滾後該 widget 在桌面變 placeholder（acceptable for emergency rollback）

## Post-Initial-Review Refinement

下列項目為 initial change 完成後的 cleanup pass(同 PR 內)所引入的設計改動。記錄於此以便後續維護者理解 code 與 initial design.md 既有 Decision 1-9 的差異。

### Decision 10：`STATIONS_VERSION_KEY` 與 `VERSION_KEY` 拆分

**選擇**：兩個 widget 的 `companion object` 各定義兩個 `longPreferencesKey`：

- `VERSION_KEY`（`widget_version` / `hsr_widget_version`）— Action callback 每次執行後 bump,純作為「force Glance recompose」的 change marker
- `STATIONS_VERSION_KEY`（`widget_stations_version` / `hsr_widget_stations_version`）— TR 端由 `MainActivity.reloadWidget` 在 Flutter `WidgetDataService.refreshWidget()` 觸發時 bump;HSR 端永不被任何 caller bump

`provideGlance` 內 `produceState(initialValue, stationsVersion) { GetPickerStationsUseCase.execute(system) }` 只在 `stationsVersion` 變動時 re-launch Room query。

**Why**：

1. Initial 實作 `produceState` 鍵於 `version`,但所有 Action callback（refresh / select / show picker / dismiss picker）都 bump `VERSION_KEY`,造成每次按按鈕都重跑 `GetPickerStationsUseCase.execute()` 的 Room 查詢 — wasted work,因為 stations 只有在 Flutter 端 pin 新站別後才會變
2. 拆 key 後 action callback 仍能透過 bump `VERSION_KEY` 觸發 recompose（Glance 觀測 Preferences 整體,任何 key 變都觸發）,但 stations 的 `produceState` 不再 re-launch
3. HSR 端 picker 為 fixed N→S 12 站別,本就不需要 Flutter sync,因此 `MainActivity.reloadWidget` **刻意只 bump TR 的 `STATIONS_VERSION_KEY`,不碰 HSR**（對齊 iOS `AppDelegate.swift:28` 只 reload `RailwayWidget` 不 reload `HSRWidget` 的設計）。HSR 端 `STATIONS_VERSION_KEY` 在這個語境下退化成「擋 action callback 不要重觸 Room re-query」的純優化 marker,永遠停在 `0L`

### Decision 11：抽出共用 utility — `TaipeiClock` 與 `ActionKeys`

**選擇**：新增兩個共用 module:

- `widget/util/TaipeiClock.kt`(object): `todayDate()` / `nowTime()` / `tomorrowDate()`,封裝 `SimpleDateFormat("yyyy-MM-dd"|"HH:mm", Locale.US).apply { timeZone = "Asia/Taipei" }.format(...)` 的反覆樣板。原本 `RefreshWidgetAction.kt` / `HSRRefreshWidgetAction.kt` / `GetNextTrainsUseCase.kt` 各自重複此邏輯
- `widget/presentation/ActionKeys.kt`(object): 4 個 `ActionParameters.Key`(`stationName` / `stationId` / `isFrom` / `mode`)。原本定義在 `SelectStationAction.Companion` 與 `ShowPickerAction.Companion`,HSR 端透過 `SelectStationAction.stationNameKey` 跨檔 reach in — 看起來像 TR 擁有,實際是兩 widget 共用。抽出後消除「為什麼 HSR 要 import TR 類別?」的閱讀疑問

**Why**：兩個 util 都是純 stateless constant/function,跨 widget 共用,不放共用檔反而誤導讀者以為跟某一 widget 綁定。

### Decision 12：批次 SharedPreferences 寫入 — `saveRefreshResult` / `saveRefreshError`

**選擇**：`WidgetPrefsBase` 提供兩個批次 helper:

```kotlin
fun saveRefreshResult(context, route, schedules, lastUpdate) {
    prefs(context).edit()
        .putString(keyRoute(), routeJson)
        .putString(keySchedules(), schedulesJson)
        .putString(keyLastUpdate(), lastUpdate)
        .remove(keyLastError())
        .apply()  // 單次 disk schedule
}

fun saveRefreshError(context, errorMessage) {
    prefs(context).edit()
        .putString(keySchedules(), "[]")
        .putString(keyLastError(), errorMessage)
        .apply()
}
```

`RefreshWidgetAction` 與 `HSRRefreshWidgetAction` 的成功/失敗 branch 各用一個 helper。

**Why**：Initial 實作 success branch 連續 4 次 `saveX(...)`,每次都觸發 `prefs.edit().apply()` → 4 次獨立的 disk schedule。Batching 後成功 path 1 次、失敗 path 1 次。對 widget refresh hot path（user 按查詢 button 後）有實質節能。

### Decision 13：TR ↔ HSR Action helper 對稱化

**選擇**：4 個 TR `ActionCallback`(`DismissPickerAction` / `ShowPickerAction` / `SelectStationAction` / `RefreshWidgetAction`)在 `companion object` 補上靜態 helper(`applyDismiss` / `applyShowPicker` / `applyStationSelection` / `resolveRoute` + `executeWith`),與 HSR 端對稱。`onAction` body 改成「呼叫 helper → glance ceremony」兩步。

**Why**：

1. Initial Decision 2 「共用 helper 在各 Action companion」的設計只在 HSR 落地,TR 端維持 inline 邏輯導致**asymmetry of testability** — HSR 側因為有 helper 可以 unit test,TR 側不行。對稱化讓 TR 未來補 test 不需要重構 production code
2. 順便發現並修正 TR `RefreshWidgetAction` 的舊 bug:`WidgetAuthException` / generic `Exception` catch branch 原本只寫 `lastError`,**沒清舊 schedules** → widget UI 的「if schedules empty → show lastError」分支不會觸發,使用者看到「舊班次 + 沒錯誤訊息」誤判 refresh 成功。HSR 端在 initial implementation 就修對了,對稱化時把 TR 也補上

## Open Questions

1. **`PickerStationDefaults.stations("HSR")` Kotlin 端是否已實作？** 從 archive 看 iOS HSR change 已修 Flutter 端 defaults 涵蓋 12 站，但 Android 端 Kotlin `PickerStationDefaults.kt` 是獨立 file（per file listing）—— 實作 task 中需確認既有內容，若 HSR 站不足 12 則同 PR 補上。
2. **`WidgetRoute.defaultFor("HSR")` 既有實作是否回傳「臺北 → 左營」？** 從 spec line 22-24 看 `defaultFor("TR")` 回傳「臺北 → 高雄」，HSR 版需確認；不一致時於實作 PR 修正。
3. **Glance picker 是否需要 dynamic chunk size（5 vs 6）？** ✅ Resolved：實作期確認 Glance defaultWeight 在 4×2 widget 寬度下對 6 cols 不穩定，HSR 最終採 `chunkSize = 4`（4 cols × 3 rows）。共用 `@Composable` `PickerContent` 接 `chunkSize: Int` 參數，TR 傳 5、HSR 傳 4，見 Decision 4 的差異列表「Inline chip picker」列。

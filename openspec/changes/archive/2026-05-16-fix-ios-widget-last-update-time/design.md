## Context

iOS 台鐵 / 高鐵 widget 目前用 `TimelineEntry.date` 作為 footer「更新於」的顯示來源。`TimelineEntry.date` 在 WidgetKit 的語意是「此 entry 排程展示時間」——它與「資料抓取時間」是兩個獨立概念，但被 view 層誤用為同一件事。

每次 `WidgetCenter.shared.reloadTimelines(ofKind:)` 觸發（包含 `ShowPickerIntent`、`DismissPickerIntent`、`SelectStationIntent` 三類 picker 操作），iOS 會立即呼叫對應 `TimelineProvider.getTimeline(...)`，而現行實作每次都生成 `entry = RailwayWidgetEntry(date: Date(), ...)`——`Date()` 即「現在」。view 直接顯示 `entry.date`，使用者就看到時間「跳動」，但資料來源（UserDefaults 中的 `tr_widget_schedules` / `hsr_widget_schedules`）並未更新。

Android 端（`WidgetPrefs.kt:19, 89-94`）一開始就把「最後成功 fetch 時間」獨立持久化成 `widget_last_update` SharedPreferences key（String 格式 `"HH:mm"`、台北時區），只有 `RefreshWidgetAction` 成功時才寫入；picker 動作完全不碰此 key。這是已驗證可行的設計。

本 change 的目標：在 iOS 端鏡像 Android 設計，把「entry 排程時間」與「資料新鮮度時間」徹底拆成兩個欄位、兩個生命週期。

## Goals / Non-Goals

**Goals:**

- 將「最後一次成功 API fetch 的時間戳記」獨立持久化在 App Group UserDefaults（`tr_widget_last_update` / `hsr_widget_last_update`，String 格式 `"HH:mm"`，Asia/Taipei 時區）。
- footer 顯示來源從 `entry.date` 切換為新欄位 `entry.lastUpdate: String?`；`nil` 時整段元素不渲染。
- 所有 picker 系列 intents（show / dismiss / select 共 6 個 intent，TR 與 HSR 各 3 個）對 lastUpdate 完全唯讀——觀察不變的事實，不影響時間。
- Refresh intent 採用「成功原子 batch 寫入 / 失敗只動 schedules + lastError」雙路徑，與 Android `saveRefreshResult` / `saveRefreshError` 一一對應。
- TR 與 HSR 兩支 widget 共用同一個 `MediumWidgetView`，footer 行為對兩者一致生效（單點修正，雙向受惠）。

**Non-Goals:**

- 不新增 Android 端任何邏輯——Android 已是參考實作。
- 不改變 widget 整體版面、尺寸、配色、字級、字距、按鈕位置。
- 不改變 `TimelineEntry.date` 的角色——它仍是 WidgetKit 排程語意所需，只是不再被 view 拿來顯示時間。
- 不改變既有 `tr_widget_*` / `hsr_widget_*` 任何 key 的格式與 prefix 隔離規範。
- 不做資料遷移——既有使用者升級後初次顯示「無更新時間」是可接受的、自我修復的狀態。
- 不引入新框架 / 第三方依賴。

## Decisions

### Decision 1：持久化「最後成功 fetch 時間」採 String `"HH:mm"`，不採 `Date` / `TimeInterval`

**選擇**：在 `AppGroupDataSource` 新增 `saveLastUpdate(_ time: String)` / `loadLastUpdate() -> String?`，UserDefaults 內存純字串；未寫入時 `loadLastUpdate()` 直接回 `nil`（沿用 `UserDefaults.string(forKey:)` 原生 sentinel，無需 `?? ""` 包裝）。

**替代方案**：
- (B) 存 `Date`（透過 `set(_:forKey:)` 或 `TimeInterval`）：iOS 端慣用，但需要在每次顯示時用 `DateFormatter` 格式化、處理時區。
- (C) 存 `TimelineEntry.date` 並在 view 端判斷「資料舊不舊」：脆弱，需要額外 hash schedules 對照——不直觀。
- (D) 採 `String` + `""` 空字串作為「尚未查詢過」sentinel（與 Android `WidgetPrefs.loadLastUpdate(): String` 完全字面對稱）：可行，但 iOS 端 `UserDefaults.string(forKey:)` 原生回傳 `String?`，再 `?? ""` 包裝是冗餘；且同 struct 既有 `lastError: String?` 已建立 `nil` 慣例，混用 `""` / `nil` 兩種 sentinel 反而增加心智負擔。

**理由**：
- 與 Android `WidgetPrefs.loadLastUpdate(): String` **行為**對稱（「有值/無值」二態），跨平台易驗證；iOS 端因 Swift 慣用 `Optional` 表達「不存在」、且同 struct 既有 `lastError: String?` 已建立 `nil` sentinel 慣例，採 `String?` + `nil` 比 `String` + `""` 更內聚，view 端可直接 `if let lastUpdate = entry.lastUpdate` 解包。
- 顯示端不需任何格式化邏輯，view 純粹「有值就顯示、無值就藏」——責任最簡。
- 時區邏輯收斂在「寫入時」（`TaipeiClock.nowTime()`），不會在多處重複。

### Decision 2：新增 `TaipeiClock` Swift helper，不直接在 intent 內 inline `DateFormatter`

**選擇**：新增 `ios/RailwayWidget/Data/Util/TaipeiClock.swift`，提供 `static func nowTime() -> String`，內部用 `DateFormatter` + `TimeZone(identifier: "Asia/Taipei")` + `dateFormat = "HH:mm"` + `Locale(identifier: "en_US_POSIX")`（避免 Locale 影響數字 / 時段格式）。

**替代方案**：
- (B) 在 `RefreshTimetableIntent.perform()` 內就地建立 `DateFormatter`：邏輯散落、TR / HSR 兩個 intent 重複、難測試。
- (C) 共用同一個 static `let formatter`：可行但缺乏命名語意，且未來若需要其他格式（日期、秒）容易膨脹。

**理由**：
- 對齊 Android `widget/util/TaipeiClock.kt` 命名與職責——同名跨平台輔助物，閱讀者一看就懂。
- 集中時區與格式定義，未來改規格只動一處。
- 易於單元測試（傳入注入 `Date`，測 String 輸出穩定性）。
- 順帶取代 `GetNextTrainsUseCase.swift` 內既有的 private `DateFormatter.hhmm` extension（用於 `execute` 內過濾「未來班次」的當下時間字串 `nowString`，設定與 `TaipeiClock` 完全等價），改呼叫 `TaipeiClock.nowTime(now)`；Asia/Taipei `HH:mm` 字串生成至此唯一收斂在 `TaipeiClock`（simplify 階段執行）。
- Simplify 階段同步擴充 `TaipeiClock.todayDate(_ date:) -> String`（`"yyyy-MM-dd"` Asia/Taipei），取代 `RefreshTimetableIntent.swift` 與 `HSRRefreshTimetableIntent.swift` 內各自的 `extension DateFormatter { static let yyyyMMdd: ... }`、以及 `GetNextTrainsUseCase.swift` 內 `private extension DateFormatter { static let yyyyMMddTaipei: ... }` 共三處重複定義（三者設定皆等價、皆強制 Asia/Taipei，純 DRY 收斂）；refresh intent 內呼叫 `TaipeiClock.todayDate()` 拿當日字串送 API，`GetNextTrainsUseCase` 內呼叫 `TaipeiClock.todayDate(tomorrow)` 拿跨日 fallback 字串。Asia/Taipei 的 `HH:mm` 與 `yyyy-MM-dd` 兩種字串生成至此皆唯一收斂在 `TaipeiClock`。

### Decision 3：新增 `saveRefreshResult` / `saveRefreshError` 兩個 batch 方法，不維持原有 `saveSchedules` 單獨呼叫

**選擇**：在 `AppGroupDataSource` 新增：
```swift
func saveRefreshResult(route: WidgetRoute, schedules: [TrainSchedule], lastUpdate: String)
func saveRefreshError(_ message: String)
```
原有 `saveSchedules` / `saveLastError` 保留作為低階 API，不被 refresh intent 直接呼叫。

**替代方案**：
- (B) Refresh intent 內依序呼叫 `saveSchedules` → `saveLastUpdate` → `saveLastError(nil)` 三次：每次 `UserDefaults.set` 都會觸發磁碟同步排程，3 次寫入 = 3 次 IO；且若中間崩潰會留下不一致狀態（schedules 已寫但 lastUpdate 未寫）。
- (C) 不分 success / error 兩種 batch，由 caller 判斷：把跨欄位的 invariant（成功時清 lastError、失敗時清 schedules、失敗時不動 lastUpdate）外洩到 caller，重複且容易出錯。

**理由**：
- Android `WidgetPrefsBase.saveRefreshResult` / `saveRefreshError` 已驗證此設計（`WidgetPrefs.kt:105-144`）——直接搬。
- 把「失敗時不能改 lastUpdate」這個 invariant 鎖在 data layer 的方法簽名內，picker / refresh intent 任何 caller 都不可能搞錯。
- iOS UserDefaults 雖然是「同一程序內 atomic」，但 batch 仍有語意收斂的好處——讀程式時「這是一次 refresh 結果」一目瞭然。

### Decision 4：`RailwayWidgetEntry` 新增 `lastUpdate: String?` 欄位，保留原有 `date: Date`

**選擇**：在 entry struct 新增第 7 個欄位 `lastUpdate: String?`。`date: Date` 維持原樣（`TimelineEntry` protocol 必需）。

**替代方案**：
- (B) 改用 `TimelineEntry.date` 同時存「資料時間」並用 `policy: .never` 防止 reload 改變 entry：違反 WidgetKit 語意（`date` 應是排程時間），且 picker 操作仍會主動 reload，無法守住。
- (C) 把 `lastUpdate` 放在 `WidgetRoute` 結構：不該與「路線設定」綁定——它的生命週期跟 schedules 一致。

**理由**：
- 純粹擴充，現有 placeholder（`trPlaceholder` / `hsrPlaceholder`）只需多帶一個 `nil` 欄位即可。
- 與 `lastError: String?` 並列，型別與職責皆對稱：兩者都是「上一次 refresh 的副產物」，都用 `nil` 表達「不存在」。
- 維持 `TimelineEntry` 語意純淨——`date` 仍是 WidgetKit 排程訊號（`policy: .after(now + 1h)` 計算基準）。

### Decision 5：footer 顯示用 `if let lastUpdate = entry.lastUpdate` 整段隱藏，不用 placeholder 字串

**選擇**：`MediumWidgetView` footer 改寫為條件解包：
```swift
HStack {
    if let lastUpdate = entry.lastUpdate {
        Text("更新於 \(lastUpdate)")
            .font(.system(size: 10))
            .foregroundColor(Color(.systemGray3))
    }
    Spacer()
    Text("查看更多 →") ...
}
```

**替代方案**：
- (B) 永遠顯示 `Text("更新於 \(entry.lastUpdate ?? "—")")`：占位符「—」會干擾使用者，且與 Android 不一致。
- (C) 顯示「尚未查詢」字樣：與 widget 中段已有的「點右上角查詢取得班次」訊息重複，視覺冗餘。

**理由**：
- 鏡像 Android `WidgetComposables.kt:114` 的 `if (lastUpdate.isNotEmpty()) { ... }`——跨平台條件**語意**一致（「有值才顯示」），編碼形式因 Swift Optional 與 Kotlin String 慣例差異而選用 `if let` 解包。
- 避免空狀態多一個元件搶版面（widget 4×2 空間極限）。
- 「查看更多 →」靠 `Spacer()` 自動向左擴張即可填補空缺，視覺平衡不破。

### Decision 6：兩個 Refresh intent（TR / HSR）各自走自己的 `AppGroupDataSource(system:)`，不共用實例

**選擇**：維持現有架構，`RefreshTimetableIntent` 用 `AppGroupDataSource(system: .tr)`，`HSRRefreshTimetableIntent` 用 `AppGroupDataSource(system: .hsr)`，兩者各自呼叫各自的 `saveRefreshResult` / `saveRefreshError`。

**替代方案**：
- (B) 抽出一個 generic 「refresh runner」吃 system 參數：理論上可，但 TR / HSR 的 `getNextTrains` 路徑、API endpoint、錯誤訊息文字本來就有差異（既有架構就分開），重構超出本 change scope。

**理由**：
- 最小改動原則——本 change 是「補一個欄位」，不是「重構 refresh pipeline」。
- 未來若要抽共用 runner，本 change 已備好的 batch 方法會是更好的起點。

## Risks / Trade-offs

- **Risk: view 端遺漏一處 `entry.date` 引用** → Mitigation: tasks.md 包含明確的 grep 步驟（`grep -n "entry.date" ios/RailwayWidget/Presentation/View/`），改完後再 grep 一次確認無殘留；既有 `MediumWidgetView` 內 `dateString` computed property 顯示日期 `M/d EEE` 仍可用 `entry.date`（這是「今天日期」不是「資料新鮮度」，語意正確），需保留。

- **Risk: `TaipeiClock.nowTime()` 在裝置時區非台灣時誤差** → Mitigation: 強制使用 `TimeZone(identifier: "Asia/Taipei")`，與 Android 完全一致；單元測試以 `Locale.posix` + 固定 `Date(timeIntervalSince1970:)` 驗證輸出。

- **Risk: 既有使用者升級後 footer 「更新於」消失產生疑慮** → Mitigation: 此狀態自我修復——按一次「查詢」即恢復；且消失的元素不影響 widget 主功能（班次仍正常顯示）。Impact 段落已說明、屬可接受退化。

- **Trade-off: lastUpdate 用 String 而非 `Date` 喪失時區彈性** → 接受。本 widget 僅服務台灣用戶（台鐵 / 高鐵），無跨時區需求；換取與 Android 對稱、無格式化邏輯外洩的好處。

- **Trade-off: 新增的 batch 方法與既有 `saveSchedules` / `saveLastError` 並存，data layer API 表面變大** → 接受。低階 API 仍有測試與 picker intent 之外的使用情境（如未來其他 partial update），保留無害；高階 batch 方法清楚標記「refresh 專用」職責。

- **Risk: `RailwayWidgetEntry` 加欄位導致既有 unit test placeholder 編譯錯誤** → Mitigation: tasks.md 第一步先更新 `RailwayWidgetEntry` + 兩個 placeholder + 所有測試 fixture，避免後續步驟卡編譯。

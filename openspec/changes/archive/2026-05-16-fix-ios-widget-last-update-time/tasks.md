## 1. 基礎設施與 Entry 結構

- [x] 1.1 新增 `ios/RailwayWidget/Data/Util/TaipeiClock.swift`，提供 `static func nowTime(_ date: Date = Date()) -> String`，內部以 `DateFormatter` + `TimeZone(identifier: "Asia/Taipei")` + `dateFormat = "HH:mm"` + `Locale(identifier: "en_US_POSIX")` 產生字串；接受可選 `Date` 參數注入以利測試。**Simplify 階段順手取代**：移除 `ios/RailwayWidget/Domain/UseCase/GetNextTrainsUseCase.swift` 內既有的 private `DateFormatter.hhmm` extension（設定完全等價），改呼叫 `TaipeiClock.nowTime(now)`，Asia/Taipei `HH:mm` 字串生成統一在 TaipeiClock
- [x] 1.2 在 `ios/RailwayWidgetTests/` 新增 `TaipeiClockTests.swift`，以固定 `Date(timeIntervalSince1970:)` 驗證輸出格式與時區行為（含跨日邊界、Locale 中性）
- [x] 1.3 修改 `ios/RailwayWidget/Presentation/Entry/RailwayWidgetEntry.swift`：在 struct 新增 `let lastUpdate: String?` 欄位（與同 struct 既有 `lastError: String?` 採用相同 sentinel 慣例 — `nil` 表示「尚未查詢過」），更新 `trPlaceholder` 與 `hsrPlaceholder` 兩個 static factory 帶入 `lastUpdate: nil`
- [x] 1.4 全 repo 編譯一次（`xcodebuild` 或 Xcode build），確認所有 `RailwayWidgetEntry(...)` 呼叫處（含現有測試 fixture）都因新欄位錯誤後逐一補齊；`RailwayWidgetEntryTests` 內既有 fixture 預設帶 `lastUpdate: nil`
- [x] 1.5 **Simplify 階段擴充**：在 `TaipeiClock` 補上 `static func todayDate(_ date: Date = Date()) -> String`（`"yyyy-MM-dd"` Asia/Taipei，與既有 `nowTime` 共用同一組 timezone/locale 設定，分用兩個 private static `DateFormatter` 各自緩存）；`TaipeiClockTests.swift` 新增 2 條 `todayDate` 測試（同日 + 跨日邊界）。同步移除三處重複的 `DateFormatter` extension（`RefreshTimetableIntent.swift` 與 `HSRRefreshTimetableIntent.swift` 的 `static let yyyyMMdd`、`GetNextTrainsUseCase.swift` 的 `private static let yyyyMMddTaipei`）並改呼叫 `TaipeiClock.todayDate()`。Asia/Taipei 的 `HH:mm` 與 `yyyy-MM-dd` 兩種字串生成至此皆唯一收斂在 `TaipeiClock`

## 2. Data Layer — AppGroupDataSource 擴充（TDD）

- [x] 2.1 在 `ios/RailwayWidgetTests/AppGroupDataSourceTests.swift` 新增測試（先紅）：`tr_saveLoadLastUpdate_roundTrip` 驗證寫入字串後可讀回相同值（TR system 代表）；`loadLastUpdate_defaultNil` 驗證未寫入時回傳 `nil`（TR / HSR 兩個 system 在同一個測試方法內各驗一次）。HSR system 的 round-trip 改由 §2.4 的 isolation 測試完整覆蓋（避免與 TR round-trip 變成只差 system-name 的複製貼上）
- [x] 2.2 在 `AppGroupDataSourceTests.swift` 新增 `testSaveRefreshResult_writesAllFieldsAndClearsError`：先寫入 lastError，再呼叫 `saveRefreshResult(route:schedules:lastUpdate:)`，驗證 route / schedules / lastUpdate 三 key 皆為新值且 lastError 被清除
- [x] 2.3 在 `AppGroupDataSourceTests.swift` 新增 `testSaveRefreshError_preservesLastUpdate`：先呼叫 `saveRefreshResult` 寫入 lastUpdate `"08:00"`，再呼叫 `saveRefreshError("ERR_TEST")`，驗證 lastUpdate 仍為 `"08:00"`、schedules 為空、lastError 為 `"ERR_TEST"`
- [x] 2.4 在 `AppGroupDataSourceTests.swift` 新增 `testTrAndHsrLastUpdate_isolated`：分別對 TR / HSR DataSource 寫入不同 lastUpdate 值，驗證讀回各自為自己的值，不交叉污染
- [x] 2.5 修改 `ios/RailwayWidget/Data/AppGroup/AppGroupDataSource.swift`：新增 `lastUpdateKey` computed property（`"\(system.prefix)_widget_last_update"`）、`saveLastUpdate(_ time: String)`（成功路徑專用，不接受 nil — 進入成功路徑就一定有時間）、`loadLastUpdate() -> String?`（未寫入時直接回 `nil`，沿用 `UserDefaults.string(forKey:)` 的原生 sentinel）、`saveRefreshResult(route:schedules:lastUpdate:)` 與 `saveRefreshError(_:)` 兩個 batch 方法；確認 2.1–2.4 測試由紅轉綠

## 3. Refresh Intent 改用 Batch 寫入

- [x] 3.1 修改 `ios/RailwayWidget/Presentation/Intent/RefreshTimetableIntent.swift`：成功路徑改呼叫 `dataSource.saveRefreshResult(route:schedules: lastUpdate: TaipeiClock.nowTime())`；失敗路徑改呼叫 `dataSource.saveRefreshError(message)`；不再個別呼叫 `saveSchedules` / `saveLastError`
- [x] 3.2 修改 `ios/RailwayWidget/Presentation/Intent/HSRRefreshTimetableIntent.swift`：對 HSR system 套用 3.1 同樣模式
- [x] 3.3 若有既有 refresh intent 測試，補上「成功時 lastUpdate 被寫入」與「失敗時 lastUpdate 不變」兩條斷言；若無相關測試檔案，於 `AppGroupDataSourceTests` 之外新增 minimal integration-style 測試或記錄為手動驗證項目（見 §6）

## 4. TimelineProvider 從持久層讀 lastUpdate

- [x] 4.1 修改 `ios/RailwayWidget/RailwayWidget.swift` 的 `RailwayTimelineProvider.getTimeline`：在現有 `dataSource.loadSchedules()` 等讀取後新增 `let lastUpdate = dataSource.loadLastUpdate()`，並把 `lastUpdate` 傳入 `RailwayWidgetEntry(...)` 建構參數
- [x] 4.2 修改 `ios/RailwayWidget/HSRWidget.swift` 的 `HSRRailwayTimelineProvider.getTimeline`：同 4.1 模式套用至 HSR system
- [x] 4.3 確認 `entry.date = Date()` 維持原樣（這是 `TimelineEntry` 排程語意所需，policy `.after(now + 1h)` 仍以此計算）

## 5. View 顯示來源切換

- [x] 5.1 修改 `ios/RailwayWidget/Presentation/View/MediumWidgetView.swift:147` 附近 footer 區塊：將 `Text("更新於 \(entry.date, formatter: MediumWidgetView.timeFormatter)")` 改為條件解包 `if let lastUpdate = entry.lastUpdate { Text("更新於 \(lastUpdate)") ... }`；保留右側「查看更多 →」與其 `Spacer()` 排版不變
- [x] 5.2 確認 `MediumWidgetView.swift` 內保留 `dateString` computed property 與 header 右側 `Text(dateString)`（這是「今天日期 M/d EEE」，使用 `entry.date` 是正確語意，不應改動）；可考慮移除已不再使用的 `static let timeFormatter`（若 grep 確認無其他引用）
- [x] 5.3 執行 `grep -n "entry.date" "ios/RailwayWidget/Presentation/View/MediumWidgetView.swift"` 確認剩餘的 `entry.date` 引用僅來自 `dateString` computed property 或 timeline 排程相關用途，無任何 footer「更新時間」殘留

## 6. 手動驗證（依 proposal Done means）

- [x] 6.1 用 Xcode 在 iPhone 模擬器或實機 build 並安裝 app；長按桌面拉出「台鐵時刻表」與「高鐵時刻表」兩支 widget
- [x] 6.2 對每支 widget 分別測試：點擊「查詢」按鈕成功後，footer 顯示「更新於 HH:mm」為當下時間（台北時區）
- [x] 6.3 對每支 widget 分別測試：點擊出發站開啟 picker → 切到不同站 → 關閉 picker，footer「更新於」**不變**
- [x] 6.4 對每支 widget 分別測試：模擬網路斷線後點擊「查詢」（或讓 API 失敗），footer「更新於」維持上次成功時間，中段顯示錯誤訊息
- [x] 6.5 在乾淨環境（首次安裝、清除 App Group UserDefaults）拉出 widget，確認 footer **沒有**「更新於」字樣，僅顯示「查看更多 →」
- [x] 6.6 同時操作 TR 與 HSR widget，驗證兩支 widget 的「更新於」時間互相獨立、不交叉影響

## 7. 自動化測試與最終確認

- [x] 7.1 執行 `xcodebuild test -workspace ios/Runner.xcworkspace -scheme RailwayWidget` 或對應 scheme，確認 `AppGroupDataSourceTests`、`TaipeiClockTests`、`RailwayWidgetEntryTests`、`HSRDecodeTests` 所有現有與新增測試全綠
- [x] 7.2 在 repo 根目錄執行 `flutter analyze` 與 `flutter test`，確認 Flutter 端未受影響（本 change 僅動 iOS native 程式碼，但仍以 baseline 確認無誤）
- [x] 7.3 執行 `/opsx:verify` 指令對齊 proposal / design / specs / tasks 一致性，依輸出補正
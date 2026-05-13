## 1. 資料層改造：AppGroupDataSource 注入 system

- [x] 1.1 為 `AppGroupDataSource` 撰寫新單元測試（Swift Testing），驗證 `init(system: .tr)` 寫入時 key 為 `tr_widget_route` / `tr_widget_picker_mode` / `tr_widget_schedules` / `tr_widget_last_error`
- [x] 1.2 為 `AppGroupDataSource` 撰寫新單元測試，驗證 `init(system: .hsr)` 寫入時 key 為 `hsr_widget_*` 系列；同一個 UserDefaults instance 下 `(system: .tr)` 與 `(system: .hsr)` 寫入互不覆蓋
- [x] 1.3 修改 `ios/RailwayWidget/Data/AppGroup/AppGroupDataSource.swift`：加 `init(system: RailwaySystem)`，移除 4 個 static `*Key` 常數，改用 instance computed property
- [x] 1.4 跑 1.1 / 1.2 測試確認 GREEN（5 tests passed in 0.31s on iPhone 17 Pro iOS 26.4）

## 2. TR widget 收斂為 TR-only

- [x] 2.1 修改 `ios/RailwayWidget/RailwayWidget.swift`：`RailwayTimelineProvider` 改為持有 `AppGroupDataSource(system: .tr)`；`GetPickerStationsUseCase.execute(system:)` 改傳固定 `"TR"`；fallback 邏輯為 `dataSource.loadRoute() ?? RailwayWidgetEntry.trPlaceholderRoute`（key 隔離已保證 `tr_widget_route` 內只會是 TR route，毋須額外 system 檢查）
- [x] 2.2 修改 `ios/RailwayWidget/RailwayWidget.swift`：`configurationDisplayName` 改 `"台鐵時刻表"`、`description` 改 `"顯示台鐵下班車資訊"`；`kind` 字串維持 `"RailwayWidget"` 不變
- [x] 2.3 修改 `ios/RailwayWidget/Presentation/Intent/StationPickerIntents.swift`：所有 `AppGroupDataSource()` 改為 `AppGroupDataSource(system: .tr)`；`reloadTimelines(ofKind: "RailwayWidget")` 維持；intent title 加「（台鐵）」識別
- [x] 2.4 修改 `ios/RailwayWidget/Presentation/Intent/RefreshTimetableIntent.swift`：同上，datasource `.tr`；reload kind `"RailwayWidget"`；title/description 加「台鐵」識別
- [x] 2.5 `MediumWidgetView.swift` 初版無需動結構：palette 由 `RailwayPalette.of(entry.route.system)` 推得（後續第 10 節清理時改為同時負責兩 system）
- [x] 2.6 修改 `RailwayWidgetEntry.swift`：拆 `placeholderRoute` 為 `trPlaceholderRoute` (`臺北→高雄`) 與 `hsrPlaceholderRoute` (`臺北→左營`)；entry 工廠改為對稱命名 `trPlaceholder` / `hsrPlaceholder`
- [x] 2.7 `RailwayWidget.swift` 的 `#Preview(as: .systemMedium)` 使用 `RailwayWidgetEntry.trPlaceholder`（TR widget 預覽 invariant）

## 3. HSR Domain 與 Entry 擴展

- [x] 3.1 為 `RailwayWidgetEntry.hsrPlaceholderRoute` 撰寫單元測試（檔案：`RailwayWidgetEntryTests.swift`）：驗證 `fromName == "臺北"`（傳統「臺」字）、`toName == "左營"`、`system == .hsr`；額外加 `trPlaceholderRoute` 與 `hsrPlaceholder` entry 對稱驗證
- [x] 3.2 為 `RailwaySystem` enum 加上 `prefix` computed property（`"tr"` / `"hsr"`），給 `AppGroupDataSource` 動態組 key 使用
- [x] 3.3 跑 3.1 測試確認 GREEN（3 tests passed in 0.006s）

## 4. HSR AppIntent 新增（4 個 intent class）

- [x] 4.1 由 `AppGroupDataSourceTests/hsr_saveSchedules_doesNotTouchTRSchedules` 覆蓋：intent 對 datasource 是 thin wrapper，datasource-level 隔離測試已驗證寫入 hsr key 時 tr key 不變
- [x] 4.2 新增 `ios/RailwayWidget/Presentation/Intent/HSRStationPickerIntents.swift`：類別 `HSRShowPickerIntent` / `HSRDismissPickerIntent` / `HSRSelectStationIntent`，datasource `(system: .hsr)`，`reloadTimelines(ofKind: "HSRWidget")`，HSR 選站 fallback 至 `hsrPlaceholderRoute`
- [x] 4.3 新增 `ios/RailwayWidget/Presentation/Intent/HSRRefreshTimetableIntent.swift`：類別 `HSRRefreshTimetableIntent`；datasource `.hsr`；`useCase.execute(system: .hsr, ...)`；reload kind `"HSRWidget"`；錯誤訊息寫入 `hsr_widget_last_error`
- [x] 4.4 4 個 HSR intent title 都含「（高鐵）」（`選擇車站（高鐵）` / `設定車站（高鐵）` / `關閉選站（高鐵）` / `查詢時刻表（高鐵）`）
- [x] 4.5 跑測試確認 GREEN（5 AppGroupDataSource + 3 RailwayWidgetEntry tests passed）

## 5. HSR View（初版採平行 view，第 10 節清理時合併）

- [x] 5.1 初版新增 `ios/RailwayWidget/Presentation/View/HSRMediumWidgetView.swift` 與 `MediumWidgetView` 平行；intent 引用為 `HSRShowPickerIntent` / `HSRDismissPickerIntent` / `HSRSelectStationIntent` / `HSRRefreshTimetableIntent`；`RailwayPalette` 與 `Color(hex:)` 共用 `MediumWidgetView.swift` 內定義（**Code review 後合併**：見 task 10.4，此檔已刪除，HSR 改用同一個 `MediumWidgetView`）
- [x] 5.2 「點右上角查詢取得班次」提示文字、「無法取得班次，請點查詢重試」錯誤路徑、`pal.name` 顯示「高鐵」等文案與 TR 版本對稱一致
- [x] 5.3 「查看更多 →」、「更新於 HH:mm」、底線可點站名、查詢膠囊按鈕配色皆透過 `pal.accent`（HSR `#C86820`）渲染

## 6. HSR Widget + TimelineProvider + Preview

- [x] 6.1 `RailwayWidgetEntryTests/hsrPlaceholder_isHSRWithNoSchedules` 已驗證 `.hsrPlaceholder` 屬性；`HSRRailwayTimelineProvider.placeholder(in:)` 回傳該 entry verbatim（provider 是 thin wrapper），transitive coverage
- [x] 6.2 新增 `ios/RailwayWidget/HSRWidget.swift`：`HSRRailwayTimelineProvider` 持有 `AppGroupDataSource(system: .hsr)`、`GetPickerStationsUseCase` 傳 `"HSR"`，fallback 為 `dataSource.loadRoute() ?? RailwayWidgetEntry.hsrPlaceholderRoute`（key 隔離已保證讀回的 route 必為 HSR）；`HSRMediumWidget: Widget` (`kind = "HSRWidget"`、`configurationDisplayName("高鐵時刻表")`、`description("顯示台灣高鐵下班車資訊")`、`supportedFamilies([.systemMedium])`)；UI 由 `MediumWidgetView` 提供（與 TR widget 共用，見 task 10.4）
- [x] 6.3 `HSRWidget.swift` 結尾已加 `#Preview(as: .systemMedium) { HSRMediumWidget() } timeline: { RailwayWidgetEntry.hsrPlaceholder }`
- [x] 6.4 跑測試確認 GREEN（9 tests passed in <0.4s）
- [x] 6.5 在 Xcode 中開啟 Canvas 預覽，確認 HSR widget Medium 顯示正常（橘色配色、`臺北 → 左營`、底部「點右上角查詢取得班次」）— **使用者手動驗證**

## 7. WidgetBundle 整合

- [x] 7.1 修改 `ios/RailwayWidget/RailwayWidgetBundle.swift`：`body` 同時回傳 `RailwayWidget()` 與 `HSRMediumWidget()`
- [x] 7.2 `xcodebuild -scheme RailwayWidgetExtension build` 成功；模擬器 widget gallery 驗證留待 group 8

## 8. 端到端驗證

- [x] 8.1 模擬器：拉「台鐵時刻表」到桌面 → 點站名選站 → 查詢 → 確認顯示 TR 班次
- [x] 8.2 模擬器：拉「高鐵時刻表」到桌面 → 點站名選站（驗證僅顯示高鐵站）→ 查詢 → 確認顯示 HSR 班次
- [x] 8.3 模擬器：兩個 widget 同時放桌面，分別修改路線，確認對方 widget 顯示不受影響（`tr_widget_route` 與 `hsr_widget_route` 完全隔離）
- [x] 8.4 ~~iOS 16 fallback 測試~~ **N/A** — `RailwayWidgetExtension` 的 `IPHONEOS_DEPLOYMENT_TARGET` 為 `17.0`，widget 在 iOS 16 裝置無法安裝；順手把 `MediumWidgetView` 與 `HSRMediumWidgetView` 內 `if #available(iOS 17.0, *)` 死碼分支移除（build & 12 tests 仍 GREEN）；spec 同步移除 iOS 16 scenario
- [x] 8.5 升級遷移驗證：手動在 App Group UserDefaults 寫入舊版 `widget_route` 為 HSR 路線，然後升級執行新版 widget extension，確認 TR widget 顯示預設 `臺北 → 高雄`，不 crash
- [x] 8.6 跑 `openspec validate add-ios-hsr-4x2-widget`（如有此 CLI 子命令）或對應驗證指令，確認 spec / change 一致性

## 9. 收尾與交付

- [x] 9.1 執行 `/opsx:verify` 確認 implementation 與 specs 對齊
- [x] 9.2 視 verify 結果以 `/opsx:archive` 歸檔此 change（將 specs delta 合併入 `openspec/specs/ios-widget-extension/spec.md`，並新增 `openspec/specs/ios-hsr-widget/spec.md`）

## 10. Code review 清理（2026-05-13 post-implementation）

審查過 1–8 節落地的程式碼後，由 reviewer 提出並執行下列清理；spec 行為不變（仍對應第 1–8 節之 scenarios），僅實作精簡。

- [x] 10.1 移除未引用的 `RailwaySystem.displayName` 與 `RailwaySystem.accentColor`（視圖層改吃 `RailwayPalette.name` / `pal.accent`，這兩個欄位從未被讀取）
- [x] 10.2 移除 `RailwayPalette.accentSoft` 未使用欄位（建構時設值但無讀取點；軟色背景以 `pal.accent.opacity(...)` 達成）
- [x] 10.3 刪除 Xcode 自動生成的空 `ios/RailwayWidgetTests/RailwayWidgetTests.swift`（僅有 `example()` 占位，覆蓋全由 `AppGroupDataSourceTests` / `HSRDecodeTests` / `RailwayWidgetEntryTests` 提供）
- [x] 10.4 統一 `MediumWidgetView` 同時渲染 TR 與 HSR；刪除 `HSRMediumWidgetView.swift`；新增四個 `@ViewBuilder` private helper（`showPickerButton` / `refreshButton` / `dismissPickerButton` / `selectStationButton`）以 `switch entry.route.system` 分派正確 AppIntent class；新增 `PickerLayout` 私有 struct 提供 grid 尺寸（TR 10/5/5、HSR 12/6/4）
- [x] 10.5 `HSRWidget.swift` 改用 `MediumWidgetView(entry:)`（原為 `HSRMediumWidgetView`）
- [x] 10.6 新增 `ios/RailwayWidget/Data/AppGroup/AppGroupDataSource+Errors.swift`：定義 `recordFetchError(_:)` extension 集中 `TDXAuthError` / `TDXAPIError` / 一般錯誤 → 錯誤碼字串映射
- [x] 10.7 `RefreshTimetableIntent` / `HSRRefreshTimetableIntent` 內三段 catch 收斂為單一 `catch { ds.recordFetchError(error) }`，各減少約 15 行重複
- [x] 10.8 簡化 `RailwayWidget.swift` / `HSRWidget.swift` 內 `loadRoute()` 結果的 system 防禦性檢查為純 `?? placeholderRoute`（key prefix 隔離已保證從 `tr_widget_route` / `hsr_widget_route` 讀回的 route 必為對應 system）
- [x] 10.9 `lib/features/widget_config/domain/usecase/update_widget_stations_use_case.dart` 內 `if (system == 'HSR') return;` 改為 `if (system != 'TR') return;`（表達「只有 TR 走 recency 重排」，避免後續維護者誤判 `maxStations(system)` 之 HSR 分支在此處仍可達）
- [x] 10.10 重新跑既有測試（`AppGroupDataSourceTests` 5 個、`HSRDecodeTests` 3 個、`RailwayWidgetEntryTests` 3 個）— GREEN；swiftc parser pass GREEN
- [x] 10.11 在 Xcode 重新建置 RailwayWidgetExtension target 並於模擬器拉兩個 widget 到桌面驗證 UI 未退化（schedule view + picker grid 切換、TR/HSR 配色、按鈕觸發正確 intent）— **使用者手動驗證**

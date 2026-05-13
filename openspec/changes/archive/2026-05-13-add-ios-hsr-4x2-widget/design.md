## Context

**現況**：iOS RailwayWidget extension 內目前只有一支 `RailwayWidget`（kind `"RailwayWidget"`，supportedFamilies `[.systemMedium]`）。Widget 視圖 `MediumWidgetView` 透過 `entry.route.system`（`.tr` / `.hsr`）取出 `RailwayPalette` 切換配色。所有狀態（route / pickerMode / schedules / lastError）共用 App Group 中四把 generic key：`widget_route` / `widget_picker_mode` / `widget_schedules` / `widget_last_error`。4 個 `AppIntent`（`ShowPickerIntent`、`DismissPickerIntent`、`SelectStationIntent`、`RefreshTimetableIntent`）皆透過 `AppGroupDataSource` 讀寫上述 key。

**驅動因素**：Claude Design 釋出設計檔 `Home Screen Widgets.html`，其中 HSR 與 TR 採視覺平行（同尺寸 / 同結構 / 不同配色）並暗示「兩個系統各自獨立 widget」的擺放邏輯。現有「一支 widget 切系統」造成：

- 桌面只能擺一支：HSR 使用者每次切系統會覆蓋 TR 設定（反之亦然）
- intent 共用 key 與 reloadTimelines kind → 升級時 picker mode 殘留 / TDX token bucket 撞限速無法分流診斷
- spec 端 `ios-widget-extension` 把 TR / HSR scenarios 混在同一 Requirement，未來個別調整 HSR 視覺會牽動 TR 既有 scenario

**Stakeholders / 受影響角色**：

- HSR 重度使用者：升級後可在桌面同時擺台鐵與高鐵兩支 widget
- 舊使用者（widget 設為 HSR）：升級後既有那顆 widget 退化為 TR `臺北 → 高雄`，需手動於 widget gallery 加入「高鐵時刻表」
- iOS 16 使用者：兩支 widget 都仍能顯示時刻，只是無法點站名選站（與既有行為一致）

**Constraints**：

- 不能改 `RailwayWidget` 的 `kind` 字串，否則桌面已釘 widget 會消失
- 不能新增 App Group ID（兩個 widget 必須共用既有 `group.com.jerry.railwaytimetable.widget`，否則 entitlement 與 provisioning profile 都要重打）
- 不能改 Flutter 端的 `WidgetDataService` API（避免 cross-team coordination 與既有 `reloadWidget` method channel 簽章變動）

## Goals / Non-Goals

**Goals:**

- 桌面可同時擺放「台鐵時刻表」（kind `"RailwayWidget"`，藍）與「高鐵時刻表」（kind `"HSRWidget"`，橘）兩支獨立 widget
- 兩支 widget 的狀態完全隔離（路線、picker mode、schedules、last error 走各自 key prefix）
- TR 視覺與功能升級後與升級前一致（只是不能再切 HSR）
- HSR 視覺對齊設計檔（`#F2A85C → #C86820` 漸層、accent `#C86820`、淺底 `#FBEEDF`）
- 舊使用者升級後不 crash、widget 不會從桌面消失
- Xcode `#Preview` 兩支都能跑

**Non-Goals:**

- 新增 iOS Small (2×2) / Large (4×4) 兩個尺寸（設計檔有，本次不做）
- Android Glance widget 對齊設計（4×1 strip / 4×4 large 等）
- TR widget 的視覺微調（自訂 MiniTrainGlyph 等）—— 本次只「鎖系統」不改 TR 樣式
- Flutter 端 UI 改動（widget 設定流程仍照舊）
- TDX API rate limiting 重新設計或 token 共用機制
- 既有舊 key (`widget_route` 等四個) 內容搬遷或保留站名（HSR/TR 站集不同，搬遷無意義）
- iOS 16 以下相容性（`RailwayWidgetExtension.IPHONEOS_DEPLOYMENT_TARGET = 17.0`，widget 在 iOS 16 裝置無法安裝；兩 view 內 `if #available(iOS 17.0, *)` 死碼分支已順手清除）

## Decisions

### Decision 1：兩支 widget 共用 `MediumWidgetView`，透過 `entry.route.system` 在 button helper 內 dispatch AppIntent

**選擇**：單一 `MediumWidgetView.swift` 同時渲染 TR 與 HSR widget；HSR 用同一個 view，差異收斂為四個 `@ViewBuilder` 私有 helper（`showPickerButton` / `refreshButton` / `dismissPickerButton` / `selectStationButton`），於 helper 內 `switch entry.route.system` 選擇正確的 AppIntent class，並用 `PickerLayout.of(entry.route.system)` 提供 grid 尺寸（TR：10 chips × 5 cols × spacing 5；HSR：12 chips × 6 cols × spacing 4）。`RailwayPalette.of(entry.route.system)` 提供配色與系統名（沿用既有設計）。

**Why over 替代方案**：

- (A) **採用** — 共用 `MediumWidgetView` + system-dispatch helper
- (B) 複製成兩個並行 view（原始 Phase 1 決策，code review 階段反轉）

**Rationale**：

1. **AppIntent 型別綁定 widget kind 是唯一不可共用的點**：iOS 對每個 widget kind 必須有靜態型別的 AppIntent class，無法用泛型代換；其餘所有佈局、字串、配色都已被 `RailwayPalette` / `PickerLayout` / `entry.route.system` 完全抽象。把「不可共用」的 4 個 button 集中在 helper、其他 ~250 行 SwiftUI 共用，反而是邊界最清晰的拆分。
2. **複製版的實際維護成本高於預期**：Phase 1 假設「兩支 widget 視覺會各自演化」，但實作後發現 view 結構本身就高度對稱（同一個 4×2 grid、同一個 schedule layout、同一個 picker grid），未來若 HSR 真的演化出獨有元素，再 fork 也來得及。
3. **`@ViewBuilder` 的 if/switch 機制原生支援不同 concrete type 的 Button**：不必走泛型或型別擦除即可在 helper 內 dispatch 不同 intent class。
4. **死碼可見性提升**：所有「兩支 widget 共同邏輯」現在只有一處 source of truth，未來 bug fix 不會漏改一邊。

**Consistency**：與 Decision 2 中「intent class 仍保持兩套」並不衝突 — view 層共用，是因為 view 主體是 declarative SwiftUI，可以用 switch dispatch 解決差異；intent 層保持平行類別，是因為 AppIntent 型別本身就是 widget kind 的識別。

### Decision 2：複製 4 個 AppIntent 為 HSR 專屬類別，**不採用 system 參數**；錯誤映射抽出共用 helper

**選擇**：新增 `HSRShowPickerIntent` / `HSRDismissPickerIntent` / `HSRSelectStationIntent` / `HSRRefreshTimetableIntent`，邏輯與既有 4 個 intent 平行；既有 4 個 intent 改吃 `tr_*` key、reload kind 仍為 `"RailwayWidget"`。Code review 階段把兩個 `*RefreshTimetableIntent` 的錯誤分支映射抽到 `AppGroupDataSource.recordFetchError(_:)` extension，兩個 intent 共用同一份 `TDXAuthError` / `TDXAPIError` / 一般錯誤 → 錯誤碼字串的對應邏輯。

**Why over 替代方案**：

- (A) 給既有 intent 加 `system: String` 參數，依參數決定 datasource
- **(B) 採用 — 完全複製成 HSR 並行類別，但抽出可純函式化的共用片段**

**Rationale**：

1. **AppIntent schema 升級風險低**：iOS 對 intent class 簽章敏感；新增類別 = 零既有 schema 變動；既有 widget 升級後 `tap` 行為連續，無 reload race
2. **AppIntent 型別本身綁定 widget kind**：iOS 需以靜態型別識別 intent，無法在單一類別內用參數承擔兩個 widget kind 的 reload 路由
3. **共用片段以 free function / extension 形式抽出**：`recordFetchError` 是純函式（無 widget kind 狀態），可以安全共用而不破壞 intent class 的型別獨立性
4. **與 view dispatch 策略一致**：view 內以 system switch 共用 layout，intent 以類別保持身份 + helper 共用映射，兩層拆分基準（「能否共用」）一致

**代價**：4 個 intent class 各保留一份，未來 intent 主體邏輯改動需要兩處同步（透過 code review checklist 強制）；但錯誤映射、key 命名等純資料邏輯透過 helper / datasource extension 集中。

### Decision 3：`AppGroupDataSource` 加 `init(system: RailwaySystem)`，**內部以 prefix 動態組 key**

**選擇**：`AppGroupDataSource` 改為 stateful，建構時注入 `system`，內部以 `"\(prefix)_widget_route"` 等動態組 key。每個 timeline provider / intent 都建立屬於該 widget 的 datasource instance。

**Why over 替代方案**：

- (A) 兩個獨立的 datasource 類別（`TRAppGroupDataSource` / `HSRAppGroupDataSource`）
- **(B) 採用 — 同類別、注入 system**

**Rationale**：

1. **Key 命名邏輯一致性**：所有 key 名都是 `"\(prefix)_widget_xxx"`，集中管理避免 typo（特別是 reload kind 與 key prefix 必須保持對應）
2. **不擴大重複**：Decision 1/2 已經複製 view 與 intent，再複製 datasource 會把 80% 一樣的 JSON encode/decode 邏輯也複製一份，性價比過低
3. **單元測試友善**：可以 `AppGroupDataSource(system: .hsr)` 注入測試
4. **未來新尺寸 widget 也能複用**：若 (out-of-scope) 之後做 HSR Small / Large widget，仍走同一個 datasource

### Decision 4：既有舊 key 內容**直接捨棄、不做資料搬遷**

**選擇**：升級時不讀 `widget_route` / `widget_picker_mode` / `widget_schedules` / `widget_last_error` 這 4 個舊 key；TR widget 在新 key `tr_widget_route` 不存在時 fallback 到預設 `臺北 → 高雄`，HSR widget 在 `hsr_widget_route` 不存在時 fallback 到 `臺北 → 左營`。

**Why over 替代方案**：

- (A) 升級時讀舊 key，依 `system` 欄位寫入 `tr_widget_route` 或 `hsr_widget_route`，再刪舊 key
- **(B) 採用 — 直接捨棄**

**Rationale**：

1. **TR / HSR 站集不重疊**：HSR 沒有「花蓮」「臺東」等台鐵站，TR 沒有「左營」「新烏日」等高鐵站，搬遷後對「跨系統使用者」價值極低
2. **遷移程式碼是長尾負擔**：寫一次只用一次的 migration 函式會留在 codebase 中（必須維護到所有舊版本都 EOL）
3. **使用者體感影響有限**：原本是 HSR 的使用者只需在 widget gallery 多按一次「+」加入「高鐵時刻表」即可；原本是 TR 的使用者 zero 操作
4. **API call 一致性**：新 widget 第一次 tap 「查詢」即可拉到最新班次（與既有「點查詢取得班次」flow 一致）

### Decision 5：HSR widget 預設站使用「**臺北 → 左營**」（傳統「臺」字）

**選擇**：`HSRRailwayTimelineProvider` 在 `hsr_widget_route` 不存在或 decode 失敗時 fallback 到 `WidgetRoute(system: .hsr, fromId: "1000", fromName: "臺北", toId: "1070", toName: "左營")`。

**Why**：

- 對齊設計檔 `widgets.jsx` 的 `W_PAL.HSR.sample`（`from: '台北', to: '左營'`），但採與專案統一的「臺北」傳統字（TDX HSR API 的 stationName 也是「臺北」/「左營」）
- 「臺北 → 左營」是 HSR 全線南北直達示意，比「臺北 → 板橋」更具代表性
- 站名與 stationId 對齊 TDX HSR `/v3/Rail/THSR/Station` 端點實際資料

### Decision 6：既有 widget displayName 改字、kind 字串維持原樣

**選擇**：`RailwayWidget` 的 `kind` 字串維持 `"RailwayWidget"` 不動；只改 `configurationDisplayName("台鐵時刻表")` 與 `description("顯示台鐵下班車資訊")`。

**Why**：

- iOS 依 `kind` 字串記錄桌面已釘 widget；改 kind = 桌面那顆 widget 消失 → 嚴重 user-visible regression
- displayName/description 只影響 widget gallery 顯示文字，桌面已釘 widget 重新整理時自動更新文案
- 風險：既有 TR widget 升級後 `kind="RailwayWidget"` 內容變化（HSR 樣式被移除）會讓設定為 HSR 的舊使用者桌面 widget 變成 TR 樣式，但 widget 不會消失（acceptable，已於 proposal 標 BREAKING）

### Decision 7：HSR picker 永遠按南港→左營固定 N→S 順序顯示全 12 站

**選擇**：`UpdateWidgetStationsUseCase.execute` 對 `system == 'HSR'`（在實作中以 `if (system != 'TR') return;` 表達「只有 TR 走 recency 重排」）直接 early-return，不執行 `setFront` 重排。HSR DB row 從 `_hsrDefaults`（已按南港→臺北→...→左營 N→S 序）初次 seed 之後永不變動。iOS 端 `MediumWidgetView` 透過 `PickerLayout.of(.hsr) → chipCount=12, columnCount=6, chipSpacing=4` 顯示全 12 站；TR 對應 `chipCount=10, columnCount=5, chipSpacing=5` 維持原 layout。

**Why over 替代方案**：

- (A) HSR 也走 `setFront`（recency-based，與 TR 一致）
- **(B) 採用 — HSR 不走 setFront，picker 永遠固定 N→S 顯示全 12 站**

**Rationale**：

1. **HSR 是閉合站集（12 站）vs TR 是開放站集（200+ 站）**：TR 用 recency-based 排序是為了讓使用者常用的站擠進 widget 僅 10 個 chip 的有限空間；HSR 12 站全部顯示，沒有「擠掉某站」的問題 → recency 排序失去目的
2. **地理直覺 > 個人習慣**：HSR 使用者心智模型是「南港在最北、左營在最南」，按地理排能瞬間定位目標站；recency 排序會破壞這個心智模型（例如使用者上次查過「彰化→嘉義」後，臺北跑到陣列中段）
3. **領域知識編碼進 codebase**：HSR 站集數年來相對穩定（無短期擴增計畫公告），N→S 地理序具長期可預測性。未來若擴第 13 站才需重新評估這個決策
4. **`setFront` 程式碼仍保留**：`WidgetStationRepositoryImpl.setFront` 與 `UpdateWidgetStationsUseCase.maxStations(system)` 仍然存在，未來如新增需要 recency 排序的開放站集 system（例如「公車」），可直接複用

**代價**：

- HSR 的 `setFront` 程式碼路徑成為 dead branch（從 use case 短路後不會被呼叫到），但保留以便未來其他開放站集 system 複用
- 既有使用者（升級前 DB 內 HSR 已被 setFront 洗亂）需重灌 app 才能取回 N→S 序（與「升級時 HSR 預設 placeholder 重置」的代價同源，acceptable）

## Risks / Trade-offs

- **[TDX rate limit 429 撞限]** 兩支 widget 同時觸發 `Refresh*Intent.perform()` 可能撞 TDX OAuth2 token bucket → **Mitigation**：既有 `TDXAuthManager` actor 已快取 token；既有錯誤訊息提示「請稍後重試」；兩支 widget 各自 timeline policy 為 `.after(now + 1h)` 不會頻繁同步觸發
- **[BREAKING：HSR 設定使用者升級後體驗下降]** 既有 widget 設為 HSR 的使用者升級後桌面那顆會跳成 TR 預設 `臺北 → 高雄` → **Mitigation**：proposal 明確標 BREAKING；無遷移文案彈窗（widget 沒有彈窗機制）；建議在下版本 release note 提示「HSR 使用者請手動加入新的高鐵時刻表 widget」
- **[Intent class 複製造成 4 處邏輯漂移]** TR 修 bug 時容易忘記同步 HSR → **Mitigation**：可純函式化的共用片段已抽到 `AppGroupDataSource.recordFetchError`；剩餘需同步的部分以 code review checklist 加一行「intent 改動是否兩支 widget 同步？」處理
- **[Xcode preview 兩支都要設]** 漏設一個會讓開發者預覽空白 → **Mitigation**：tasks 列表明確列出兩個 `#Preview` 設定 task
- **[App Group 兩 widget race condition]** 兩個 timeline provider 同時讀同一個 UserDefaults 不會 corrupt（atomic write）但理論上有讀到 stale 值的可能 → **Mitigation**：每支 widget 只讀自己 prefix 的 key，物理上不會撞；reload kind 不同（`"RailwayWidget"` vs `"HSRWidget"`）→ WidgetKit 不會交叉觸發

## Migration Plan

**升級路徑（自動，無需使用者介入）**：

1. App 與 Widget Extension 一起升級（同一 IPA）
2. 既有 `RailwayWidget`（kind 不變）：第一次 timeline refresh 時讀 `tr_widget_route`（不存在）→ fallback `臺北 → 高雄`；既有的 `widget_route` 等舊 key 留在 UserDefaults 中（無清理動作，下次系統清空 App Group 時自然消失）
3. 既有桌面 widget 自動 reload，顯示 TR 樣式（即使原本設為 HSR）
4. 使用者若要 HSR widget：開啟桌面「+」→ widget gallery → 拉「高鐵時刻表」到桌面 → 預設 `臺北 → 左營` → 點站名/查詢設定

**Rollback strategy**：

- 若 production 後發現 critical bug，回滾 = 釋出舊版本 IPA
- 新 key (`tr_*` / `hsr_*`) 與舊 key (`widget_*`) 物理上獨立，舊版 binary 仍能讀回舊 key（雖然舊 key 沒被新版寫入過，會 fallback 到 placeholder）
- 即不會 data corruption，但使用者升級期間設過的 route 會丟失（acceptable for emergency rollback）

## Open Questions

無 — Phase 1 grilling 已釐清所有架構決策，並於 Decisions 段一一記錄。實作期若發現新問題，於 tasks.md 中以子任務形式追蹤。

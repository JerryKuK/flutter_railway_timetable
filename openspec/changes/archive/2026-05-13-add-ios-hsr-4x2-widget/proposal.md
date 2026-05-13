## Why

目前 iOS 端只有一支 `RailwayWidget` 4×2 widget（kind = `"RailwayWidget"`），透過 `widget_route.system` 欄位在 TR（台鐵藍）與 HSR（高鐵橘）兩種樣式之間切換。隨著 Claude Design 釋出新的「Home Screen Widgets」設計檔，需要讓 HSR 使用者擁有一支**外觀與資料都與台鐵完全獨立**的高鐵專屬 widget，並消除「同一支 widget 用 system 欄位切換樣式」造成的狀態混淆（例如：升級後 picker mode 殘留、TDX token 共用導致 race condition）。

切換為「一系統一 widget」後，使用者可在桌面同時放台鐵與高鐵兩支獨立 widget，各自有獨立路線、選站、查詢時間，互不干擾。

## What Changes

- 新增 iOS-only 的 HSR 4×2 widget「高鐵時刻表」（kind = `"HSRWidget"`），列入 `RailwayWidgetBundle`，與既有 TR widget 並存
- 新增 HSR 專屬的 4 個 `AppIntent`（`HSRShowPickerIntent` / `HSRDismissPickerIntent` / `HSRSelectStationIntent` / `HSRRefreshTimetableIntent`），結構複製自既有 4 個 intent，彼此不共用 perform 邏輯
- `AppGroupDataSource` 改為 `init(system: RailwaySystem)`，內部以 `"\(prefix)_widget_route"` / `_picker_mode` / `_schedules` / `_last_error` 動態組 key
- TR widget 改用 `tr_widget_*` 系列 key；HSR widget 用 `hsr_widget_*` 系列 key；既有舊 key (`widget_route` 等四個) 內容捨棄、不做資料搬遷
- 既有 `RailwayWidget` **BREAKING**：
  - displayName 改為「台鐵時刻表」、description 改為「顯示台鐵下班車資訊」（kind 不變，已釘 widget 不會消失）
  - 移除 `widget_route.system == HSR` 的支援路徑；timeline provider 強制以 TR 渲染
  - 既有舊使用者若 `widget_route.system == HSR` → 升級後桌面該 widget 自動 fallback 顯示 TR 預設路線 `臺北 → 高雄`
- HSR widget 首次安裝、`hsr_widget_route` 不存在時，預設路線 = `臺北 → 左營`（呼應設計檔 `widgets.jsx` sample）
- 站名點擊 → chips 選站介面（兩支 widget 各自獨立）；不引入 iOS 16 fallback —— `RailwayWidgetExtension.IPHONEOS_DEPLOYMENT_TARGET = 17.0`，iOS 16 裝置無法安裝 widget
- 兩支 widget 各自的 `#Preview` 配置

## Capabilities

### New Capabilities

- `ios-hsr-widget`：iOS 4×2 HSR 專屬桌面小工具的視覺、資料、AppIntent 互動需求；對應 Widget Extension 內 kind `"HSRWidget"` 與 `hsr_widget_*` App Group keys

### Modified Capabilities

- `ios-widget-extension`：移除 HSR scenarios 並改寫為 TR-only；UserDefaults key 由 `widget_route` 等四個 generic 名稱改為 `tr_widget_route` 等系列；移除「`widget_route.system == HSR` 時顯示橘色高鐵樣式」scenario；新增舊使用者升級遷移 scenario（system=HSR 自動 fallback 到 `臺北 → 高雄`）

## Impact

**Affected Swift code（iOS RailwayWidget extension）**：

- `ios/RailwayWidget/Data/AppGroup/AppGroupDataSource.swift` — 加 `init(system:)` 與動態 key（4 個 `*Key` static 常數移除）
- `ios/RailwayWidget/Data/AppGroup/AppGroupDataSource+Errors.swift` — 新增；提供 `recordFetchError(_:)` 共用 `TDXAuthError` / `TDXAPIError` / 一般錯誤 → 錯誤碼字串映射
- `ios/RailwayWidget/Domain/Entity/WidgetRoute.swift` — `RailwaySystem` 新增 `prefix` computed property（移除未使用的 `displayName` / `accentColor`）
- `ios/RailwayWidget/Domain/Entity/PickerStation.swift` — HSR 預設站集擴為全 12 站（北→南順序）
- `ios/RailwayWidget/Presentation/Entry/RailwayWidgetEntry.swift` — 拆出 `trPlaceholderRoute` / `hsrPlaceholderRoute`、`trPlaceholder` / `hsrPlaceholder`（名稱對稱）
- `ios/RailwayWidget/Presentation/View/MediumWidgetView.swift` — 同時渲染 TR 與 HSR；新增四個 `@ViewBuilder` private helper（`showPickerButton` / `refreshButton` / `dismissPickerButton` / `selectStationButton`）以 `entry.route.system` switch 分派正確 AppIntent；新增 `PickerLayout` 私有 struct 提供 grid 尺寸（TR：10/5/5，HSR：12/6/4）；`RailwayPalette` 移除未使用的 `accentSoft`
- `ios/RailwayWidget/RailwayWidget.swift` — TR widget displayName/description 改字；provider 改吃 `tr_*` key；fallback 至 `trPlaceholderRoute`
- `ios/RailwayWidget/HSRWidget.swift` — 新增 HSR widget + provider + `#Preview`；UI 由 `MediumWidgetView` 提供
- `ios/RailwayWidget/RailwayWidgetBundle.swift` — bundle 列出兩個 widget
- `ios/RailwayWidget/Presentation/Intent/StationPickerIntents.swift` — TR intent 改吃 `tr_*` key、title 加「（台鐵）」
- `ios/RailwayWidget/Presentation/Intent/RefreshTimetableIntent.swift` — datasource `.tr`；錯誤分支改呼叫 `ds.recordFetchError(error)`；reloadTimelines kind 仍為 `"RailwayWidget"`
- `ios/RailwayWidget/Presentation/Intent/HSRStationPickerIntents.swift` — 新增 3 個 HSR intent
- `ios/RailwayWidget/Presentation/Intent/HSRRefreshTimetableIntent.swift` — 新增；datasource `.hsr`；同樣使用 `recordFetchError` 共用 helper；reloadTimelines kind = `"HSRWidget"`

**Affected Dart code（lib/）**：

- `lib/features/widget_config/domain/usecase/update_widget_stations_use_case.dart` — `maxStations` 改為 `static int maxStations(String system)`（TR 10、HSR 12）；early-return 改為 `if (system != 'TR') return;` 表達「只有 TR 走 recency 重排」
- `lib/features/widget_config/data/repository/widget_station_repository_impl.dart` — `_hsrDefaults` 擴為全 12 站、`take(...)` 改用 `maxStations(system)`

**Affected test code（ios/RailwayWidgetTests/）**：

- `AppGroupDataSourceTests.swift` — 新增；驗證 TR / HSR key prefix 隔離
- `HSRDecodeTests.swift` — 新增；鎖住 TDX v2 THSR DailyTimetable OD 巢狀 `DailyTrainInfo` 的 decode shape
- `RailwayWidgetEntryTests.swift` — 新增；驗證 `trPlaceholderRoute` / `hsrPlaceholderRoute` / `hsrPlaceholder`

**未受影響**（明確列出以縮小審查範圍）：

- `widget_stations.db`（SQLite picker station list）schema 與內容 — 已依 system 欄位分組，直接重用
- `Color(hex:)` extension / `WidgetRoute` struct 本體 / `GetPickerStationsUseCase` — 完全不動
- Flutter 端 `WidgetDataService` 與 method channel — 沒有變化
- App Group ID `group.com.jerry.railwaytimetable.widget` 與 entitlement — 不變（兩個 widget 同屬一個 extension target）
- TDX API client、TDXAuthManager、credentials 載入路徑 — 不動
- Android Glance widget — 本次 change 不觸碰

**Risks**：

- 兩支 widget 同時觸發 `Refresh*Intent` 可能撞 TDX 429 rate limit（現有錯誤提示已能處理，可接受）
- AppIntent schema 新增類別（不修改既有 intent 簽章）→ 既有 widget 第一次 tap 後 widget 自動 reload，無 user-facing 異常
- 舊使用者把現有 widget 設為 HSR → 升級後桌面那顆顯示 TR 預設站；需自行於 widget gallery 加入「高鐵時刻表」並重新選站
- Widget kind `"RailwayWidget"` 不可改名，否則桌面已釘 widget 會消失 — 本次刻意保留原 kind
- **架構**：依 Clean Architecture 分層（data / domain / presentation）；TR / HSR view 邏輯共用 `MediumWidgetView`，僅 AppIntent class 維持兩套以對應 widget kind
## Context

iOS RailwayWidget（WidgetKit）已完整實作台鐵/高鐵 4×2 Widget，使用 Swift clean architecture（TDXAuthManager / TDXAPIClient / Repository / UseCase）搭配 App Group UserDefaults 共享資料。Android 目前無對應實作。本 change 在 Android 側建立架構對稱的 Glance Widget，對稱 iOS 設計，同時涵蓋台鐵與高鐵。

現有相關程式碼：
- `ios/RailwayWidget/` — iOS widget 完整實作（設計參考）
- `lib/features/widget_config/data/database/widget_station_database.dart` — Drift SQLite，存選站清單；Android widget read-only 透過 Room 讀取
- `android/app/build.gradle.kts` — 目前無 Compose / KSP 設定，Kotlin 1.8.22

## Goals / Non-Goals

**Goals:**
- 4×2 Glance Widget，TR + HSR 同一 widget 由 `widget_route.system` 切換配色與 API，視覺與 iOS `MediumWidgetView` 一致
- 「查詢」button 在 Widget process 直接打 TDX API，不依賴主 App 開啟
- Widget 內嵌站台 picker：點站名直接切換出發/到達站，不需開 App
- Kotlin clean architecture（data / domain / presentation），對稱 iOS 分層

**Non-Goals:**
- 跨 system 切換 UI（要切 TR↔HSR 走主 App）
- App 選站後即時推送至 Widget（透過 MethodChannel `reloadWidget` 半被動觸發即可）

## Decisions

### D1: UI Framework — Glance（非 RemoteViews XML）
- **Decision**: `androidx.glance:glance-appwidget:1.0.0`
- **Why**: Compose-like API 大幅減少 ViewId 管理；iOS 用 SwiftUI，Glance 是最對稱的 Android 對應物；1.0.0 支援 API 21+
- **Alternative**: RemoteViews XML — 拒絕：verbose，難維護，版本適配複雜
- **Trade-off**: `cornerRadius` 在 API 31 以下降級為直角（可接受）；需啟用 `buildFeatures.compose = true` 與 Compose Compiler 1.4.8（Kotlin 1.8.22 相容版本）

### D2: 「查詢」button 觸發機制 — Glance ActionCallback
- **Decision**: `actionRunCallback<RefreshWidgetAction>()`；`RefreshWidgetAction : ActionCallback` 的 suspend `onAction()` 直接 call Kotlin Retrofit → 寫 SharedPreferences → `RailwayGlanceWidget().update()`
- **Why**: `ActionCallback.onAction()` 由 Glance 提供 coroutine scope，可直接 call suspend API；比 BroadcastReceiver 更簡潔，無需額外 Manifest 宣告
- **Alternative**: BroadcastReceiver + Service — 拒絕：需 PendingIntent 管理與生命週期宣告
- **Trade-off**: 不適合 > 20s 作業；TDX API 通常 < 5s，可接受。`KotlinTdxAuthManager` 內以 `Mutex` + `withContext(Dispatchers.IO)` 確保 OkHttp 同步呼叫不阻塞 Main thread 也不會被多次 Action 同時觸發。

### D3: 班次資料儲存 — SharedPreferences（非 Drift/SQLite）
- **Decision**: `widget_route`、`widget_schedules`、`widget_last_error`、`widget_last_update`、`widget_picker_mode` 全存 SharedPreferences JSON
- **Why**: 對稱 iOS UserDefaults 模式；SharedPreferences 在同一 App process 無衝突；無 schema migration 風險；避免與 Flutter Drift 同時 write SQLite 的衝突
- **Alternative**: 在 `WidgetStationDatabase` 加 `widget_schedules` table — 拒絕：Drift 管理 schema migration，Kotlin 直接操作 SQLite 會繞過 migration，升級踩雷風險高

### D4: 站台清單讀取 — Room read-only over Drift-written DB
- **Decision**: 用 Room（`WidgetStationRoomDatabase` + `WidgetStationDao`）以 read-only 方式開啟 Flutter app 由 Drift 寫入的 `widget_stations.db`；明確不啟用 `fallbackToDestructiveMigration`
- **Why**: Room 提供 type-safe DAO 與 cursor mapping；schema mismatch 會爆 exception 而非清空 Flutter 端資料
- **Alternative**: 直接用 `SQLiteDatabase.openDatabase(...)` — 拒絕：缺乏 type safety，DAO mapping 要手寫
- **Trade-off**: 引入 KSP（1.8.22-1.0.11）與 Room 依賴。Compose 已啟用 KSP，邊際成本低。
- **Schema 對齊細節**：Drift 寫的 SQL 是 `sort_order INTEGER NOT NULL DEFAULT 0` 與 inline `UNIQUE("name","system")`，後者由 SQLite 自動產生隱式索引 `sqlite_autoindex_widget_stations_1`。要讓 Room 的 schema validator 通過：
  - `sortOrder` 必須加 `@ColumnInfo(defaultValue = "0")`，否則 Room 期望「無 SQL default」與 PRAGMA 結果衝突
  - entity **不得**宣告 `indices = [Index(...)]`，因為 Room `TableInfo.read` 在 validate 時會過濾 `sqlite_autoindex_*`，宣告 explicit index 反而會期望一個不存在的 named index
- **Bridge**：`MainActivity.getAppGroupDir` MethodChannel 回傳 `<dataDir>/databases/` 給 Drift，確保兩側共用同一 DB file

### D5: TDX 憑證注入 — local.properties → BuildConfig
- **Decision**: Developer 在 `android/local.properties`（root `local.properties`，Flutter 預設 gitignore）加 `TDX_CLIENT_ID=` / `TDX_CLIENT_SECRET=`；`build.gradle.kts` 透過 `rootProject.file("local.properties")` 讀取後以 `buildConfigField` 注入 `BuildConfig`
- **Why**: `local.properties` 已在預設 `.gitignore`；對稱 iOS `Secrets.xcconfig` 模式；`BuildConfig` 在 Kotlin widget runtime 直接可讀
- **Alternative**: Flutter `.env` → `envied` — 拒絕：Dart codegen 產物，Kotlin 無法存取

### D6: Kotlin Clean Architecture 分層（對稱 iOS）

```
widget/
  data/
    auth/        KotlinTdxAuthManager  （token 快取 + Mutex + withContext(IO)，對稱 TDXAuthManager.swift）
    network/     TdxApiService（Retrofit interface，TRA + HSR）、TdxApiClient
    prefs/       WidgetPrefs（SharedPreferences read/write）
    room/        WidgetStationRoomDatabase / Dao / Entity（read-only Drift DB 橋接）
    repository/  TrainScheduleRepositoryImpl、WidgetStationRepositoryImpl
  domain/
    entity/      WidgetSchedule, WidgetRoute（含 defaultFor(system) 工廠）, PickerStation, PickerStationDefaults
    repository/  ITrainScheduleRepository、IWidgetStationRepository（interface）
    usecase/     GetNextTrainsUseCase、GetPickerStationsUseCase
  presentation/
    RailwayGlanceWidget        （Glance UI composable + station picker）
    RailwayWidgetReceiver      （GlanceAppWidgetReceiver）
    RefreshWidgetAction        （查詢按鈕 ActionCallback）
    ShowPickerAction / SelectStationAction / DismissPickerAction（picker 互動）
```

## Risks / Trade-offs

- **[Compose Compiler 版本鎖定]** Kotlin 1.8.22 需 compilerExtensionVersion = "1.4.8"；Flutter 升級 Kotlin 時需同步更新 → build.gradle.kts 內以註解標示，避免 silent break
- **[KSP 版本鎖定]** Room 2.5.x 是 KSP 1.8.22-1.0.11 最後相容版本，bump Kotlin 時要同步處理
- **[ActionCallback timeout]** TDX API 若逾時 → 寫入 `widget_last_error`；Widget 顯示錯誤，不崩潰；不影響主 App ANR
- **[SQLite 跨 process 讀取]** Widget read-only 讀 Drift DB → SQLite WAL mode（已啟用）保護讀取一致性；無 write 競爭
- **[local.properties 缺漏]** Developer 未設定憑證 → `KotlinTdxAuthManager` 偵測空值，拋 `WidgetAuthException("ERR_NO_CREDENTIALS")`，`RefreshWidgetAction` 寫 `widget_last_error`，Widget 顯示錯誤提示，不崩潰

## Migration Plan

1. Developer 在 `android/local.properties` 加入 TDX 憑證兩行
2. `./gradlew assembleDebug` 確認 Compose / KSP 編譯通過
3. `adb install` 後長按桌面 → Widget → 加入「鐵路時刻表」4×2
4. 點擊「查詢」驗證 API 更新並顯示班次；點站名驗證 picker

回滾：移除 `AndroidManifest.xml` 的 `RailwayWidgetReceiver` receiver 宣告即可停用 widget，不影響 Flutter App 本身。

## Open Questions

（無）
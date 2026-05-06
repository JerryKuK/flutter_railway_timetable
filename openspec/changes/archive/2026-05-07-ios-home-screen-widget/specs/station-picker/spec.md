## ADDED Requirements

### Requirement: Widget 選站清單反映最近搜尋（iOS 17+）
Widget 選站 chip grid SHALL 以 SQLite `sort_order` 排序顯示站台，使用者最近在主 App 搜尋過的站台會自動排至清單頂端，提供符合使用習慣的選站順序。

#### Scenario: 最近搜尋站台排在 chip grid 最前
- **WHEN** 使用者在主 App 首頁搜尋「板橋→台中 台鐵」並查詢時刻表
- **THEN** `UpdateWidgetStationsUseCase.setFront()` 將台鐵清單中「板橋」移至第 1 位、「台中」移至第 2 位，其餘站台依原順序後移；下次開啟 Widget 選站 grid，板橋和台中顯示在最前面

#### Scenario: SQLite 不可用時顯示靜態預設清單
- **WHEN** Widget Extension 讀取 SQLite 失敗（`WidgetStationDatabase.make()` 回傳 nil）
- **THEN** 使用 `PickerStationDefaults.stations(for:)` 靜態清單作為後備，台鐵顯示臺北、板橋、桃園等 10 站，高鐵顯示南港、臺北、板橋等 10 站

---

### Requirement: Flutter 與 Swift 預設站台清單保持一致
Flutter `widget_station_repository_impl.dart` 中的 `_trDefaults` / `_hsrDefaults` SHALL 與 Swift `PickerStationDefaults` 中的靜態清單完全對應（站名、stationId、順序），確保 SQLite 初始資料與 Swift fallback 一致。

#### Scenario: 初始化資料與靜態清單一致
- **WHEN** `initDefaultsIfNeeded()` 首次寫入台鐵清單
- **THEN** 寫入的 10 筆站台（名稱、stationId、sort_order）與 Swift `PickerStationDefaults.stations(for: "TR")` 回傳的清單完全相同
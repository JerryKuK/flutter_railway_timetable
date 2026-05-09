package com.example.flutter_railway_timetable.widget.data.room

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey

// Schema must match what the Flutter app writes via Drift
// (see widget_station_database.dart). Two alignment points to keep Room's
// schema validator happy:
//
// 1. `sort_order` carries `DEFAULT 0` in Drift's CREATE TABLE
//    (`integer().withDefault(const Constant(0))`), so we mirror with
//    `@ColumnInfo(defaultValue = "0")`. Without this, Room reads a
//    null defaultValue from PRAGMA and reports a mismatch.
//
// 2. Drift's `uniqueKeys: [{name, system}]` becomes an inline
//    `UNIQUE("name","system")` constraint, which SQLite enforces via
//    an auto-index named `sqlite_autoindex_widget_stations_1`. Room's
//    `TableInfo.read` filters out `sqlite_autoindex_*` entries during
//    validation, so we MUST NOT declare an explicit `indices = [...]`
//    here — doing so would expect a different index that doesn't exist.
@Entity(tableName = "widget_stations")
data class WidgetStationEntity(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val name: String,
    @ColumnInfo(name = "station_id") val stationId: String,
    val system: String,
    @ColumnInfo(name = "sort_order", defaultValue = "0") val sortOrder: Int = 0,
)

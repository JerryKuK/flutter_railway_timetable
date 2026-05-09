package com.example.flutter_railway_timetable.widget.data.room

import androidx.room.Dao
import androidx.room.Query

// Read-only DAO. Writes are handled by the Flutter app via Drift; both sides
// land at <dataDir>/databases/widget_stations.db (Room's default location,
// returned to Flutter through MainActivity.getAppGroupDir).
@Dao
interface WidgetStationDao {
    @Query("SELECT * FROM widget_stations WHERE system = :system ORDER BY sort_order ASC")
    suspend fun getAll(system: String): List<WidgetStationEntity>
}

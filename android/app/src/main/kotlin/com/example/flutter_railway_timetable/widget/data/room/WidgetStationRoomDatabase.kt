package com.example.flutter_railway_timetable.widget.data.room

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase

// Read-only Room handle to the SQLite file the Flutter app writes via Drift.
// Same path because activity and Glance receiver share filesDir (same UID).
// fallbackToDestructiveMigration is intentionally NOT enabled — if Room ever
// detects a schema mismatch we want to fail loudly rather than wipe the
// Flutter-side data.
@Database(entities = [WidgetStationEntity::class], version = 1, exportSchema = false)
abstract class WidgetStationRoomDatabase : RoomDatabase() {

    abstract fun widgetStationDao(): WidgetStationDao

    companion object {
        private const val DB_NAME = "widget_stations.db"

        @Volatile private var INSTANCE: WidgetStationRoomDatabase? = null

        fun getInstance(context: Context): WidgetStationRoomDatabase =
            INSTANCE ?: synchronized(this) {
                INSTANCE ?: Room.databaseBuilder(
                    context.applicationContext,
                    WidgetStationRoomDatabase::class.java,
                    DB_NAME
                )
                    .build()
                    .also { INSTANCE = it }
            }
    }
}

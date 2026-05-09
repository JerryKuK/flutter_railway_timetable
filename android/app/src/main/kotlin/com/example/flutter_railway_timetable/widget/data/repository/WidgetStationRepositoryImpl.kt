package com.example.flutter_railway_timetable.widget.data.repository

import android.content.Context
import com.example.flutter_railway_timetable.widget.data.room.WidgetStationRoomDatabase
import com.example.flutter_railway_timetable.widget.domain.entity.PickerStation
import com.example.flutter_railway_timetable.widget.domain.repository.IWidgetStationRepository

class WidgetStationRepositoryImpl(context: Context) : IWidgetStationRepository {

    private val dao = WidgetStationRoomDatabase.getInstance(context).widgetStationDao()

    override suspend fun getStations(system: String): List<PickerStation> =
        dao.getAll(system).map { entity ->
            PickerStation(
                name = entity.name,
                stationId = entity.stationId,
                system = entity.system,
                sortOrder = entity.sortOrder,
            )
        }
}

package com.example.flutter_railway_timetable.widget.domain.repository

import com.example.flutter_railway_timetable.widget.domain.entity.PickerStation

interface IWidgetStationRepository {
    suspend fun getStations(system: String): List<PickerStation>
}

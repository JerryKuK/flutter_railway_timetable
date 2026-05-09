package com.example.flutter_railway_timetable.widget.domain.repository

import com.example.flutter_railway_timetable.widget.domain.entity.WidgetSchedule

interface ITrainScheduleRepository {
    // system: "TR" or "HSR" — picks the corresponding TDX endpoint.
    suspend fun getSchedules(
        fromId: String,
        toId: String,
        date: String,
        system: String,
    ): List<WidgetSchedule>
}

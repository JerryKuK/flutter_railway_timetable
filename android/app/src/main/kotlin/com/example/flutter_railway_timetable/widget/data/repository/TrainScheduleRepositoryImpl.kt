package com.example.flutter_railway_timetable.widget.data.repository

import com.example.flutter_railway_timetable.widget.data.network.TdxApiClient
import com.example.flutter_railway_timetable.widget.domain.entity.WidgetSchedule
import com.example.flutter_railway_timetable.widget.domain.repository.ITrainScheduleRepository

class TrainScheduleRepositoryImpl(
    private val apiClient: TdxApiClient
) : ITrainScheduleRepository {

    override suspend fun getSchedules(
        fromId: String,
        toId: String,
        date: String,
        system: String,
    ): List<WidgetSchedule> = when (system) {
        "HSR" -> apiClient.fetchHSRSchedule(fromId, toId, date)
        else -> apiClient.fetchTRASchedule(fromId, toId, date)
    }
}

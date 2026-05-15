package com.example.flutter_railway_timetable.widget.domain.usecase

import com.example.flutter_railway_timetable.widget.domain.entity.WidgetSchedule
import com.example.flutter_railway_timetable.widget.domain.repository.ITrainScheduleRepository
import com.example.flutter_railway_timetable.widget.util.TaipeiClock
import java.util.Date

class GetNextTrainsUseCase(private val repository: ITrainScheduleRepository) {

    suspend fun execute(
        fromId: String,
        toId: String,
        date: String,
        system: String,
        now: Date = Date(),
    ): List<WidgetSchedule> {
        val nowStr = TaipeiClock.nowTime(now)

        val today = repository.getSchedules(fromId, toId, date, system)
            .filter { it.dep >= nowStr }
            .sortedBy { it.dep }

        if (today.size >= MAX_RESULTS) return today.take(MAX_RESULTS)

        val tomorrowStr = TaipeiClock.tomorrowDate(now)

        val tomorrow = try {
            repository.getSchedules(fromId, toId, tomorrowStr, system).sortedBy { it.dep }
        } catch (_: Exception) {
            emptyList()
        }

        return (today + tomorrow).take(MAX_RESULTS)
    }

    private companion object {
        const val MAX_RESULTS = 3
    }
}

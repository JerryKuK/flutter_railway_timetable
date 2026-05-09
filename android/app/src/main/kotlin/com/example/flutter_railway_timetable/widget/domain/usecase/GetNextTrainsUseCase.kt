package com.example.flutter_railway_timetable.widget.domain.usecase

import com.example.flutter_railway_timetable.widget.domain.entity.WidgetSchedule
import com.example.flutter_railway_timetable.widget.domain.repository.ITrainScheduleRepository
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import java.util.TimeZone

class GetNextTrainsUseCase(private val repository: ITrainScheduleRepository) {

    suspend fun execute(
        fromId: String,
        toId: String,
        date: String,
        system: String,
        now: Date = Date(),
    ): List<WidgetSchedule> {
        val taipeiTz = TimeZone.getTimeZone("Asia/Taipei")
        val nowStr = SimpleDateFormat("HH:mm", Locale.US)
            .apply { timeZone = taipeiTz }
            .format(now)

        val today = repository.getSchedules(fromId, toId, date, system)
            .filter { it.dep >= nowStr }
            .sortedBy { it.dep }

        if (today.size >= MAX_RESULTS) return today.take(MAX_RESULTS)

        val tomorrowDate = Calendar.getInstance(taipeiTz).apply {
            time = now
            add(Calendar.DAY_OF_MONTH, 1)
        }.time
        val tomorrowStr = SimpleDateFormat("yyyy-MM-dd", Locale.US)
            .apply { timeZone = taipeiTz }
            .format(tomorrowDate)

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

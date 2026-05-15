package com.example.flutter_railway_timetable.widget.util

import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import java.util.TimeZone

// All widget code (refresh actions, GetNextTrainsUseCase) formats dates in
// Asia/Taipei; centralising here keeps SimpleDateFormat allocations + timezone
// setup in one place and lets unit tests inject a fixed `now`.
object TaipeiClock {
    val taipeiTz: TimeZone = TimeZone.getTimeZone("Asia/Taipei")

    fun todayDate(now: Date = Date()): String =
        SimpleDateFormat("yyyy-MM-dd", Locale.US).apply { timeZone = taipeiTz }.format(now)

    fun nowTime(now: Date = Date()): String =
        SimpleDateFormat("HH:mm", Locale.US).apply { timeZone = taipeiTz }.format(now)

    fun tomorrowDate(now: Date = Date()): String {
        val cal = Calendar.getInstance(taipeiTz).apply {
            time = now
            add(Calendar.DAY_OF_MONTH, 1)
        }
        return todayDate(cal.time)
    }
}
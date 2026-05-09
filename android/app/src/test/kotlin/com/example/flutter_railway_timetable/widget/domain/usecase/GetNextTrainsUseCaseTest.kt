package com.example.flutter_railway_timetable.widget.domain.usecase

import com.example.flutter_railway_timetable.widget.domain.entity.WidgetSchedule
import com.example.flutter_railway_timetable.widget.domain.repository.ITrainScheduleRepository
import io.mockk.coEvery
import io.mockk.mockk
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Test
import java.text.SimpleDateFormat
import java.util.Locale
import java.util.TimeZone

class GetNextTrainsUseCaseTest {

    private val repository = mockk<ITrainScheduleRepository>()
    private val useCase = GetNextTrainsUseCase(repository)

    private fun atTaipei(yyyyMMddHHmm: String) =
        SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.US)
            .apply { timeZone = TimeZone.getTimeZone("Asia/Taipei") }
            .parse(yyyyMMddHHmm)!!

    @Test
    fun `filters out trains that have already departed`() = runBlocking {
        coEvery { repository.getSchedules(any(), any(), "2026-05-08", any()) } returns listOf(
            WidgetSchedule("08:00", "10:00", "自強", "#100"),
            WidgetSchedule("09:59", "11:59", "區間", "#101"),
            WidgetSchedule("10:00", "12:00", "自強", "#102"),
            WidgetSchedule("11:00", "13:00", "自強", "#103"),
        )

        val result = useCase.execute("1000", "3300", "2026-05-08", "TR", atTaipei("2026-05-08 10:00"))

        assertEquals(2, result.size)
        assertEquals("10:00", result[0].dep)
        assertEquals("11:00", result[1].dep)
    }

    @Test
    fun `caps at 3 results`() = runBlocking {
        coEvery { repository.getSchedules(any(), any(), "2026-05-08", any()) } returns listOf(
            WidgetSchedule("10:00", "12:00", "自強", "#100"),
            WidgetSchedule("10:30", "12:30", "區間", "#101"),
            WidgetSchedule("11:00", "13:00", "自強", "#102"),
            WidgetSchedule("11:30", "13:30", "莒光", "#103"),
        )

        val result = useCase.execute("1000", "3300", "2026-05-08", "TR", atTaipei("2026-05-08 09:00"))

        assertEquals(3, result.size)
    }

    @Test
    fun `sorts by departure time before filtering`() = runBlocking {
        coEvery { repository.getSchedules(any(), any(), "2026-05-08", any()) } returns listOf(
            WidgetSchedule("12:00", "14:00", "自強", "#100"),
            WidgetSchedule("10:00", "12:00", "自強", "#101"),
            WidgetSchedule("11:00", "13:00", "自強", "#102"),
        )

        val result = useCase.execute("1000", "3300", "2026-05-08", "TR", atTaipei("2026-05-08 09:00"))

        assertEquals("10:00", result[0].dep)
        assertEquals("11:00", result[1].dep)
        assertEquals("12:00", result[2].dep)
    }

    @Test
    fun `falls back to tomorrow when today is exhausted`() = runBlocking {
        coEvery { repository.getSchedules(any(), any(), "2026-05-08", any()) } returns listOf(
            WidgetSchedule("06:00", "08:00", "自強", "#100"),
            WidgetSchedule("07:00", "09:00", "自強", "#101"),
        )
        coEvery { repository.getSchedules(any(), any(), "2026-05-09", any()) } returns listOf(
            WidgetSchedule("05:00", "07:00", "自強", "#200"),
            WidgetSchedule("06:00", "08:00", "自強", "#201"),
            WidgetSchedule("07:00", "09:00", "自強", "#202"),
        )

        val result = useCase.execute("1000", "3300", "2026-05-08", "TR", atTaipei("2026-05-08 23:59"))

        assertEquals(3, result.size)
        assertEquals("05:00", result[0].dep)
        assertEquals("06:00", result[1].dep)
        assertEquals("07:00", result[2].dep)
    }

    @Test
    fun `mixes remaining today with tomorrow when today has fewer than 3`() = runBlocking {
        coEvery { repository.getSchedules(any(), any(), "2026-05-08", any()) } returns listOf(
            WidgetSchedule("23:30", "01:00", "自強", "#100"),
        )
        coEvery { repository.getSchedules(any(), any(), "2026-05-09", any()) } returns listOf(
            WidgetSchedule("05:00", "07:00", "自強", "#200"),
            WidgetSchedule("06:00", "08:00", "自強", "#201"),
        )

        val result = useCase.execute("1000", "3300", "2026-05-08", "TR", atTaipei("2026-05-08 22:00"))

        assertEquals(3, result.size)
        assertEquals("23:30", result[0].dep)
        assertEquals("05:00", result[1].dep)
        assertEquals("06:00", result[2].dep)
    }

    @Test
    fun `returns empty when no trains today and tomorrow throws`() = runBlocking {
        coEvery { repository.getSchedules(any(), any(), "2026-05-08", any()) } returns emptyList()
        coEvery { repository.getSchedules(any(), any(), "2026-05-09", any()) } throws RuntimeException("network")

        val result = useCase.execute("1000", "3300", "2026-05-08", "TR", atTaipei("2026-05-08 12:00"))

        assertEquals(0, result.size)
    }
}

package com.example.flutter_railway_timetable.widget.data.repository

import com.example.flutter_railway_timetable.widget.data.network.TdxApiClient
import com.example.flutter_railway_timetable.widget.domain.entity.WidgetSchedule
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.mockk
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Test

class TrainScheduleRepositoryImplTest {

    private val apiClient = mockk<TdxApiClient>()
    private val repository = TrainScheduleRepositoryImpl(apiClient)

    @Test
    fun `TR system delegates to fetchTRASchedule`() = runBlocking {
        val expected = listOf(
            WidgetSchedule("08:00", "10:00", "自強", "#100"),
            WidgetSchedule("09:30", "11:30", "莒光", "#105")
        )
        coEvery { apiClient.fetchTRASchedule("1000", "3300", "2025-01-01") } returns expected

        val result = repository.getSchedules("1000", "3300", "2025-01-01", "TR")

        assertEquals(expected, result)
        coVerify(exactly = 1) { apiClient.fetchTRASchedule("1000", "3300", "2025-01-01") }
        coVerify(exactly = 0) { apiClient.fetchHSRSchedule(any(), any(), any()) }
    }

    @Test
    fun `HSR system delegates to fetchHSRSchedule`() = runBlocking {
        val expected = listOf(WidgetSchedule("10:00", "11:30", "標準", "#1234"))
        coEvery { apiClient.fetchHSRSchedule("1000", "1070", "2025-01-01") } returns expected

        val result = repository.getSchedules("1000", "1070", "2025-01-01", "HSR")

        assertEquals(expected, result)
        coVerify(exactly = 1) { apiClient.fetchHSRSchedule("1000", "1070", "2025-01-01") }
        coVerify(exactly = 0) { apiClient.fetchTRASchedule(any(), any(), any()) }
    }

    @Test
    fun `empty API result returns empty list`() = runBlocking {
        coEvery { apiClient.fetchTRASchedule(any(), any(), any()) } returns emptyList()

        val result = repository.getSchedules("1000", "3300", "2025-01-01", "TR")

        assertEquals(0, result.size)
    }
}

package com.example.flutter_railway_timetable.widget.domain.usecase

import com.example.flutter_railway_timetable.widget.domain.entity.PickerStation
import com.example.flutter_railway_timetable.widget.domain.entity.PickerStationDefaults
import com.example.flutter_railway_timetable.widget.domain.repository.IWidgetStationRepository
import io.mockk.coEvery
import io.mockk.mockk
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class GetPickerStationsUseCaseTest {

    private val repository = mockk<IWidgetStationRepository>()
    private val useCase = GetPickerStationsUseCase(repository)

    @Test
    fun `returns DB stations as-is when DB has 10 or more entries`() = runBlocking {
        val tenStations = (0 until 12).map {
            PickerStation("Station$it", "id$it", "TR", it)
        }
        coEvery { repository.getStations("TR") } returns tenStations

        val result = useCase.execute("TR")

        assertEquals(tenStations, result)
    }

    @Test
    fun `falls back fully to defaults when DB is empty`() = runBlocking {
        coEvery { repository.getStations("TR") } returns emptyList()

        val result = useCase.execute("TR")

        assertEquals(PickerStationDefaults.stations("TR"), result)
    }

    @Test
    fun `tops up to 10 stations when DB has fewer entries, skipping duplicates by name`() = runBlocking {
        val partial = listOf(
            PickerStation("臺北", "1000", "TR", 0),
            PickerStation("板橋", "1020", "TR", 1),
        )
        coEvery { repository.getStations("TR") } returns partial

        val result = useCase.execute("TR")

        assertEquals(10, result.size)
        // DB entries come first
        assertEquals("臺北", result[0].name)
        assertEquals("板橋", result[1].name)
        // Remaining filled from defaults, no duplicate names
        assertEquals(10, result.map { it.name }.toSet().size)
    }

    @Test
    fun `falls back to defaults when repository throws`() = runBlocking {
        coEvery { repository.getStations("HSR") } throws RuntimeException("db unavailable")

        val result = useCase.execute("HSR")

        assertEquals(PickerStationDefaults.stations("HSR"), result)
        assertTrue(result.all { it.system == "HSR" })
    }

    @Test
    fun `system parameter selects correct defaults set`() = runBlocking {
        coEvery { repository.getStations("HSR") } returns emptyList()

        val result = useCase.execute("HSR")

        assertTrue(result.all { it.system == "HSR" })
        // 南港 / 左營 are HSR-specific; should never appear in TR defaults
        assertTrue(result.any { it.name == "南港" })
    }
}
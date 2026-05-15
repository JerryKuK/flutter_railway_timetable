package com.example.flutter_railway_timetable.widget.domain.entity

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class PickerStationDefaultsTest {

    @Test
    fun `HSR contains all 12 stations in north-to-south order`() {
        val stations = PickerStationDefaults.stations("HSR")
        assertEquals(12, stations.size)

        val expectedOrder = listOf(
            "南港" to "0990",
            "臺北" to "1000",
            "板橋" to "1010",
            "桃園" to "1020",
            "新竹" to "1030",
            "苗栗" to "1035",
            "臺中" to "1040",
            "彰化" to "1043",
            "雲林" to "1047",
            "嘉義" to "1050",
            "臺南" to "1060",
            "左營" to "1070",
        )
        expectedOrder.forEachIndexed { index, (name, id) ->
            val station = stations[index]
            assertEquals("station #$index name", name, station.name)
            assertEquals("station #$index id", id, station.stationId)
            assertEquals("HSR", station.system)
            assertEquals(index, station.sortOrder)
        }
    }

    @Test
    fun `HSR stations include 彰化 and 雲林`() {
        val stations = PickerStationDefaults.stations("HSR")
        assertTrue("彰化 missing", stations.any { it.name == "彰化" && it.stationId == "1043" })
        assertTrue("雲林 missing", stations.any { it.name == "雲林" && it.stationId == "1047" })
    }

    @Test
    fun `TR default stations remain unchanged`() {
        val stations = PickerStationDefaults.stations("TR")
        assertEquals(10, stations.size)
        assertEquals("臺北", stations[0].name)
        assertEquals("基隆", stations[9].name)
        assertTrue(stations.all { it.system == "TR" })
    }
}

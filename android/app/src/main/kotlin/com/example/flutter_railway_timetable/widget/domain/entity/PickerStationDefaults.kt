package com.example.flutter_railway_timetable.widget.domain.entity

// Mirror of iOS PickerStationDefaults — IDs must match because both platforms
// share the same Drift-written widget_stations.db schema.
object PickerStationDefaults {

    private val tr = listOf(
        "臺北" to "1000", "板橋" to "1020", "桃園" to "1080", "新竹" to "1210",
        "臺中" to "3300", "臺南" to "4220", "高雄" to "4400", "花蓮" to "7000",
        "臺東" to "6000", "基隆" to "0900",
    )

    private val hsr = listOf(
        "南港" to "0990", "臺北" to "1000", "板橋" to "1010", "桃園" to "1020",
        "新竹" to "1030", "臺中" to "1040", "嘉義" to "1050", "臺南" to "1060",
        "左營" to "1070", "苗栗" to "1035",
    )

    fun stations(system: String): List<PickerStation> {
        val pairs = if (system == "HSR") hsr else tr
        return pairs.mapIndexed { i, (name, id) ->
            PickerStation(name = name, stationId = id, system = system, sortOrder = i)
        }
    }
}

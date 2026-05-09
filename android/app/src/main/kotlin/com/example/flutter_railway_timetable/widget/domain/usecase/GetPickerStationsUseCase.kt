package com.example.flutter_railway_timetable.widget.domain.usecase

import com.example.flutter_railway_timetable.widget.domain.entity.PickerStation
import com.example.flutter_railway_timetable.widget.domain.entity.PickerStationDefaults
import com.example.flutter_railway_timetable.widget.domain.repository.IWidgetStationRepository

// Mirrors iOS GetPickerStationsUseCase: returns up to 10 ordered picker stations,
// falling back to / topping up with PickerStationDefaults when the DB is missing
// rows or unavailable.
class GetPickerStationsUseCase(private val repository: IWidgetStationRepository) {

    suspend fun execute(system: String): List<PickerStation> {
        return try {
            val db = repository.getStations(system)
            when {
                db.isEmpty() -> PickerStationDefaults.stations(system)
                db.size < MAX_STATIONS -> {
                    val existingNames = db.map { it.name }.toSet()
                    val extras = PickerStationDefaults.stations(system)
                        .filter { it.name !in existingNames }
                    (db + extras).take(MAX_STATIONS)
                }
                else -> db
            }
        } catch (_: Exception) {
            PickerStationDefaults.stations(system)
        }
    }

    private companion object {
        const val MAX_STATIONS = 10
    }
}

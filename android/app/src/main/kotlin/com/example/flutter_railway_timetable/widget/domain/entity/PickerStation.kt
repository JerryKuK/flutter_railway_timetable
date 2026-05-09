package com.example.flutter_railway_timetable.widget.domain.entity

// Domain-pure picker station (independent of Room/Drift schema details).
data class PickerStation(
    val name: String,
    val stationId: String,
    val system: String,   // "TR" or "HSR"
    val sortOrder: Int,
)

package com.example.flutter_railway_timetable.widget.presentation

import androidx.glance.action.ActionParameters

// Glance ActionCallback parameter keys shared by TR and HSR actions. Both widget
// systems pass the same payload shape (station selection / picker mode), so the
// keys are factored here instead of being defined on one action class and
// reached into from the other.
object ActionKeys {
    val stationName = ActionParameters.Key<String>("stationName")
    val stationId = ActionParameters.Key<String>("stationId")
    val isFrom = ActionParameters.Key<Boolean>("isFrom")
    val mode = ActionParameters.Key<String>("mode")
}

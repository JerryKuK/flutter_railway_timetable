package com.example.flutter_railway_timetable.widget.presentation

import android.content.Context
import androidx.glance.GlanceId
import androidx.glance.action.ActionParameters
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.state.updateAppWidgetState
import com.example.flutter_railway_timetable.widget.data.prefs.WidgetPrefs
import com.example.flutter_railway_timetable.widget.domain.entity.WidgetRoute

class SelectStationAction : ActionCallback {

    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        val stationName = parameters[stationNameKey] ?: return
        val stationId = parameters[stationIdKey] ?: return
        val isFrom = parameters[isFromKey] ?: true

        val current = WidgetPrefs.loadRoute(context) ?: WidgetRoute.defaultFor("TR")

        val updated = if (isFrom) {
            current.copy(fromName = stationName, fromId = stationId)
        } else {
            current.copy(toName = stationName, toId = stationId)
        }

        WidgetPrefs.saveRoute(context, updated)
        WidgetPrefs.saveSchedules(context, emptyList())
        WidgetPrefs.savePickerMode(context, "home")
        updateAppWidgetState(context, glanceId) { prefs ->
            prefs[RailwayGlanceWidget.VERSION_KEY] = System.currentTimeMillis()
        }
        RailwayGlanceWidget().update(context, glanceId)
    }

    companion object {
        val stationNameKey = ActionParameters.Key<String>("stationName")
        val stationIdKey = ActionParameters.Key<String>("stationId")
        val isFromKey = ActionParameters.Key<Boolean>("isFrom")
    }
}

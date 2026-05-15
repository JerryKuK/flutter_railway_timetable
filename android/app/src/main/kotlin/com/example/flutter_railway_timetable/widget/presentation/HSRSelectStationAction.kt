package com.example.flutter_railway_timetable.widget.presentation

import android.content.Context
import androidx.glance.GlanceId
import androidx.glance.action.ActionParameters
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.state.updateAppWidgetState
import com.example.flutter_railway_timetable.widget.data.prefs.WidgetPrefsHSR
import com.example.flutter_railway_timetable.widget.domain.entity.WidgetRoute

class HSRSelectStationAction : ActionCallback {

    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        applyStationSelection(context, parameters)
        updateAppWidgetState(context, glanceId) { prefs ->
            prefs[HSRRailwayGlanceWidget.VERSION_KEY] = System.currentTimeMillis()
        }
        HSRRailwayGlanceWidget().update(context, glanceId)
    }

    companion object {
        // MUST NOT call TdxApiClient — station selection is a UI-only state
        // change; data refresh is HSRRefreshWidgetAction's job.
        suspend fun applyStationSelection(context: Context, parameters: ActionParameters) {
            val stationName = parameters[ActionKeys.stationName] ?: return
            val stationId = parameters[ActionKeys.stationId] ?: return
            val isFrom = parameters[ActionKeys.isFrom] ?: true

            val current = WidgetPrefsHSR.loadRoute(context)
                ?: WidgetRoute.defaultFor("HSR")

            val updated = if (isFrom) {
                current.copy(fromName = stationName, fromId = stationId)
            } else {
                current.copy(toName = stationName, toId = stationId)
            }

            WidgetPrefsHSR.saveRoute(context, updated)
            WidgetPrefsHSR.saveSchedules(context, emptyList())
            WidgetPrefsHSR.savePickerMode(context, "home")
        }
    }
}

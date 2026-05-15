package com.example.flutter_railway_timetable.widget.presentation

import android.content.Context
import androidx.glance.GlanceId
import androidx.glance.action.ActionParameters
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.state.updateAppWidgetState
import com.example.flutter_railway_timetable.widget.data.prefs.WidgetPrefsHSR

class HSRShowPickerAction : ActionCallback {

    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        applyShowPicker(context, parameters)
        updateAppWidgetState(context, glanceId) { prefs ->
            prefs[HSRRailwayGlanceWidget.VERSION_KEY] = System.currentTimeMillis()
        }
        HSRRailwayGlanceWidget().update(context, glanceId)
    }

    companion object {
        suspend fun applyShowPicker(context: Context, parameters: ActionParameters) {
            val mode = parameters[ActionKeys.mode] ?: "from"
            WidgetPrefsHSR.savePickerMode(context, mode)
        }
    }
}

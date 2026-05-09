package com.example.flutter_railway_timetable.widget.presentation

import android.content.Context
import androidx.glance.GlanceId
import androidx.glance.action.ActionParameters
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.state.updateAppWidgetState
import com.example.flutter_railway_timetable.widget.data.prefs.WidgetPrefs

class ShowPickerAction : ActionCallback {

    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        val mode = parameters[modeKey] ?: "from"
        WidgetPrefs.savePickerMode(context, mode)
        updateAppWidgetState(context, glanceId) { prefs ->
            prefs[RailwayGlanceWidget.VERSION_KEY] = System.currentTimeMillis()
        }
        RailwayGlanceWidget().update(context, glanceId)
    }

    companion object {
        val modeKey = ActionParameters.Key<String>("mode")
    }
}

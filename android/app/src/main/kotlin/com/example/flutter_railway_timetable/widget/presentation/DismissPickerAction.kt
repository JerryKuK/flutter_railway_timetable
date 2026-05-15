package com.example.flutter_railway_timetable.widget.presentation

import android.content.Context
import androidx.glance.GlanceId
import androidx.glance.action.ActionParameters
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.state.updateAppWidgetState
import com.example.flutter_railway_timetable.widget.data.prefs.WidgetPrefsTR

class DismissPickerAction : ActionCallback {

    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        applyDismiss(context)
        updateAppWidgetState(context, glanceId) { prefs ->
            prefs[RailwayGlanceWidget.VERSION_KEY] = System.currentTimeMillis()
        }
        RailwayGlanceWidget().update(context, glanceId)
    }

    companion object {
        suspend fun applyDismiss(context: Context) {
            WidgetPrefsTR.savePickerMode(context, "home")
        }
    }
}

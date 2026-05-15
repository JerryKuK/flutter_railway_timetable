package com.example.flutter_railway_timetable.widget.presentation

import android.content.Context
import androidx.glance.GlanceId
import androidx.glance.action.ActionParameters
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.state.updateAppWidgetState
import com.example.flutter_railway_timetable.widget.data.prefs.WidgetPrefsHSR

class HSRDismissPickerAction : ActionCallback {

    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        applyDismiss(context)
        updateAppWidgetState(context, glanceId) { prefs ->
            prefs[HSRRailwayGlanceWidget.VERSION_KEY] = System.currentTimeMillis()
        }
        HSRRailwayGlanceWidget().update(context, glanceId)
    }

    companion object {
        suspend fun applyDismiss(context: Context) {
            WidgetPrefsHSR.savePickerMode(context, "home")
        }
    }
}

package com.example.flutter_railway_timetable.widget.presentation

import android.content.Context
import androidx.glance.GlanceId
import androidx.glance.action.ActionParameters
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.state.updateAppWidgetState
import com.example.flutter_railway_timetable.BuildConfig
import com.example.flutter_railway_timetable.widget.data.auth.KotlinTdxAuthManager
import com.example.flutter_railway_timetable.widget.data.auth.WidgetAuthException
import com.example.flutter_railway_timetable.widget.data.network.TdxApiClient
import com.example.flutter_railway_timetable.widget.data.prefs.WidgetPrefs
import com.example.flutter_railway_timetable.widget.data.repository.TrainScheduleRepositoryImpl
import com.example.flutter_railway_timetable.widget.data.repository.WidgetStationRepositoryImpl
import com.example.flutter_railway_timetable.widget.domain.entity.WidgetRoute
import com.example.flutter_railway_timetable.widget.domain.usecase.GetNextTrainsUseCase
import com.example.flutter_railway_timetable.widget.domain.usecase.GetPickerStationsUseCase
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

class RefreshWidgetAction : ActionCallback {

    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        val route = resolveRoute(context)

        val authManager = KotlinTdxAuthManager(
            clientId = BuildConfig.TDX_CLIENT_ID,
            clientSecret = BuildConfig.TDX_CLIENT_SECRET
        )
        val useCase = GetNextTrainsUseCase(TrainScheduleRepositoryImpl(TdxApiClient(authManager)))
        val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).apply {
            timeZone = TimeZone.getTimeZone("Asia/Taipei")
        }.format(Date())

        try {
            val schedules = useCase.execute(route.fromId, route.toId, today, route.system)
            WidgetPrefs.saveRoute(context, route)
            WidgetPrefs.saveSchedules(context, schedules)
            WidgetPrefs.saveLastError(context, null)
            WidgetPrefs.saveLastUpdate(context, timeNow())
        } catch (e: WidgetAuthException) {
            WidgetPrefs.saveLastError(context, e.message)
        } catch (_: Exception) {
            WidgetPrefs.saveLastError(context, "查詢失敗，請稍後再試")
        }

        updateAppWidgetState(context, glanceId) { prefs ->
            prefs[RailwayGlanceWidget.VERSION_KEY] = System.currentTimeMillis()
        }
        RailwayGlanceWidget().update(context, glanceId)
    }

    // Saved route wins; otherwise derive from/to from picker stations (first two
    // entries — same fallback iOS uses), falling back to platform defaults.
    private suspend fun resolveRoute(context: Context): WidgetRoute {
        WidgetPrefs.loadRoute(context)?.let { return it }
        val system = "TR"
        val stations = GetPickerStationsUseCase(WidgetStationRepositoryImpl(context)).execute(system)
        val first = stations.getOrNull(0)
        val second = stations.getOrNull(1)
        if (first != null && second != null) {
            return WidgetRoute(first.name, first.stationId, second.name, second.stationId, system)
        }
        return WidgetRoute.defaultFor(system)
    }

    private fun timeNow(): String = SimpleDateFormat("HH:mm", Locale.US).apply {
        timeZone = TimeZone.getTimeZone("Asia/Taipei")
    }.format(Date())
}

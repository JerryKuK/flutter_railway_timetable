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
import com.example.flutter_railway_timetable.widget.data.prefs.WidgetPrefsHSR
import com.example.flutter_railway_timetable.widget.data.repository.TrainScheduleRepositoryImpl
import com.example.flutter_railway_timetable.widget.domain.entity.WidgetRoute
import com.example.flutter_railway_timetable.widget.domain.usecase.GetNextTrainsUseCase
import com.example.flutter_railway_timetable.widget.util.TaipeiClock

class HSRRefreshWidgetAction : ActionCallback {

    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        val useCase = defaultUseCase()
        val route = resolveRoute(context)
        executeWith(context, route, useCase)

        updateAppWidgetState(context, glanceId) { prefs ->
            prefs[HSRRailwayGlanceWidget.VERSION_KEY] = System.currentTimeMillis()
        }
        HSRRailwayGlanceWidget().update(context, glanceId)
    }

    private fun defaultUseCase(): GetNextTrainsUseCase {
        val authManager = KotlinTdxAuthManager(
            clientId = BuildConfig.TDX_CLIENT_ID,
            clientSecret = BuildConfig.TDX_CLIENT_SECRET
        )
        return GetNextTrainsUseCase(TrainScheduleRepositoryImpl(TdxApiClient(authManager)))
    }

    companion object {
        // Do NOT fall back to the first two picker stations as TR does —
        // HSR picker is fixed N→S order, so first-two would always be
        // 南港 → 臺北 instead of the canonical 臺北 → 左營 default.
        suspend fun resolveRoute(context: Context): WidgetRoute {
            return WidgetPrefsHSR.loadRoute(context)
                ?: WidgetRoute.defaultFor("HSR")
        }

        suspend fun executeWith(
            context: Context,
            route: WidgetRoute,
            useCase: GetNextTrainsUseCase,
        ) {
            val today = TaipeiClock.todayDate()

            try {
                val schedules = useCase.execute(route.fromId, route.toId, today, "HSR")
                WidgetPrefsHSR.saveRefreshResult(context, route, schedules, TaipeiClock.nowTime())
            } catch (e: WidgetAuthException) {
                WidgetPrefsHSR.saveRefreshError(context, e.message ?: "ERR_AUTH")
            } catch (_: Exception) {
                WidgetPrefsHSR.saveRefreshError(context, "查詢失敗，請稍後再試")
            }
        }
    }
}

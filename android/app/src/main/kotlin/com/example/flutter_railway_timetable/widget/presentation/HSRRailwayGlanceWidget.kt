package com.example.flutter_railway_timetable.widget.presentation

import android.content.Context
import androidx.compose.runtime.getValue
import androidx.compose.runtime.produceState
import androidx.compose.ui.graphics.Color
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.longPreferencesKey
import androidx.glance.GlanceId
import androidx.glance.action.actionParametersOf
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.provideContent
import androidx.glance.currentState
import androidx.glance.state.PreferencesGlanceStateDefinition
import com.example.flutter_railway_timetable.R
import com.example.flutter_railway_timetable.widget.data.prefs.WidgetPrefsHSR
import com.example.flutter_railway_timetable.widget.data.repository.WidgetStationRepositoryImpl
import com.example.flutter_railway_timetable.widget.domain.entity.PickerStation
import com.example.flutter_railway_timetable.widget.domain.entity.PickerStationDefaults
import com.example.flutter_railway_timetable.widget.domain.entity.WidgetRoute
import com.example.flutter_railway_timetable.widget.domain.usecase.GetPickerStationsUseCase

// HSR widget palette — mirrors iOS RailwayPalette.hsr.
private val hsrPalette = Palette(
    accent = Color(0xFFC86820),
    accentSoft = Color(0xFFFBEEDF),
    displayName = "高鐵",
    iconRes = R.drawable.widget_icon_hsr,
)

class HSRRailwayGlanceWidget : GlanceAppWidget() {

    override val stateDefinition = PreferencesGlanceStateDefinition

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            val state = currentState<Preferences>()
            // HSR picker is a fixed 12-station N→S list, so STATIONS_VERSION_KEY
            // is never bumped from Flutter — its purpose here is only to keep
            // produceState from re-running when action callbacks bump VERSION_KEY
            // for UI recompose. Effectively `Unit` as the key, written explicitly
            // to mirror the TR widget shape.
            val stationsVersion = state[STATIONS_VERSION_KEY] ?: 0L

            val pickerMode = WidgetPrefsHSR.loadPickerMode(context)
            val route = WidgetPrefsHSR.loadRoute(context) ?: WidgetRoute.defaultFor("HSR")
            val schedules = WidgetPrefsHSR.loadSchedules(context)
            val lastError = WidgetPrefsHSR.loadLastError(context)
            val lastUpdate = WidgetPrefsHSR.loadLastUpdate(context)

            val stations: List<PickerStation> by produceState(
                initialValue = PickerStationDefaults.stations("HSR"),
                stationsVersion,
            ) {
                value = GetPickerStationsUseCase(WidgetStationRepositoryImpl(context))
                    .execute("HSR")
            }

            if (pickerMode == "from" || pickerMode == "to") {
                PickerContent(
                    route = route,
                    stations = stations,
                    mode = pickerMode,
                    palette = hsrPalette,
                    // 4 cols × 3 rows = 12 stations. 6-col rows overflow the
                    // 4×2 widget width (last chip gets clipped); 4 cols keeps
                    // ~60dp per chip and renders all 12 reliably.
                    chunkSize = 4,
                    selectStationAction = { station, isFrom ->
                        actionRunCallback<HSRSelectStationAction>(
                            actionParametersOf(
                                ActionKeys.stationName to station.name,
                                ActionKeys.stationId to station.stationId,
                                ActionKeys.isFrom to isFrom
                            )
                        )
                    },
                    dismissAction = actionRunCallback<HSRDismissPickerAction>(),
                )
            } else {
                WidgetContent(
                    route = route,
                    schedules = schedules,
                    lastError = lastError,
                    lastUpdate = lastUpdate,
                    palette = hsrPalette,
                    showFromPickerAction = actionRunCallback<HSRShowPickerAction>(
                        actionParametersOf(ActionKeys.mode to "from")
                    ),
                    showToPickerAction = actionRunCallback<HSRShowPickerAction>(
                        actionParametersOf(ActionKeys.mode to "to")
                    ),
                    refreshAction = actionRunCallback<HSRRefreshWidgetAction>(),
                )
            }
        }
    }

    companion object {
        val VERSION_KEY = longPreferencesKey("hsr_widget_version")
        val STATIONS_VERSION_KEY = longPreferencesKey("hsr_widget_stations_version")
    }
}

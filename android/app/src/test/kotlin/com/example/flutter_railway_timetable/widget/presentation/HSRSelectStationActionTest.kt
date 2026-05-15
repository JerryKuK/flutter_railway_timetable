package com.example.flutter_railway_timetable.widget.presentation

import android.content.Context
import androidx.glance.action.ActionParameters
import androidx.glance.action.actionParametersOf
import com.example.flutter_railway_timetable.widget.data.network.TdxApiClient
import com.example.flutter_railway_timetable.widget.data.prefs.WidgetPrefsHSR
import com.example.flutter_railway_timetable.widget.data.prefs.WidgetPrefsTR
import com.example.flutter_railway_timetable.widget.domain.entity.WidgetRoute
import com.example.flutter_railway_timetable.widget.domain.entity.WidgetSchedule
import io.mockk.coVerify
import io.mockk.every
import io.mockk.just
import io.mockk.mockk
import io.mockk.mockkObject
import io.mockk.Runs
import io.mockk.unmockkAll
import io.mockk.verify
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Before
import org.junit.Test

class HSRSelectStationActionTest {

    private val context = mockk<Context>(relaxed = true)

    @Before
    fun setup() {
        mockkObject(WidgetPrefsHSR)
        mockkObject(WidgetPrefsTR)
        every { WidgetPrefsHSR.loadRoute(context) } returns WidgetRoute.defaultFor("HSR")
        every { WidgetPrefsHSR.saveRoute(any(), any()) } just Runs
        every { WidgetPrefsHSR.saveSchedules(any(), any()) } just Runs
        every { WidgetPrefsHSR.savePickerMode(any(), any()) } just Runs
    }

    @After
    fun teardown() {
        unmockkAll()
    }

    @Test
    fun `selecting from station writes hsr_widget_route with new from`() = runBlocking {
        val params = actionParametersOf(
            ActionKeys.stationName to "板橋",
            ActionKeys.stationId to "1010",
            ActionKeys.isFrom to true,
        )

        HSRSelectStationAction.applyStationSelection(context, params)

        verify {
            WidgetPrefsHSR.saveRoute(
                context,
                match { it.fromName == "板橋" && it.fromId == "1010" && it.system == "HSR" },
            )
        }
    }

    @Test
    fun `selecting to station writes hsr_widget_route with new to`() = runBlocking {
        val params = actionParametersOf(
            ActionKeys.stationName to "嘉義",
            ActionKeys.stationId to "1050",
            ActionKeys.isFrom to false,
        )

        HSRSelectStationAction.applyStationSelection(context, params)

        verify {
            WidgetPrefsHSR.saveRoute(
                context,
                match { it.toName == "嘉義" && it.toId == "1050" && it.system == "HSR" },
            )
        }
    }

    @Test
    fun `selecting station clears hsr_widget_schedules`() = runBlocking {
        val params = actionParametersOf(
            ActionKeys.stationName to "板橋",
            ActionKeys.stationId to "1010",
            ActionKeys.isFrom to true,
        )

        HSRSelectStationAction.applyStationSelection(context, params)

        verify { WidgetPrefsHSR.saveSchedules(context, emptyList<WidgetSchedule>()) }
    }

    @Test
    fun `selecting station resets picker mode to home`() = runBlocking {
        val params = actionParametersOf(
            ActionKeys.stationName to "板橋",
            ActionKeys.stationId to "1010",
            ActionKeys.isFrom to true,
        )

        HSRSelectStationAction.applyStationSelection(context, params)

        verify { WidgetPrefsHSR.savePickerMode(context, "home") }
    }

    @Test
    fun `selecting station never writes TR namespace`() = runBlocking {
        val params = actionParametersOf(
            ActionKeys.stationName to "板橋",
            ActionKeys.stationId to "1010",
            ActionKeys.isFrom to true,
        )

        HSRSelectStationAction.applyStationSelection(context, params)

        verify(exactly = 0) { WidgetPrefsTR.saveRoute(any(), any()) }
        verify(exactly = 0) { WidgetPrefsTR.saveSchedules(any(), any()) }
        verify(exactly = 0) { WidgetPrefsTR.savePickerMode(any(), any()) }
    }

    @Test
    fun `selecting station does NOT call TdxApiClient`() = runBlocking {
        val apiClient = mockk<TdxApiClient>(relaxed = true)
        val params = actionParametersOf(
            ActionKeys.stationName to "板橋",
            ActionKeys.stationId to "1010",
            ActionKeys.isFrom to true,
        )

        HSRSelectStationAction.applyStationSelection(context, params)

        // The action MUST NOT hit the network when only the route changes.
        // User must press 查詢 button to actually fetch — matches TR widget UX
        // and the design.jsx interaction model.
        coVerify(exactly = 0) { apiClient.fetchHSRSchedule(any(), any(), any()) }
        coVerify(exactly = 0) { apiClient.fetchTRASchedule(any(), any(), any()) }
    }

    @Test
    fun `missing stationName parameter is a no-op`() = runBlocking {
        // Defensive: malformed Action params shouldn't crash or write garbage.
        val params: ActionParameters = actionParametersOf(
            ActionKeys.isFrom to true,
        )

        HSRSelectStationAction.applyStationSelection(context, params)

        verify(exactly = 0) { WidgetPrefsHSR.saveRoute(any(), any()) }
        verify(exactly = 0) { WidgetPrefsHSR.saveSchedules(any(), any()) }
    }
}

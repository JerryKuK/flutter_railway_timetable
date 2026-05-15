package com.example.flutter_railway_timetable.widget.presentation

import android.content.Context
import androidx.glance.action.actionParametersOf
import com.example.flutter_railway_timetable.widget.data.prefs.WidgetPrefsHSR
import com.example.flutter_railway_timetable.widget.data.prefs.WidgetPrefsTR
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

class HSRShowPickerActionTest {

    private val context = mockk<Context>(relaxed = true)

    @Before
    fun setup() {
        mockkObject(WidgetPrefsHSR)
        mockkObject(WidgetPrefsTR)
        every { WidgetPrefsHSR.savePickerMode(any(), any()) } just Runs
    }

    @After
    fun teardown() {
        unmockkAll()
    }

    @Test
    fun `from mode writes hsr_widget_picker_mode = from`() = runBlocking {
        val params = actionParametersOf(ActionKeys.mode to "from")

        HSRShowPickerAction.applyShowPicker(context, params)

        verify { WidgetPrefsHSR.savePickerMode(context, "from") }
    }

    @Test
    fun `to mode writes hsr_widget_picker_mode = to`() = runBlocking {
        val params = actionParametersOf(ActionKeys.mode to "to")

        HSRShowPickerAction.applyShowPicker(context, params)

        verify { WidgetPrefsHSR.savePickerMode(context, "to") }
    }

    @Test
    fun `missing mode parameter defaults to from`() = runBlocking {
        val params = actionParametersOf()

        HSRShowPickerAction.applyShowPicker(context, params)

        verify { WidgetPrefsHSR.savePickerMode(context, "from") }
    }

    @Test
    fun `never writes TR picker_mode key`() = runBlocking {
        val params = actionParametersOf(ActionKeys.mode to "from")

        HSRShowPickerAction.applyShowPicker(context, params)

        verify(exactly = 0) { WidgetPrefsTR.savePickerMode(any(), any()) }
    }
}

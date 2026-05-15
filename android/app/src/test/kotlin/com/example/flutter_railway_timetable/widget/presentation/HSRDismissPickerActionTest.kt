package com.example.flutter_railway_timetable.widget.presentation

import android.content.Context
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

class HSRDismissPickerActionTest {

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
    fun `dismiss writes hsr_widget_picker_mode = home`() = runBlocking {
        HSRDismissPickerAction.applyDismiss(context)

        verify { WidgetPrefsHSR.savePickerMode(context, "home") }
    }

    @Test
    fun `dismiss never writes TR picker_mode key`() = runBlocking {
        HSRDismissPickerAction.applyDismiss(context)

        verify(exactly = 0) { WidgetPrefsTR.savePickerMode(any(), any()) }
    }
}

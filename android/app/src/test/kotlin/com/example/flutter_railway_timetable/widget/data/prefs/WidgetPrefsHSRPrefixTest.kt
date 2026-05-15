package com.example.flutter_railway_timetable.widget.data.prefs

import android.content.Context
import android.content.SharedPreferences
import com.example.flutter_railway_timetable.widget.domain.entity.WidgetRoute
import com.example.flutter_railway_timetable.widget.domain.entity.WidgetSchedule
import io.mockk.every
import io.mockk.mockk
import io.mockk.slot
import io.mockk.verify
import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Before
import org.junit.Test

class WidgetPrefsHSRPrefixTest {

    private val context = mockk<Context>()
    private val prefs = mockk<SharedPreferences>(relaxed = true)
    private val editor = mockk<SharedPreferences.Editor>(relaxed = true)

    @Before
    fun setup() {
        every { context.getSharedPreferences(any(), any()) } returns prefs
        every { prefs.edit() } returns editor
        every { editor.putString(any(), any()) } returns editor
        every { editor.remove(any()) } returns editor
    }

    @Test
    fun `saveRoute writes hsr_widget_route key`() {
        val keySlot = slot<String>()
        every { editor.putString(capture(keySlot), any()) } returns editor

        WidgetPrefsHSR.saveRoute(
            context,
            WidgetRoute("臺北", "1000", "左營", "1070", "HSR"),
        )

        assertEquals("hsr_widget_route", keySlot.captured)
        assertFalse("must not touch TR key", keySlot.captured == "widget_route")
    }

    @Test
    fun `loadRoute reads hsr_widget_route key`() {
        every { prefs.getString("hsr_widget_route", null) } returns JSONObject().apply {
            put("fromName", "臺北"); put("fromId", "1000")
            put("toName", "左營"); put("toId", "1070")
            put("system", "HSR")
        }.toString()

        val route = WidgetPrefsHSR.loadRoute(context)

        assertEquals("HSR", route?.system)
        assertEquals("左營", route?.toName)
        verify { prefs.getString("hsr_widget_route", null) }
    }

    @Test
    fun `saveSchedules writes hsr_widget_schedules key`() {
        val keySlot = slot<String>()
        every { editor.putString(capture(keySlot), any()) } returns editor

        WidgetPrefsHSR.saveSchedules(
            context,
            listOf(WidgetSchedule("10:00", "11:30", "標準", "#1234")),
        )

        assertEquals("hsr_widget_schedules", keySlot.captured)
    }

    @Test
    fun `saveLastError with value writes hsr_widget_last_error key`() {
        val keySlot = slot<String>()
        every { editor.putString(capture(keySlot), any()) } returns editor

        WidgetPrefsHSR.saveLastError(context, "查詢失敗，請稍後再試")

        assertEquals("hsr_widget_last_error", keySlot.captured)
    }

    @Test
    fun `saveLastError null removes hsr_widget_last_error key`() {
        val keySlot = slot<String>()
        every { editor.remove(capture(keySlot)) } returns editor

        WidgetPrefsHSR.saveLastError(context, null)

        assertEquals("hsr_widget_last_error", keySlot.captured)
    }

    @Test
    fun `saveLastUpdate writes hsr_widget_last_update key`() {
        val keySlot = slot<String>()
        every { editor.putString(capture(keySlot), any()) } returns editor

        WidgetPrefsHSR.saveLastUpdate(context, "10:15")

        assertEquals("hsr_widget_last_update", keySlot.captured)
    }

    @Test
    fun `savePickerMode writes hsr_widget_picker_mode key`() {
        val keySlot = slot<String>()
        every { editor.putString(capture(keySlot), any()) } returns editor

        WidgetPrefsHSR.savePickerMode(context, "from")

        assertEquals("hsr_widget_picker_mode", keySlot.captured)
    }

    @Test
    fun `loadPickerMode reads hsr_widget_picker_mode key`() {
        every { prefs.getString("hsr_widget_picker_mode", "home") } returns "from"

        val mode = WidgetPrefsHSR.loadPickerMode(context)

        assertEquals("from", mode)
        verify { prefs.getString("hsr_widget_picker_mode", "home") }
    }

    @Test
    fun `loadLastUpdate reads hsr_widget_last_update key`() {
        every { prefs.getString("hsr_widget_last_update", "") } returns "10:15"

        val lastUpdate = WidgetPrefsHSR.loadLastUpdate(context)

        assertEquals("10:15", lastUpdate)
        verify { prefs.getString("hsr_widget_last_update", "") }
    }
}

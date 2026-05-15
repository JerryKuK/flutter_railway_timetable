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
import org.junit.Before
import org.junit.Test

class WidgetPrefsTrBackwardCompatTest {

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
    fun `saveRoute with default prefix writes widget_route key`() {
        val keySlot = slot<String>()
        every { editor.putString(capture(keySlot), any()) } returns editor

        WidgetPrefsTR.saveRoute(
            context,
            WidgetRoute("臺北", "1000", "高雄", "4400", "TR")
        )

        assertEquals("widget_route", keySlot.captured)
    }

    @Test
    fun `loadRoute with default prefix reads widget_route key`() {
        every { prefs.getString("widget_route", null) } returns JSONObject().apply {
            put("fromName", "臺北"); put("fromId", "1000")
            put("toName", "高雄"); put("toId", "4400")
            put("system", "TR")
        }.toString()

        val route = WidgetPrefsTR.loadRoute(context)

        assertEquals("臺北", route?.fromName)
        assertEquals("TR", route?.system)
        verify { prefs.getString("widget_route", null) }
    }

    @Test
    fun `saveSchedules with default prefix writes widget_schedules key`() {
        val keySlot = slot<String>()
        every { editor.putString(capture(keySlot), any()) } returns editor

        WidgetPrefsTR.saveSchedules(context, listOf(WidgetSchedule("08:00", "10:00", "自強", "#100")))

        assertEquals("widget_schedules", keySlot.captured)
    }

    @Test
    fun `saveLastError null with default prefix removes widget_last_error key`() {
        val keySlot = slot<String>()
        every { editor.remove(capture(keySlot)) } returns editor

        WidgetPrefsTR.saveLastError(context, null)

        assertEquals("widget_last_error", keySlot.captured)
    }

    @Test
    fun `saveLastUpdate with default prefix writes widget_last_update key`() {
        val keySlot = slot<String>()
        every { editor.putString(capture(keySlot), any()) } returns editor

        WidgetPrefsTR.saveLastUpdate(context, "08:30")

        assertEquals("widget_last_update", keySlot.captured)
    }

    @Test
    fun `savePickerMode with default prefix writes widget_picker_mode key`() {
        val keySlot = slot<String>()
        every { editor.putString(capture(keySlot), any()) } returns editor

        WidgetPrefsTR.savePickerMode(context, "from")

        assertEquals("widget_picker_mode", keySlot.captured)
    }

    @Test
    fun `loadPickerMode with default prefix reads widget_picker_mode key and defaults to home`() {
        every { prefs.getString("widget_picker_mode", "home") } returns "home"

        val mode = WidgetPrefsTR.loadPickerMode(context)

        assertEquals("home", mode)
        verify { prefs.getString("widget_picker_mode", "home") }
    }
}

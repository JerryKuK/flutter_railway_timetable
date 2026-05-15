package com.example.flutter_railway_timetable.widget.domain.entity

import org.junit.Assert.assertEquals
import org.junit.Test

class WidgetRouteTest {

    @Test
    fun `defaultFor TR returns 臺北 to 高雄`() {
        val route = WidgetRoute.defaultFor("TR")
        assertEquals("臺北", route.fromName)
        assertEquals("1000", route.fromId)
        assertEquals("高雄", route.toName)
        assertEquals("4400", route.toId)
        assertEquals("TR", route.system)
    }

    @Test
    fun `defaultFor HSR returns 臺北 to 左營`() {
        val route = WidgetRoute.defaultFor("HSR")
        assertEquals("臺北", route.fromName)
        assertEquals("1000", route.fromId)
        assertEquals("左營", route.toName)
        assertEquals("1070", route.toId)
        assertEquals("HSR", route.system)
    }

    @Test
    fun `defaultFor unknown system falls back to TR`() {
        val route = WidgetRoute.defaultFor("UNKNOWN")
        assertEquals("TR", route.system)
    }
}

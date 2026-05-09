package com.example.flutter_railway_timetable.widget.data.prefs

import android.content.Context
import com.example.flutter_railway_timetable.widget.domain.entity.WidgetRoute
import com.example.flutter_railway_timetable.widget.domain.entity.WidgetSchedule
import org.json.JSONArray
import org.json.JSONObject

object WidgetPrefs {
    private const val PREFS_NAME = "com.example.flutter_railway_timetable.widget_prefs"
    private const val KEY_ROUTE = "widget_route"
    private const val KEY_SCHEDULES = "widget_schedules"
    private const val KEY_LAST_ERROR = "widget_last_error"
    private const val KEY_LAST_UPDATE = "widget_last_update"

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun loadRoute(context: Context): WidgetRoute? {
        val json = prefs(context).getString(KEY_ROUTE, null) ?: return null
        return try {
            val obj = JSONObject(json)
            WidgetRoute(
                fromName = obj.getString("fromName"),
                fromId = obj.getString("fromId"),
                toName = obj.getString("toName"),
                toId = obj.getString("toId"),
                system = obj.getString("system")
            )
        } catch (e: Exception) { null }
    }

    fun saveRoute(context: Context, route: WidgetRoute) {
        val obj = JSONObject().apply {
            put("fromName", route.fromName)
            put("fromId", route.fromId)
            put("toName", route.toName)
            put("toId", route.toId)
            put("system", route.system)
        }
        prefs(context).edit().putString(KEY_ROUTE, obj.toString()).apply()
    }

    fun loadSchedules(context: Context): List<WidgetSchedule> {
        val json = prefs(context).getString(KEY_SCHEDULES, null) ?: return emptyList()
        return try {
            val arr = JSONArray(json)
            (0 until arr.length()).mapNotNull { i ->
                val obj = arr.getJSONObject(i)
                WidgetSchedule(
                    dep = obj.optString("dep"),
                    arr = obj.optString("arr"),
                    type = obj.optString("type"),
                    num = obj.optString("num")
                )
            }
        } catch (e: Exception) { emptyList() }
    }

    fun saveSchedules(context: Context, schedules: List<WidgetSchedule>) {
        val arr = JSONArray()
        schedules.forEach { s ->
            arr.put(JSONObject().apply {
                put("dep", s.dep)
                put("arr", s.arr)
                put("type", s.type)
                put("num", s.num)
            })
        }
        prefs(context).edit().putString(KEY_SCHEDULES, arr.toString()).apply()
    }

    fun loadLastError(context: Context): String? =
        prefs(context).getString(KEY_LAST_ERROR, null)

    fun saveLastError(context: Context, error: String?) {
        prefs(context).edit().apply {
            if (error != null) putString(KEY_LAST_ERROR, error) else remove(KEY_LAST_ERROR)
        }.apply()
    }

    fun loadLastUpdate(context: Context): String =
        prefs(context).getString(KEY_LAST_UPDATE, "") ?: ""

    fun saveLastUpdate(context: Context, time: String) {
        prefs(context).edit().putString(KEY_LAST_UPDATE, time).apply()
    }

    fun loadPickerMode(context: Context): String =
        prefs(context).getString(KEY_PICKER_MODE, "home") ?: "home"

    fun savePickerMode(context: Context, mode: String) {
        prefs(context).edit().putString(KEY_PICKER_MODE, mode).apply()
    }

    private const val KEY_PICKER_MODE = "widget_picker_mode"
}

package com.example.flutter_railway_timetable.widget.data.prefs

import android.content.Context
import com.example.flutter_railway_timetable.widget.domain.entity.WidgetRoute
import com.example.flutter_railway_timetable.widget.domain.entity.WidgetSchedule
import org.json.JSONArray
import org.json.JSONObject

// TR and HSR widgets share one SharedPreferences file but namespace their keys
// via prefix. The two singletons below give each widget a typed accessor — no
// per-call keyPrefix argument to remember or get wrong.
//   - WidgetPrefsTR : keys widget_route / widget_schedules / ...
//   - WidgetPrefsHSR: keys hsr_widget_route / hsr_widget_schedules / ...
abstract class WidgetPrefsBase(private val keyPrefix: String) {

    private fun keyRoute() = "${keyPrefix}widget_route"
    private fun keySchedules() = "${keyPrefix}widget_schedules"
    private fun keyLastError() = "${keyPrefix}widget_last_error"
    private fun keyLastUpdate() = "${keyPrefix}widget_last_update"
    private fun keyPickerMode() = "${keyPrefix}widget_picker_mode"

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun loadRoute(context: Context): WidgetRoute? {
        val json = prefs(context).getString(keyRoute(), null) ?: return null
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
        prefs(context).edit().putString(keyRoute(), obj.toString()).apply()
    }

    fun loadSchedules(context: Context): List<WidgetSchedule> {
        val json = prefs(context).getString(keySchedules(), null) ?: return emptyList()
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
        prefs(context).edit().putString(keySchedules(), arr.toString()).apply()
    }

    fun loadLastError(context: Context): String? =
        prefs(context).getString(keyLastError(), null)

    fun saveLastError(context: Context, error: String?) {
        prefs(context).edit().apply {
            if (error != null) putString(keyLastError(), error)
            else remove(keyLastError())
        }.apply()
    }

    fun loadLastUpdate(context: Context): String =
        prefs(context).getString(keyLastUpdate(), "") ?: ""

    fun saveLastUpdate(context: Context, time: String) {
        prefs(context).edit().putString(keyLastUpdate(), time).apply()
    }

    fun loadPickerMode(context: Context): String =
        prefs(context).getString(keyPickerMode(), "home") ?: "home"

    fun savePickerMode(context: Context, mode: String) {
        prefs(context).edit().putString(keyPickerMode(), mode).apply()
    }

    // One-edit batch for a successful refresh: route + schedules + lastUpdate +
    // clear lastError. Avoids 4 separate apply() calls (4 disk schedules).
    fun saveRefreshResult(
        context: Context,
        route: WidgetRoute,
        schedules: List<WidgetSchedule>,
        lastUpdate: String,
    ) {
        val routeJson = JSONObject().apply {
            put("fromName", route.fromName)
            put("fromId", route.fromId)
            put("toName", route.toName)
            put("toId", route.toId)
            put("system", route.system)
        }.toString()

        val schedulesJson = JSONArray().apply {
            schedules.forEach { s ->
                put(JSONObject().apply {
                    put("dep", s.dep)
                    put("arr", s.arr)
                    put("type", s.type)
                    put("num", s.num)
                })
            }
        }.toString()

        prefs(context).edit()
            .putString(keyRoute(), routeJson)
            .putString(keySchedules(), schedulesJson)
            .putString(keyLastUpdate(), lastUpdate)
            .remove(keyLastError())
            .apply()
    }

    // One-edit batch for a failed refresh: clear schedules + write error.
    fun saveRefreshError(context: Context, errorMessage: String) {
        prefs(context).edit()
            .putString(keySchedules(), "[]")
            .putString(keyLastError(), errorMessage)
            .apply()
    }

    private companion object {
        const val PREFS_NAME = "com.example.flutter_railway_timetable.widget_prefs"
    }
}

object WidgetPrefsTR : WidgetPrefsBase("")
object WidgetPrefsHSR : WidgetPrefsBase("hsr_")

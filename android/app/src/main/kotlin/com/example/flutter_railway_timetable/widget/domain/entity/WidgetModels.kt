package com.example.flutter_railway_timetable.widget.domain.entity

data class WidgetSchedule(
    val dep: String,
    val arr: String,
    val type: String,
    val num: String
)

data class WidgetRoute(
    val fromName: String,
    val fromId: String,
    val toName: String,
    val toId: String,
    val system: String
) {
    companion object {
        fun defaultFor(system: String): WidgetRoute = when (system) {
            "HSR" -> WidgetRoute("臺北", "1000", "左營", "1070", "HSR")
            else -> WidgetRoute("臺北", "1000", "高雄", "4400", "TR")
        }
    }
}

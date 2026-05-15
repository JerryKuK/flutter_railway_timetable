package com.example.flutter_railway_timetable.widget.presentation

import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.action.Action
import androidx.glance.action.clickable
import androidx.glance.appwidget.cornerRadius
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.layout.wrapContentWidth
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.example.flutter_railway_timetable.widget.domain.entity.PickerStation
import com.example.flutter_railway_timetable.widget.domain.entity.WidgetRoute
import com.example.flutter_railway_timetable.widget.domain.entity.WidgetSchedule

// Visual theme shared by all rail widgets (TR / HSR). Mirrors iOS
// RailwayPalette — callers pick a palette and pass it down so the same
// @Composable tree renders either system.
internal data class Palette(
    val accent: Color,
    val accentSoft: Color,
    val displayName: String,
    val iconRes: Int,
)

internal val textPrimary = Color(0xFF1F2937)
internal val textSecondary = Color(0xFF6B7280)
internal val textTertiary = Color(0xFF9CA3AF)
internal val chipBg = Color(0xFFF3F4F6)
internal val selectedChipText = Color.White

// Schedule view shared by TR and HSR widgets. Actions are injected so each
// widget can wire its own ActionCallback class (e.g. RefreshWidgetAction vs.
// HSRRefreshWidgetAction) without duplicating the layout.
@Composable
internal fun WidgetContent(
    route: WidgetRoute,
    schedules: List<WidgetSchedule>,
    lastError: String?,
    lastUpdate: String,
    palette: Palette,
    showFromPickerAction: Action,
    showToPickerAction: Action,
    refreshAction: Action,
) {
    Column(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(Color.White)
            .padding(horizontal = 16.dp, vertical = 12.dp)
    ) {
        Row(
            modifier = GlanceModifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Image(
                provider = ImageProvider(palette.iconRes),
                contentDescription = null,
                modifier = GlanceModifier.size(32.dp)
            )
            Spacer(GlanceModifier.width(10.dp))
            Column(modifier = GlanceModifier.defaultWeight()) {
                Text(
                    text = "${palette.displayName} 時刻表",
                    style = TextStyle(
                        fontSize = 15.sp,
                        fontWeight = FontWeight.Bold,
                        color = ColorProvider(textPrimary)
                    )
                )
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(modifier = GlanceModifier
                        .wrapContentWidth()
                        .clickable(showFromPickerAction)
                    ) {
                        Text(
                            text = route.fromName,
                            style = TextStyle(fontSize = 12.sp, color = ColorProvider(palette.accent))
                        )
                    }
                    Text(
                        text = " → ",
                        style = TextStyle(fontSize = 12.sp, color = ColorProvider(textSecondary))
                    )
                    Box(modifier = GlanceModifier
                        .wrapContentWidth()
                        .clickable(showToPickerAction)
                    ) {
                        Text(
                            text = route.toName,
                            style = TextStyle(fontSize = 12.sp, color = ColorProvider(palette.accent))
                        )
                    }
                }
            }
            if (lastUpdate.isNotEmpty()) {
                Box(
                    modifier = GlanceModifier
                        .background(palette.accentSoft)
                        .cornerRadius(10.dp)
                        .padding(horizontal = 10.dp, vertical = 5.dp)
                ) {
                    Text(
                        text = "更新 $lastUpdate",
                        style = TextStyle(
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold,
                            color = ColorProvider(palette.accent)
                        )
                    )
                }
                Spacer(GlanceModifier.width(6.dp))
            }
            Box(
                modifier = GlanceModifier
                    .background(palette.accentSoft)
                    .cornerRadius(10.dp)
                    .padding(horizontal = 12.dp, vertical = 5.dp)
                    .clickable(refreshAction)
            ) {
                Text(
                    text = "查詢",
                    style = TextStyle(
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        color = ColorProvider(palette.accent)
                    )
                )
            }
        }

        Spacer(GlanceModifier.height(10.dp))

        if (schedules.isEmpty()) {
            Text(
                text = lastError ?: "點站名選路線，再按查詢",
                style = TextStyle(fontSize = 13.sp, color = ColorProvider(textTertiary))
            )
        } else {
            schedules.forEach { s -> TrainRow(s, palette) }
        }
    }
}

@Composable
internal fun TrainRow(schedule: WidgetSchedule, palette: Palette) {
    Row(
        modifier = GlanceModifier.fillMaxWidth().padding(vertical = 6.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = schedule.dep,
            style = TextStyle(
                fontSize = 16.sp,
                fontWeight = FontWeight.Bold,
                color = ColorProvider(palette.accent)
            ),
            modifier = GlanceModifier.width(52.dp)
        )
        Spacer(GlanceModifier.width(8.dp))
        Box(
            modifier = GlanceModifier
                .background(chipBg)
                .cornerRadius(6.dp)
                .padding(horizontal = 8.dp, vertical = 3.dp)
        ) {
            Text(
                text = schedule.type,
                style = TextStyle(fontSize = 12.sp, color = ColorProvider(textSecondary))
            )
        }
        Spacer(GlanceModifier.width(8.dp))
        Text(
            text = schedule.num,
            style = TextStyle(fontSize = 12.sp, color = ColorProvider(textSecondary)),
            modifier = GlanceModifier.defaultWeight()
        )
        Text(
            text = "→ ${schedule.arr}",
            style = TextStyle(fontSize = 12.sp, color = ColorProvider(textSecondary))
        )
    }
}

// `chunkSize` is the chips-per-row count (TR: 5, HSR: 4). `selectStationAction`
// is a factory so each chip builds its own (stationName, stationId, isFrom) Action.
@Composable
internal fun PickerContent(
    route: WidgetRoute,
    stations: List<PickerStation>,
    mode: String,
    palette: Palette,
    chunkSize: Int,
    selectStationAction: (station: PickerStation, isFrom: Boolean) -> Action,
    dismissAction: Action,
) {
    val isFrom = mode == "from"
    val other = if (isFrom) route.toName else route.fromName
    val currentName = if (isFrom) route.fromName else route.toName

    Column(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(Color.White)
            .padding(horizontal = 16.dp, vertical = 12.dp)
    ) {
        Row(
            modifier = GlanceModifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Image(
                provider = ImageProvider(palette.iconRes),
                contentDescription = null,
                modifier = GlanceModifier.size(28.dp)
            )
            Spacer(GlanceModifier.width(8.dp))
            Column(modifier = GlanceModifier.defaultWeight()) {
                Text(
                    text = "選擇${if (isFrom) "出發" else "到達"}站",
                    style = TextStyle(
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Bold,
                        color = ColorProvider(textPrimary)
                    )
                )
                Text(
                    text = "${palette.displayName} · 點選下方車站",
                    style = TextStyle(fontSize = 11.sp, color = ColorProvider(textSecondary))
                )
            }
            Box(
                modifier = GlanceModifier
                    .size(26.dp)
                    .background(chipBg)
                    .cornerRadius(13.dp)
                    .clickable(dismissAction),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "×",
                    style = TextStyle(
                        fontSize = 15.sp,
                        fontWeight = FontWeight.Bold,
                        color = ColorProvider(textSecondary)
                    )
                )
            }
        }

        Spacer(GlanceModifier.height(10.dp))

        val rows = stations.chunked(chunkSize)
        rows.forEach { rowStations ->
            Row(modifier = GlanceModifier.fillMaxWidth()) {
                rowStations.forEachIndexed { index, station ->
                    if (index > 0) Spacer(GlanceModifier.width(5.dp))
                    val isSelected = station.name == currentName
                    Box(
                        modifier = GlanceModifier
                            .defaultWeight()
                            .background(if (isSelected) palette.accent else chipBg)
                            .cornerRadius(999.dp)
                            .padding(vertical = 6.dp)
                            .clickable(selectStationAction(station, isFrom)),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = station.name,
                            style = TextStyle(
                                fontSize = 12.sp,
                                color = ColorProvider(
                                    if (isSelected) selectedChipText else textPrimary
                                )
                            )
                        )
                    }
                }
            }
            Spacer(GlanceModifier.height(7.dp))
        }

        Spacer(GlanceModifier.height(4.dp))

        Row(
            modifier = GlanceModifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = if (isFrom) "到達" else "出發",
                style = TextStyle(fontSize = 12.sp, color = ColorProvider(textSecondary))
            )
            Spacer(GlanceModifier.width(4.dp))
            Text(
                text = other,
                style = TextStyle(
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    color = ColorProvider(textPrimary)
                )
            )
        }
    }
}

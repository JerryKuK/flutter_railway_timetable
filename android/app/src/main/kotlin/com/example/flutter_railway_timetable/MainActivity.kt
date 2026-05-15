package com.example.flutter_railway_timetable

import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.state.updateAppWidgetState
import androidx.lifecycle.lifecycleScope
import com.example.flutter_railway_timetable.widget.presentation.RailwayGlanceWidget
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.io.File

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // iOS uses an App Group container. Android's widget receiver
                    // shares the same UID as the activity, so "any directory in this
                    // app" works — but Room expects its DB inside <dataDir>/databases/.
                    // We return that exact directory so Flutter's Drift writes land
                    // where Room reads them.
                    "getAppGroupDir" -> {
                        val dbDir = applicationContext
                            .getDatabasePath("widget_stations.db")
                            .parentFile
                            ?: File(applicationContext.filesDir, "databases")
                        dbDir.mkdirs()
                        result.success(dbDir.absolutePath)
                    }

                    // TR-only: bumps every TR widget's STATIONS_VERSION_KEY so its
                    // picker re-queries Drift after the user picks new from/to stations
                    // on the home page. HSR widget intentionally not reloaded — its
                    // picker is a fixed 12-station N→S list, no Flutter-side sync.
                    "reloadWidget" -> {
                        lifecycleScope.launch(Dispatchers.IO) {
                            try {
                                val manager = GlanceAppWidgetManager(applicationContext)
                                val now = System.currentTimeMillis()

                                for (gid in manager.getGlanceIds(RailwayGlanceWidget::class.java)) {
                                    updateAppWidgetState(applicationContext, gid) { prefs ->
                                        prefs[RailwayGlanceWidget.STATIONS_VERSION_KEY] = now
                                    }
                                    RailwayGlanceWidget().update(applicationContext, gid)
                                }

                                runOnUiThread { result.success(null) }
                            } catch (e: Exception) {
                                runOnUiThread { result.error("RELOAD_FAILED", e.message, null) }
                            }
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    companion object {
        private const val CHANNEL = "com.jerry.railwaytimetable/app_group"
    }
}

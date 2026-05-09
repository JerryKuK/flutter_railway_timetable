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

                    // Triggers Glance recomposition for every widget instance via the
                    // VERSION_KEY pattern so the picker reflects newly-pinned stations
                    // immediately after the user selects from/to in the app.
                    "reloadWidget" -> {
                        lifecycleScope.launch(Dispatchers.IO) {
                            try {
                                val manager = GlanceAppWidgetManager(applicationContext)
                                val ids = manager.getGlanceIds(RailwayGlanceWidget::class.java)
                                for (gid in ids) {
                                    updateAppWidgetState(applicationContext, gid) { prefs ->
                                        prefs[RailwayGlanceWidget.VERSION_KEY] =
                                            System.currentTimeMillis()
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

package com.example.flutter_railway_timetable.widget.data.network

import com.example.flutter_railway_timetable.widget.data.auth.KotlinTdxAuthManager
import com.example.flutter_railway_timetable.widget.domain.entity.WidgetSchedule
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

// Returns mapped schedules in API order. Callers (see GetNextTrainsUseCase) are
// responsible for sorting before presenting — keeps this layer side-effect free
// and avoids redundant sorts.
class TdxApiClient(
    private val authManager: KotlinTdxAuthManager,
    private val service: TdxApiService = defaultService(),
) {

    suspend fun fetchTRASchedule(fromId: String, toId: String, date: String): List<WidgetSchedule> {
        val token = authManager.getValidToken()
        val response = service.getTRADailyTimetable(
            origin = fromId,
            destination = toId,
            date = date,
            authorization = "Bearer $token"
        )
        return response.trainTimetables.mapNotNull { item ->
            val stopTimes = item.stopTimes
            if (stopTimes.size < 2) return@mapNotNull null
            val origin = stopTimes.first()
            val dest = stopTimes.last()
            val dep = origin.departureTime.take(5)
            val arr = dest.arrivalTime.take(5)
            if (dep.isBlank() || arr.isBlank()) return@mapNotNull null
            WidgetSchedule(
                dep = dep,
                arr = arr,
                type = item.trainInfo?.trainTypeName?.zhTw ?: "",
                num = "#${item.trainInfo?.trainNo ?: ""}"
            )
        }
    }

    suspend fun fetchHSRSchedule(fromId: String, toId: String, date: String): List<WidgetSchedule> {
        val token = authManager.getValidToken()
        val response = service.getHSRDailyTimetable(
            origin = fromId,
            destination = toId,
            date = date,
            authorization = "Bearer $token"
        )
        // HSR returns 404 when the OD pair has no trains that day — treat as empty.
        if (response.code() == 404) return emptyList()
        if (!response.isSuccessful) error("HSR API HTTP ${response.code()}")
        val items = response.body() ?: return emptyList()
        return items.mapNotNull { item ->
            val dep = item.originStopTime?.departureTime?.take(5)
            val arr = item.destinationStopTime?.arrivalTime?.take(5)
            if (dep.isNullOrBlank() || arr.isNullOrBlank()) return@mapNotNull null
            // TrainNo / TrainTypeName live inside DailyTrainInfo — reading the
            // old top-level keys yields "#null" / "null" instead of the train
            // number and type. Falls back to "標準" for type and empty TrainNo
            // (rendered as just "#") if the nested object is missing.
            val info = item.dailyTrainInfo
            WidgetSchedule(
                dep = dep,
                arr = arr,
                type = info?.trainTypeName?.zhTw ?: "標準",
                num = "#${info?.trainNo ?: ""}",
            )
        }
    }

    private companion object {
        const val BASE_URL = "https://tdx.transportdata.tw"

        fun defaultService(): TdxApiService = Retrofit.Builder()
            .baseUrl(BASE_URL)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
            .create(TdxApiService::class.java)
    }
}

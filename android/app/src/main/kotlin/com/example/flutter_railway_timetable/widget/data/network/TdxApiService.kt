package com.example.flutter_railway_timetable.widget.data.network

import com.google.gson.annotations.SerializedName
import retrofit2.Response
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.Path
import retrofit2.http.Query

interface TdxApiService {
    @GET("/api/basic/v3/Rail/TRA/DailyTrainTimetable/OD/{origin}/to/{destination}/{date}")
    suspend fun getTRADailyTimetable(
        @Path("origin") origin: String,
        @Path("destination") destination: String,
        @Path("date") date: String,
        @Header("Authorization") authorization: String,
        @Query("\$format") format: String = "JSON"
    ): TdxTraTimetableResponse

    // HSR returns a bare JSON array, not a wrapped object. Response<...> lets us
    // distinguish 404 (= no trains for that day) from real errors.
    @GET("/api/basic/v2/Rail/THSR/DailyTimetable/OD/{origin}/to/{destination}/{date}")
    suspend fun getHSRDailyTimetable(
        @Path("origin") origin: String,
        @Path("destination") destination: String,
        @Path("date") date: String,
        @Header("Authorization") authorization: String,
        @Query("\$format") format: String = "JSON"
    ): Response<List<TdxThsrItem>>
}

// ─── TRA DTOs ──────────────────────────────────────────────────────────────

data class TdxTraTimetableResponse(
    @SerializedName("TrainTimetables") val trainTimetables: List<TdxTimetableItem> = emptyList()
)

data class TdxTimetableItem(
    @SerializedName("TrainInfo") val trainInfo: TdxTrainInfo?,
    @SerializedName("StopTimes") val stopTimes: List<TdxStopTime> = emptyList()
)

data class TdxTrainInfo(
    @SerializedName("TrainNo") val trainNo: String = "",
    @SerializedName("TrainTypeName") val trainTypeName: TdxMultilingualName?
)

data class TdxMultilingualName(
    @SerializedName("Zh_tw") val zhTw: String?
)

data class TdxStopTime(
    @SerializedName("StationID") val stationId: String = "",
    @SerializedName("DepartureTime") val departureTime: String = "",
    @SerializedName("ArrivalTime") val arrivalTime: String = ""
)

// ─── HSR DTOs ──────────────────────────────────────────────────────────────

// TDX v2 THSR DailyTimetable OD API nests TrainNo + TrainTypeName inside
// a `DailyTrainInfo` object (mirrors the Flutter side fix in commit 4545b13).
// OriginStopTime / DestinationStopTime stay at the top level.
data class TdxThsrItem(
    @SerializedName("DailyTrainInfo") val dailyTrainInfo: TdxThsrDailyTrainInfo?,
    @SerializedName("OriginStopTime") val originStopTime: TdxThsrStopTime?,
    @SerializedName("DestinationStopTime") val destinationStopTime: TdxThsrStopTime?,
)

data class TdxThsrDailyTrainInfo(
    @SerializedName("TrainNo") val trainNo: String = "",
    @SerializedName("TrainTypeName") val trainTypeName: TdxMultilingualName?,
)

data class TdxThsrStopTime(
    @SerializedName("DepartureTime") val departureTime: String = "",
    @SerializedName("ArrivalTime") val arrivalTime: String = "",
)

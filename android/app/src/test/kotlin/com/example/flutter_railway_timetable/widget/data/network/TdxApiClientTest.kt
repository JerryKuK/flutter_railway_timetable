package com.example.flutter_railway_timetable.widget.data.network

import com.example.flutter_railway_timetable.widget.data.auth.KotlinTdxAuthManager
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.mockk
import kotlinx.coroutines.runBlocking
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.ResponseBody.Companion.toResponseBody
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Assert.fail
import org.junit.Test
import retrofit2.Response

class TdxApiClientTest {

    private val authManager = mockk<KotlinTdxAuthManager>().also {
        coEvery { it.getValidToken() } returns "stub-token"
    }
    private val service = mockk<TdxApiService>()
    private val client = TdxApiClient(authManager, service)

    // ─── TRA ──────────────────────────────────────────────────────────────────

    @Test
    fun `fetchTRASchedule maps fields and trims times to HH_mm`() = runBlocking {
        coEvery {
            service.getTRADailyTimetable("1000", "3300", "2026-05-09", "Bearer stub-token")
        } returns TdxTraTimetableResponse(
            trainTimetables = listOf(
                TdxTimetableItem(
                    trainInfo = TdxTrainInfo(trainNo = "152", trainTypeName = TdxMultilingualName("自強")),
                    stopTimes = listOf(
                        TdxStopTime(stationId = "1000", departureTime = "08:30:00", arrivalTime = ""),
                        TdxStopTime(stationId = "3300", departureTime = "", arrivalTime = "11:45:00"),
                    )
                )
            )
        )

        val result = client.fetchTRASchedule("1000", "3300", "2026-05-09")

        assertEquals(1, result.size)
        assertEquals("08:30", result[0].dep)
        assertEquals("11:45", result[0].arr)
        assertEquals("自強", result[0].type)
        assertEquals("#152", result[0].num)
        coVerify(exactly = 1) { authManager.getValidToken() }
    }

    @Test
    fun `fetchTRASchedule drops items with fewer than 2 stop times`() = runBlocking {
        coEvery {
            service.getTRADailyTimetable(any(), any(), any(), any())
        } returns TdxTraTimetableResponse(
            trainTimetables = listOf(
                TdxTimetableItem(
                    trainInfo = TdxTrainInfo("100", TdxMultilingualName("自強")),
                    stopTimes = listOf(TdxStopTime("1000", "08:00:00", ""))
                ),
                TdxTimetableItem(
                    trainInfo = TdxTrainInfo("101", TdxMultilingualName("自強")),
                    stopTimes = listOf(
                        TdxStopTime("1000", "09:00:00", ""),
                        TdxStopTime("3300", "", "11:00:00"),
                    )
                )
            )
        )

        val result = client.fetchTRASchedule("1000", "3300", "2026-05-09")

        assertEquals(1, result.size)
        assertEquals("#101", result[0].num)
    }

    @Test
    fun `fetchTRASchedule drops items with blank dep or arr`() = runBlocking {
        coEvery {
            service.getTRADailyTimetable(any(), any(), any(), any())
        } returns TdxTraTimetableResponse(
            trainTimetables = listOf(
                TdxTimetableItem(
                    trainInfo = TdxTrainInfo("200", TdxMultilingualName("區間")),
                    stopTimes = listOf(
                        TdxStopTime("1000", "", ""),
                        TdxStopTime("3300", "", "12:00:00"),
                    )
                )
            )
        )

        assertTrue(client.fetchTRASchedule("1000", "3300", "2026-05-09").isEmpty())
    }

    @Test
    fun `fetchTRASchedule preserves API order (sorting is caller's job)`() = runBlocking {
        coEvery {
            service.getTRADailyTimetable(any(), any(), any(), any())
        } returns TdxTraTimetableResponse(
            trainTimetables = listOf(
                TdxTimetableItem(
                    trainInfo = TdxTrainInfo("late", TdxMultilingualName("自強")),
                    stopTimes = listOf(
                        TdxStopTime("1000", "12:00:00", ""),
                        TdxStopTime("3300", "", "14:00:00"),
                    )
                ),
                TdxTimetableItem(
                    trainInfo = TdxTrainInfo("early", TdxMultilingualName("自強")),
                    stopTimes = listOf(
                        TdxStopTime("1000", "08:00:00", ""),
                        TdxStopTime("3300", "", "10:00:00"),
                    )
                )
            )
        )

        val result = client.fetchTRASchedule("1000", "3300", "2026-05-09")

        assertEquals("#late", result[0].num)
        assertEquals("#early", result[1].num)
    }

    // ─── HSR ──────────────────────────────────────────────────────────────────

    @Test
    fun `fetchHSRSchedule returns empty on 404`() = runBlocking {
        coEvery {
            service.getHSRDailyTimetable(any(), any(), any(), any())
        } returns Response.error(404, "".toResponseBody("application/json".toMediaTypeOrNull()))

        assertTrue(client.fetchHSRSchedule("0990", "1070", "2026-05-09").isEmpty())
    }

    @Test
    fun `fetchHSRSchedule throws on non-2xx non-404 errors`() = runBlocking {
        coEvery {
            service.getHSRDailyTimetable(any(), any(), any(), any())
        } returns Response.error(500, "".toResponseBody("application/json".toMediaTypeOrNull()))

        try {
            client.fetchHSRSchedule("0990", "1070", "2026-05-09")
            fail("expected exception")
        } catch (e: IllegalStateException) {
            assertTrue(e.message!!.contains("500"))
        }
    }

    @Test
    fun `fetchHSRSchedule maps fields and falls back to standard type`() = runBlocking {
        coEvery {
            service.getHSRDailyTimetable(any(), any(), any(), any())
        } returns Response.success(listOf(
            TdxThsrItem(
                dailyTrainInfo = TdxThsrDailyTrainInfo(trainNo = "1234", trainTypeName = null),
                originStopTime = TdxThsrStopTime("09:00:00", ""),
                destinationStopTime = TdxThsrStopTime("", "10:30:00"),
            )
        ))

        val result = client.fetchHSRSchedule("0990", "1070", "2026-05-09")

        assertEquals(1, result.size)
        assertEquals("09:00", result[0].dep)
        assertEquals("10:30", result[0].arr)
        assertEquals("標準", result[0].type)
        assertEquals("#1234", result[0].num)
    }

    // Regression guard: TDX v2 THSR DailyTimetable OD API nests TrainNo and
    // TrainTypeName inside `DailyTrainInfo` (not at the top level). Reading
    // the top-level keys would render trains as "#null" / "null" — same bug
    // Flutter side fixed in commit 4545b13.
    @Test
    fun `fetchHSRSchedule reads TrainNo and TrainTypeName from nested DailyTrainInfo`() = runBlocking {
        coEvery {
            service.getHSRDailyTimetable(any(), any(), any(), any())
        } returns Response.success(listOf(
            TdxThsrItem(
                dailyTrainInfo = TdxThsrDailyTrainInfo(
                    trainNo = "0617",
                    trainTypeName = TdxMultilingualName("標準"),
                ),
                originStopTime = TdxThsrStopTime("16:20:00", ""),
                destinationStopTime = TdxThsrStopTime("", "16:28:00"),
            )
        ))

        val result = client.fetchHSRSchedule("0990", "1000", "2026-05-09")

        assertEquals(1, result.size)
        assertEquals("#0617", result[0].num)   // must NOT be "#null"
        assertEquals("標準", result[0].type)    // must NOT be "null"
    }

    // Gson schema check: simulates what happens if a real API response only
    // has top-level TrainNo (e.g., if TDX ever flattens) — the DTO must NOT
    // crash, and the train should fall through to empty-num / 標準 fallback.
    @Test
    fun `fetchHSRSchedule survives missing DailyTrainInfo with sensible fallbacks`() = runBlocking {
        coEvery {
            service.getHSRDailyTimetable(any(), any(), any(), any())
        } returns Response.success(listOf(
            TdxThsrItem(
                dailyTrainInfo = null,
                originStopTime = TdxThsrStopTime("16:35:00", ""),
                destinationStopTime = TdxThsrStopTime("", "16:43:00"),
            )
        ))

        val result = client.fetchHSRSchedule("0990", "1000", "2026-05-09")

        assertEquals(1, result.size)
        assertEquals("#", result[0].num)       // empty trainNo, never "#null"
        assertEquals("標準", result[0].type)
    }
}
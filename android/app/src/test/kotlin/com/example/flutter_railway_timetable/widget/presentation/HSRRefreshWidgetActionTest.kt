package com.example.flutter_railway_timetable.widget.presentation

import android.content.Context
import com.example.flutter_railway_timetable.widget.data.auth.WidgetAuthException
import com.example.flutter_railway_timetable.widget.data.prefs.WidgetPrefsHSR
import com.example.flutter_railway_timetable.widget.data.prefs.WidgetPrefsTR
import com.example.flutter_railway_timetable.widget.domain.entity.WidgetRoute
import com.example.flutter_railway_timetable.widget.domain.entity.WidgetSchedule
import com.example.flutter_railway_timetable.widget.domain.usecase.GetNextTrainsUseCase
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.every
import io.mockk.just
import io.mockk.mockk
import io.mockk.mockkObject
import io.mockk.Runs
import io.mockk.unmockkAll
import io.mockk.verify
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Before
import org.junit.Test

class HSRRefreshWidgetActionTest {

    private val context = mockk<Context>(relaxed = true)
    private val useCase = mockk<GetNextTrainsUseCase>()
    private val hsrRoute = WidgetRoute("臺北", "1000", "左營", "1070", "HSR")

    @Before
    fun setup() {
        mockkObject(WidgetPrefsHSR)
        mockkObject(WidgetPrefsTR)
        every { WidgetPrefsHSR.saveRefreshResult(any(), any(), any(), any()) } just Runs
        every { WidgetPrefsHSR.saveRefreshError(any(), any()) } just Runs
    }

    @After
    fun teardown() {
        unmockkAll()
    }

    @Test
    fun `successful fetch calls useCase with HSR system`() = runBlocking {
        val schedules = listOf(WidgetSchedule("10:00", "11:30", "標準", "#617"))
        coEvery { useCase.execute(any(), any(), any(), eq("HSR"), any()) } returns schedules

        HSRRefreshWidgetAction.executeWith(context, hsrRoute, useCase)

        coVerify(exactly = 1) { useCase.execute(eq("1000"), eq("1070"), any(), eq("HSR"), any()) }
        // Critical: HSR refresh must NOT trigger TR system path.
        coVerify(exactly = 0) { useCase.execute(any(), any(), any(), eq("TR"), any()) }
    }

    @Test
    fun `successful fetch writes hsr_widget refresh result`() = runBlocking {
        val schedules = listOf(WidgetSchedule("10:00", "11:30", "標準", "#617"))
        coEvery { useCase.execute(any(), any(), any(), eq("HSR"), any()) } returns schedules

        HSRRefreshWidgetAction.executeWith(context, hsrRoute, useCase)

        verify { WidgetPrefsHSR.saveRefreshResult(context, hsrRoute, schedules, any()) }
    }

    @Test
    fun `WidgetAuthException writes refresh error so empty-state error renders`() = runBlocking {
        coEvery { useCase.execute(any(), any(), any(), eq("HSR"), any()) } throws WidgetAuthException("ERR_NO_CREDENTIALS")

        HSRRefreshWidgetAction.executeWith(context, hsrRoute, useCase)

        // saveRefreshError batches "clear schedules" + "set lastError" in a single
        // SharedPreferences edit() — verifies both side effects via one verify.
        verify { WidgetPrefsHSR.saveRefreshError(context, "ERR_NO_CREDENTIALS") }
    }

    @Test
    fun `generic Exception writes refresh error`() = runBlocking {
        coEvery { useCase.execute(any(), any(), any(), eq("HSR"), any()) } throws RuntimeException("network down")

        HSRRefreshWidgetAction.executeWith(context, hsrRoute, useCase)

        verify { WidgetPrefsHSR.saveRefreshError(context, "查詢失敗，請稍後再試") }
    }

    @Test
    fun `never writes through TR namespace regardless of outcome`() = runBlocking {
        coEvery { useCase.execute(any(), any(), any(), eq("HSR"), any()) } returns emptyList()

        HSRRefreshWidgetAction.executeWith(context, hsrRoute, useCase)

        verify(exactly = 0) { WidgetPrefsTR.saveRefreshResult(any(), any(), any(), any()) }
        verify(exactly = 0) { WidgetPrefsTR.saveRefreshError(any(), any()) }
        verify(exactly = 0) { WidgetPrefsTR.saveRoute(any(), any()) }
        verify(exactly = 0) { WidgetPrefsTR.saveSchedules(any(), any()) }
    }

    @Test
    fun `resolveRoute returns saved route when available`() = runBlocking {
        every { WidgetPrefsHSR.loadRoute(context) } returns hsrRoute

        val resolved = HSRRefreshWidgetAction.resolveRoute(context)

        assert(resolved == hsrRoute)
    }

    // Regression guard: when no saved HSR route exists, fallback MUST be the
    // canonical 臺北 → 左營 (design.md Decision 5), NOT the first two picker
    // stations (which would be 南港 → 臺北 since HSR picker is fixed N→S).
    @Test
    fun `resolveRoute falls back to default when prefs are empty`() = runBlocking {
        every { WidgetPrefsHSR.loadRoute(context) } returns null

        val resolved = HSRRefreshWidgetAction.resolveRoute(context)

        assert(resolved.system == "HSR")
        assert(resolved.fromName == "臺北") { "expected 臺北, got ${resolved.fromName}" }
        assert(resolved.toName == "左營") { "expected 左營, got ${resolved.toName}" }
    }
}

import Testing
import Foundation

@Suite("TaipeiClock — HH:mm formatting in Asia/Taipei")
struct TaipeiClockTests {

    @Test("nowTime formats midnight UTC as 08:00 Taipei time")
    func nowTime_midnightUtc_isEightAmTaipei() {
        // 2026-01-15T00:00:00Z = 2026-01-15T08:00:00+08:00
        let date = Date(timeIntervalSince1970: 1768435200)
        #expect(TaipeiClock.nowTime(date) == "08:00")
    }

    @Test("nowTime formats 17:30 Taipei correctly")
    func nowTime_eveningTaipei_isFormattedHHmm() {
        // 2026-01-15T09:30:00Z = 2026-01-15T17:30:00+08:00
        let date = Date(timeIntervalSince1970: 1768469400)
        #expect(TaipeiClock.nowTime(date) == "17:30")
    }

    @Test("nowTime crosses day boundary correctly (UTC late evening = Taipei next-day morning)")
    func nowTime_crossesDayBoundary() {
        // 2026-01-15T23:00:00Z = 2026-01-16T07:00:00+08:00
        let date = Date(timeIntervalSince1970: 1768518000)
        #expect(TaipeiClock.nowTime(date) == "07:00")
    }

    @Test("nowTime uses zero-padded 24-hour format, not locale-specific AM/PM")
    func nowTime_uses24HourPaddedFormat() {
        // 2026-01-15T00:05:00Z = 2026-01-15T08:05:00+08:00 → "08:05" not "8:05 AM"
        let date = Date(timeIntervalSince1970: 1768435500)
        let result = TaipeiClock.nowTime(date)
        #expect(result == "08:05")
        #expect(!result.contains("AM"))
        #expect(!result.contains("PM"))
    }

    @Test("todayDate formats midnight UTC as Taipei calendar date (same day morning)")
    func todayDate_midnightUtc_isSameDateInTaipei() {
        // 2026-01-15T00:00:00Z = 2026-01-15T08:00:00+08:00
        let date = Date(timeIntervalSince1970: 1768435200)
        #expect(TaipeiClock.todayDate(date) == "2026-01-15")
    }

    @Test("todayDate flips to next day when UTC is late evening (Taipei is past midnight)")
    func todayDate_crossesDayBoundary_returnsTaipeiCalendarDay() {
        // 2026-01-15T17:00:00Z = 2026-01-16T01:00:00+08:00 → "2026-01-16"
        let date = Date(timeIntervalSince1970: 1768496400)
        #expect(TaipeiClock.todayDate(date) == "2026-01-16")
    }
}

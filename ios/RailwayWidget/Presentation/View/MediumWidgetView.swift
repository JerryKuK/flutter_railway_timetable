import SwiftUI
import WidgetKit
import AppIntents

// MARK: - Palette
struct RailwayPalette {
    let gradTop: Color
    let gradBottom: Color
    let accent: Color
    let name: String

    static func of(_ system: RailwaySystem) -> RailwayPalette {
        switch system {
        case .tr:
            return RailwayPalette(gradTop: Color(hex: "#5FA6E0"), gradBottom: Color(hex: "#2E72B8"),
                                  accent: Color(hex: "#2E72B8"), name: "台鐵")
        case .hsr:
            return RailwayPalette(gradTop: Color(hex: "#F2A85C"), gradBottom: Color(hex: "#C86820"),
                                  accent: Color(hex: "#C86820"), name: "高鐵")
        }
    }

    var gradient: LinearGradient {
        LinearGradient(colors: [gradTop, gradBottom], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

// MARK: - Picker grid layout per system
private struct PickerLayout {
    let chipCount: Int
    let columnCount: Int
    let chipSpacing: CGFloat

    static func of(_ system: RailwaySystem) -> PickerLayout {
        switch system {
        case .tr:  return PickerLayout(chipCount: 10, columnCount: 5, chipSpacing: 5)
        case .hsr: return PickerLayout(chipCount: 12, columnCount: 6, chipSpacing: 4)
        }
    }
}

// MARK: - Main View
// Renders both 台鐵 and 高鐵 4×2 widgets. Differences between systems are limited to
// the AppIntent type each button fires (intents must be statically-typed per widget
// kind so iOS can route them) and the picker grid sizing — both are dispatched on
// `entry.route.system`.
struct MediumWidgetView: View {
    let entry: RailwayWidgetEntry

    var body: some View {
        let pal = RailwayPalette.of(entry.route.system)
        Group {
            if entry.pickerMode != "none" {
                pickerView(pal: pal)
            } else {
                scheduleView(pal: pal)
            }
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Schedule View (home state)
    private func scheduleView(pal: RailwayPalette) -> some View {
        VStack(spacing: 0) {
            // Header — left group grows, right group is fixed size
            HStack(spacing: 0) {
                // Left: system icon + name + route
                HStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(pal.gradient)
                            .frame(width: 22, height: 22)
                        Image(systemName: "tram.fill")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    Text(pal.name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)
                    Text("·")
                        .font(.system(size: 11))
                        .foregroundColor(Color(.systemGray3))
                    showPickerButton(mode: "from", stationName: entry.route.fromName, pal: pal)
                    Text("→")
                        .font(.system(size: 11))
                        .foregroundColor(Color(.systemGray2))
                    showPickerButton(mode: "to", stationName: entry.route.toName, pal: pal)
                }
                .lineLimit(1)

                Spacer(minLength: 6)

                // Right: date + query button — fixedSize prevents compression
                HStack(spacing: 6) {
                    Text(dateString)
                        .font(.system(size: 10))
                        .foregroundColor(Color(.systemGray3))
                    refreshButton(pal: pal)
                }
                .fixedSize()
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 8)

            divider

            // Train rows
            if entry.schedules.isEmpty {
                if let err = entry.lastError {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 11))
                            .foregroundColor(pal.accent)
                        Text(err)
                            .font(.system(size: 10))
                            .foregroundColor(Color(.systemGray))
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                            .foregroundColor(Color(.systemGray3))
                        Text("點右上角查詢取得班次")
                            .font(.system(size: 11))
                            .foregroundColor(Color(.systemGray2))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                }
            } else {
                let rows = entry.schedules.prefix(2)
                ForEach(Array(rows.enumerated()), id: \.offset) { idx, s in
                    trainRow(s: s, pal: pal)
                    if idx == 0 { divider }
                }
            }

            Spacer(minLength: 0)

            // Footer
            HStack {
                Text("更新於 \(entry.date, formatter: MediumWidgetView.timeFormatter)")
                    .font(.system(size: 10))
                    .foregroundColor(Color(.systemGray3))
                Spacer()
                Text("查看更多 →")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(pal.accent)
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 10)
        }
    }

    private func trainRow(s: TrainSchedule, pal: RailwayPalette) -> some View {
        HStack(spacing: 10) {
            Text(s.departureTime)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .frame(width: 60, alignment: .leading)
                .foregroundColor(.primary)

            Text(s.trainType)
                .font(.system(size: 10))
                .foregroundColor(Color(.systemGray))
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .background(Color(.systemGray6))
                .cornerRadius(8)

            Text(s.trainNumber)
                .font(.system(size: 11))
                .foregroundColor(Color(.systemGray))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(s.arrivalTime)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
    }

    // MARK: - Picker View (inline station selection, same 4×2 size)
    private func pickerView(pal: RailwayPalette) -> some View {
        let isFrom = entry.pickerMode == "from"
        let layout = PickerLayout.of(entry.route.system)
        let stations = Array(entry.pickerStations.prefix(layout.chipCount))
        let other = isFrom ? entry.route.toName : entry.route.fromName

        return VStack(spacing: 0) {
            // Header
            HStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(pal.gradient)
                        .frame(width: 22, height: 22)
                    Image(systemName: "tram.fill")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text("選擇\(isFrom ? "出發" : "到達")站")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.primary)
                    Text("\(pal.name) · 點選下方車站")
                        .font(.system(size: 9.5))
                        .foregroundColor(Color(.systemGray))
                }
                Spacer()
                dismissPickerButton
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)
            .padding(.bottom, 6)

            // Chips grid (5×2 for TR, 6×2 for HSR)
            let columns = Array(
                repeating: GridItem(.flexible(), spacing: layout.chipSpacing),
                count: layout.columnCount
            )
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(stations, id: \.name) { station in
                    let isSelected = (isFrom ? entry.route.fromName : entry.route.toName) == station.name
                    selectStationButton(station: station, isSelected: isSelected, pal: pal)
                }
            }
            .padding(.horizontal, 10)

            Spacer(minLength: 0)

            // Footer
            divider
            HStack(spacing: 4) {
                Text(isFrom ? "到達" : "出發")
                    .font(.system(size: 10))
                    .foregroundColor(Color(.systemGray))
                Text(other)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
        }
    }

    // MARK: - Intent-dispatch buttons
    // AppIntent types must be statically known per widget kind (iOS routes by type),
    // so we branch on `entry.route.system` here rather than passing intent factories.

    @ViewBuilder
    private func showPickerButton(mode: String, stationName: String, pal: RailwayPalette) -> some View {
        let label = Text(stationName)
            .font(.system(size: 11))
            .foregroundStyle(pal.accent)
            .underline(true, color: pal.accent)
        switch entry.route.system {
        case .tr:
            Button(intent: ShowPickerIntent(mode: mode)) { label }.buttonStyle(.plain)
        case .hsr:
            Button(intent: HSRShowPickerIntent(mode: mode)) { label }.buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private func refreshButton(pal: RailwayPalette) -> some View {
        let label = Label("查詢", systemImage: "magnifyingglass")
            .font(.system(size: 10.5, weight: .bold))
            .foregroundStyle(pal.accent)
            .padding(.horizontal, 9)
            .frame(height: 22)
            .background(pal.accent.opacity(0.1))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(pal.accent.opacity(0.2), lineWidth: 1))
        switch entry.route.system {
        case .tr:
            Button(intent: RefreshTimetableIntent()) { label }.buttonStyle(.plain)
        case .hsr:
            Button(intent: HSRRefreshTimetableIntent()) { label }.buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var dismissPickerButton: some View {
        let label = ZStack {
            Circle()
                .fill(Color(.systemGray5))
                .frame(width: 22, height: 22)
            Image(systemName: "xmark")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(Color(.systemGray))
        }
        switch entry.route.system {
        case .tr:
            Button(intent: DismissPickerIntent()) { label }.buttonStyle(.plain)
        case .hsr:
            Button(intent: HSRDismissPickerIntent()) { label }.buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private func selectStationButton(station: PickerStation, isSelected: Bool, pal: RailwayPalette) -> some View {
        let label = Text(station.name)
            .font(.system(size: 10.5, weight: isSelected ? .semibold : .regular))
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .background(isSelected ? pal.accent : Color(.systemGray6))
            .clipShape(Capsule())
        switch entry.route.system {
        case .tr:
            Button(intent: SelectStationIntent(stationName: station.name, stationId: station.stationId)) { label }
                .buttonStyle(.plain)
        case .hsr:
            Button(intent: HSRSelectStationIntent(stationName: station.name, stationId: station.stationId)) { label }
                .buttonStyle(.plain)
        }
    }

    // MARK: - Helpers
    private var divider: some View {
        Rectangle()
            .fill(Color(.systemGray6))
            .frame(height: 1)
            .padding(.horizontal, 14)
    }

    private var dateString: String {
        let f = DateFormatter()
        f.dateFormat = "M/d EEE"
        f.locale = Locale(identifier: "zh_TW")
        return f.string(from: entry.date)
    }

    static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()
}

// MARK: - Color hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        self.init(
            red: Double((int >> 16) & 0xFF) / 255,
            green: Double((int >> 8) & 0xFF) / 255,
            blue: Double(int & 0xFF) / 255
        )
    }
}
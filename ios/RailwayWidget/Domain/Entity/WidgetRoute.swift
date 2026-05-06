import Foundation

enum RailwaySystem: String, Codable {
    case tr = "TR"
    case hsr = "HSR"

    var displayName: String {
        switch self {
        case .tr: return "台鐵"
        case .hsr: return "高鐵"
        }
    }

    var accentColor: String {
        switch self {
        case .tr: return "#2E72B8"
        case .hsr: return "#C86820"
        }
    }
}

struct WidgetRoute: Codable, Equatable {
    let system: RailwaySystem
    let fromId: String
    let fromName: String
    let toId: String
    let toName: String
}

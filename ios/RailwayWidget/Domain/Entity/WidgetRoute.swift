import Foundation

enum RailwaySystem: String, Codable {
    case tr = "TR"
    case hsr = "HSR"

    var prefix: String {
        switch self {
        case .tr: return "tr"
        case .hsr: return "hsr"
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

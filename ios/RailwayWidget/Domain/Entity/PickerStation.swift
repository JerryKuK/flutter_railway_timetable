import Foundation

struct PickerStation: Equatable {
    let name: String
    let stationId: String
    let system: String   // "TR" or "HSR"
    let sortOrder: Int
}

enum PickerStationDefaults {
    private static let tr: [(String, String)] = [
        ("臺北", "1000"), ("板橋", "1020"), ("桃園", "1080"), ("新竹", "1210"),
        ("臺中", "3300"), ("臺南", "4220"), ("高雄", "4400"), ("花蓮", "7000"),
        ("臺東", "6000"), ("基隆", "0900"),
    ]

    // Full 12 HSR stations in north-to-south order. Must match
    // _hsrDefaults in widget_station_repository_impl.dart exactly.
    private static let hsr: [(String, String)] = [
        ("南港", "0990"), ("臺北", "1000"), ("板橋", "1010"), ("桃園", "1020"),
        ("新竹", "1030"), ("苗栗", "1035"), ("臺中", "1040"), ("彰化", "1043"),
        ("雲林", "1047"), ("嘉義", "1050"), ("臺南", "1060"), ("左營", "1070"),
    ]

    static func stations(for system: String) -> [PickerStation] {
        let pairs = system == "TR" ? tr : hsr
        return pairs.enumerated().map { i, pair in
            PickerStation(name: pair.0, stationId: pair.1, system: system, sortOrder: i)
        }
    }
}

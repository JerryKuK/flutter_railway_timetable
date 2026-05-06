import Foundation

struct TrainSchedule: Equatable {
    let departureTime: String  // HH:mm
    let arrivalTime: String    // HH:mm
    let trainType: String
    let trainNumber: String
    let fare: Int              // NT$, 0 if unavailable
}

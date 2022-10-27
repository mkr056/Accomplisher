import Foundation

extension Date {
    var dayFormat: String {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateStyle = .long
        formatter.locale = .current
        return formatter.string(from: self)
    }
}

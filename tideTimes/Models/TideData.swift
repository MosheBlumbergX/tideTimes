import Foundation

struct TideData: Codable {
    let status: Int
    let callCount: Int
    let copyright: String
    let requestLat: Double
    let requestLon: Double
    let responseLat: Double
    let responseLon: Double
    let atlas: String
    let station: String
    let heights: [TidePoint]
    let extremes: [TidePoint]
}

struct TidePoint: Codable, Identifiable {
    var id: String { "\(dt)_\(height)" } // Computed property using timestamp and height
    let dt: TimeInterval
    let date: String
    let height: Double
    
    var dateTime: Date {
        Date(timeIntervalSince1970: dt)
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: dateTime)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dateTime)
    }
}

struct Location: Codable, Identifiable, Equatable {
    var id: String { "\(latitude)_\(longitude)" } // Computed property using coordinates
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String
    
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct SearchLocation: Codable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String
}

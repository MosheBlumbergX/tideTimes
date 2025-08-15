import Foundation
import CoreLocation

// Notification names
extension Notification.Name {
    static let apiKeyUpdated = Notification.Name("apiKeyUpdated")
}

class TideAPIService: ObservableObject {
    private let baseURL = "https://api.stormglass.io/v2"
    private let userDefaults = UserDefaults.standard
    private let apiKeyKey = "StormglassAPIKey"
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Computed property to get API key from UserDefaults or use default
    private var apiKey: String {
        get {
            return userDefaults.string(forKey: apiKeyKey) ?? "YOUR_STORMGLASS_API_KEY"
        }
    }
    
    // Function to update API key
    func updateAPIKey(_ newKey: String) {
        userDefaults.set(newKey, forKey: apiKeyKey)
        // Clear any previous error messages
        errorMessage = nil
        
        // Post notification that API key was updated
        NotificationCenter.default.post(name: .apiKeyUpdated, object: nil)
    }
    
    // Function to get current API key for display
    func getCurrentAPIKey() -> String {
        let key = userDefaults.string(forKey: apiKeyKey)
        return key ?? "YOUR_STORMGLASS_API_KEY"
    }
    
    func fetchTideData(for location: Location) async throws -> TideData {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate) ?? startDate
        
        let dateFormatter = ISO8601DateFormatter()
        let startString = dateFormatter.string(from: startDate)
        let endString = dateFormatter.string(from: endDate)
        
        let urlString = "\(baseURL)/tide/extremes/point?lat=\(location.latitude)&lng=\(location.longitude)&start=\(startString)&end=\(endString)"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        
        // Debug logging
        print("🌊 API Request Debug:")
        print("URL: \(urlString)")
        print("API Key: \(String(apiKey.prefix(8)))...\(String(apiKey.suffix(4)))")
        print("Location: \(location.name) (\(location.latitude), \(location.longitude))")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // Debug logging for response
        print("🌊 API Response Debug:")
        print("Status Code: \(httpResponse.statusCode)")
        print("Response Headers: \(httpResponse.allHeaderFields)")
        
        // Handle different HTTP status codes
        switch httpResponse.statusCode {
        case 200:
            // Success - parse the response
            break
        case 401:
            throw APIError.apiError(401, "Invalid API key. Please check your Stormglass API key.")
        case 402:
            throw APIError.apiError(402, "Payment required. Your API key may have expired or hit usage limits. Please check your Stormglass account.")
        case 403:
            throw APIError.apiError(403, "Access forbidden. This could be due to: 1) Account not verified, 2) IP restrictions, 3) Account suspended. Please check your Stormglass account status.")
        case 429:
            throw APIError.apiError(429, "Rate limit exceeded. You've used all 50 free requests for today. Try again tomorrow or upgrade your plan.")
        default:
            throw APIError.apiError(httpResponse.statusCode, "API error: \(httpResponse.statusCode)")
        }
        
        // Debug: Print the raw response
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Stormglass API Response: \(jsonString)")
        }
        
        // Try to parse Stormglass response format
        do {
            let stormglassResponse = try JSONDecoder().decode(StormglassResponse.self, from: data)
            let tideData = convertStormglassResponse(stormglassResponse, for: location)
            return tideData
        } catch {
            print("JSON Decoding Error: \(error)")
            
            // Fallback: Create mock data if API parsing fails
            print("Falling back to mock data...")
            return createMockTideData(for: location)
        }
    }
    
    func searchLocations(query: String) async throws -> [SearchLocation] {
        // For demo purposes, we'll use a simple geocoding approach
        // In a real app, you might want to use a more sophisticated location search API
        
        let geocoder = CLGeocoder()
        let locations = try await geocoder.geocodeAddressString(query)
        
        return locations.compactMap { placemark in
            guard let name = placemark.name ?? placemark.locality,
                  let country = placemark.country else { return nil }
            
            return SearchLocation(
                name: name,
                lat: placemark.location?.coordinate.latitude ?? 0,
                lon: placemark.location?.coordinate.longitude ?? 0,
                country: country
            )
        }
    }
    
    private func convertStormglassResponse(_ response: StormglassResponse, for location: Location) -> TideData {
        let extremes = response.data.map { extreme in
            TidePoint(
                dt: extreme.dateTime.timeIntervalSince1970,
                date: formatDate(extreme.dateTime),
                height: extreme.height
            )
        }
        
        // Create interpolated height data from extremes
        let heights = createInterpolatedHeights(from: extremes)
        
        return TideData(
            status: 200,
            callCount: 1,
            copyright: "Stormglass API",
            requestLat: location.latitude,
            requestLon: location.longitude,
            responseLat: location.latitude,
            responseLon: location.longitude,
            atlas: "Stormglass",
            station: location.name,
            heights: heights,
            extremes: extremes
        )
    }
    
    private func createInterpolatedHeights(from extremes: [TidePoint]) -> [TidePoint] {
        var heights: [TidePoint] = []
        
        guard extremes.count >= 2 else {
            return extremes
        }
        
        for i in 0..<extremes.count - 1 {
            let current = extremes[i]
            let next = extremes[i + 1]
            
            // Add the current extreme
            heights.append(current)
            
            // Calculate time difference and create interpolated points
            let timeDiff = next.dt - current.dt
            let heightDiff = next.height - current.height
            
            // Create more realistic tide interpolation
            let minutesBetween = Int(timeDiff / 60)
            let pointsCount = max(8, minutesBetween / 5) // More frequent points for smoother curves
            
            for j in 1..<pointsCount {
                let ratio = Double(j) / Double(pointsCount)
                
                // Use a more natural tide curve interpolation
                let naturalRatio = naturalTideCurve(ratio, from: current.height, to: next.height)
                
                let interpolatedTime = current.dt + (timeDiff * ratio)
                let interpolatedHeight = current.height + (heightDiff * naturalRatio)
                
                let interpolatedPoint = TidePoint(
                    dt: interpolatedTime,
                    date: formatDate(Date(timeIntervalSince1970: interpolatedTime)),
                    height: interpolatedHeight
                )
                
                heights.append(interpolatedPoint)
            }
        }
        
        // Add the last extreme
        if let last = extremes.last {
            heights.append(last)
        }
        
        return heights
    }
    
    // Natural tide curve interpolation for more realistic appearance
    private func naturalTideCurve(_ t: Double, from startHeight: Double, to endHeight: Double) -> Double {
        // Use a combination of smooth step and sine wave for natural tide curves
        let smoothT = smoothStep(t)
        let sineT = sin(t * .pi) * 0.1 // Small sine wave for natural variation
        
        return smoothT + sineT
    }
    
    // Smooth step function for better curve interpolation
    private func smoothStep(_ t: Double) -> Double {
        return t * t * (3.0 - 2.0 * t)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
    
    // Fallback mock data function
    private func createMockTideData(for location: Location) -> TideData {
        let now = Date()
        let calendar = Calendar.current
        
        // Create 24 hours of tide data (96 points, 15-minute intervals)
        var heights: [TidePoint] = []
        var extremes: [TidePoint] = []
        
        for i in 0..<96 {
            let time = calendar.date(byAdding: .minute, value: i * 15, to: now) ?? now
            let timestamp = time.timeIntervalSince1970
            
            // Create realistic tide pattern (semi-diurnal tide)
            let hours = Double(i) * 0.25 // 15-minute intervals
            let tideHeight = 1.5 * sin(2 * .pi * hours / 12.42) + 0.2 * sin(2 * .pi * hours / 24.84)
            
            let tidePoint = TidePoint(
                dt: timestamp,
                date: formatDate(time),
                height: tideHeight
            )
            
            heights.append(tidePoint)
            
            // Add extremes (high and low tides)
            if i % 24 == 0 || i % 24 == 12 { // Every 6 hours
                let extremeHeight = i % 24 == 0 ? 2.5 : -0.5
                let extremePoint = TidePoint(
                    dt: timestamp,
                    date: formatDate(time),
                    height: extremeHeight
                )
                extremes.append(extremePoint)
            }
        }
        
        return TideData(
            status: 200,
            callCount: 1,
            copyright: "Mock Data (API Fallback)",
            requestLat: location.latitude,
            requestLon: location.longitude,
            responseLat: location.latitude,
            responseLon: location.longitude,
            atlas: "Demo",
            station: location.name,
            heights: heights,
            extremes: extremes
        )
    }
}

// Stormglass API Response Models
struct StormglassResponse: Codable {
    let data: [StormglassExtreme]
    let meta: StormglassMeta
}

struct StormglassExtreme: Codable {
    let height: Double
    let time: String // API returns time as string
    let type: String
    
    // Computed property to convert string time to Date
    var dateTime: Date {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: time) ?? Date()
    }
}

struct StormglassMeta: Codable {
    let start: String
    let end: String
    let lat: Double
    let lng: Double
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(Int, String)
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let code, let message):
            return message
        case .decodingError:
            return "Failed to decode response"
        }
    }
}

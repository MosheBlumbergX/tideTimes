import Foundation
import Combine

@MainActor
class TideViewModel: ObservableObject {
    @Published var tideData: TideData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentTideHeight: Double?
    @Published var nextHighTide: TidePoint?
    @Published var nextLowTide: TidePoint?
    
    let apiService: TideAPIService
    private let locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()
    
    init(locationManager: LocationManager) {
        self.apiService = TideAPIService()
        self.locationManager = locationManager
        
        // Observe location changes and fetch tide data
        locationManager.$currentLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                Task {
                    await self?.fetchTideData(for: location)
                }
            }
            .store(in: &cancellables)
        
        // Listen for API key updates and refresh data
        NotificationCenter.default.addObserver(
            forName: .apiKeyUpdated,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            if let location = self?.locationManager.currentLocation {
                Task {
                    await self?.fetchTideData(for: location)
                }
            }
        }
    }
    
    func fetchTideData(for location: Location) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let data = try await apiService.fetchTideData(for: location)
            tideData = data
            updateCurrentTideInfo()
        } catch {
            errorMessage = error.localizedDescription
            // Clear old data when there's an error
            tideData = nil
            currentTideHeight = nil
            nextHighTide = nil
            nextLowTide = nil
        }
        
        isLoading = false
    }
    
    private func updateCurrentTideInfo() {
        guard let data = tideData else { return }
        
        let now = Date()
        let currentTime = now.timeIntervalSince1970
        
        // Find current tide height
        if let currentHeight = data.heights.first(where: { $0.dt >= currentTime }) {
            currentTideHeight = currentHeight.height
        }
        
        // Find next high and low tides
        nextHighTide = data.extremes
            .filter { $0.dt > currentTime }
            .first { $0.height > 0 } // Assuming positive values are high tides
        
        nextLowTide = data.extremes
            .filter { $0.dt > currentTime }
            .first { $0.height < 0 } // Assuming negative values are low tides
    }
    
    func get24HourTideData() -> [TidePoint] {
        guard let data = tideData else { return [] }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? now
        
        return data.heights.filter { tidePoint in
            tidePoint.dateTime >= startOfDay && tidePoint.dateTime < endOfDay
        }
    }
    
    func getExtremesFor24Hours() -> [TidePoint] {
        guard let data = tideData else { return [] }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? now
        
        return data.extremes.filter { tidePoint in
            tidePoint.dateTime >= startOfDay && tidePoint.dateTime < endOfDay
        }
    }
}

import Foundation
import CoreLocation

class LocationManager: ObservableObject {
    @Published var savedLocations: [Location] = []
    @Published var currentLocation: Location?
    @Published var searchResults: [SearchLocation] = []
    @Published var isSearching = false
    
    private let userDefaults = UserDefaults.standard
    private let locationsKey = "savedLocations"
    private let currentLocationKey = "currentLocation"
    
    init() {
        loadSavedLocations()
        loadCurrentLocation()
    }
    
    func addLocation(_ location: Location) {
        // Check if location already exists
        if !savedLocations.contains(where: { $0.latitude == location.latitude && $0.longitude == location.longitude }) {
            savedLocations.append(location)
            saveToUserDefaults()
        }
        
        // Set as current location if it's the first one
        if currentLocation == nil {
            setCurrentLocation(location)
        }
    }
    
    func setCurrentLocation(_ location: Location) {
        currentLocation = location
        saveCurrentLocationToUserDefaults()
    }
    
    func removeLocation(_ location: Location) {
        savedLocations.removeAll { $0.id == location.id }
        
        // If we're removing the current location, set a new one
        if currentLocation?.id == location.id {
            currentLocation = savedLocations.first
            saveCurrentLocationToUserDefaults()
        }
        
        saveToUserDefaults()
    }
    
    func clearAllLocations() {
        savedLocations.removeAll()
        currentLocation = nil
        userDefaults.removeObject(forKey: locationsKey)
        userDefaults.removeObject(forKey: currentLocationKey)
    }
    
    private func loadSavedLocations() {
        if let data = userDefaults.data(forKey: locationsKey),
           let locations = try? JSONDecoder().decode([Location].self, from: data) {
            savedLocations = locations
        }
    }
    
    private func loadCurrentLocation() {
        if let data = userDefaults.data(forKey: currentLocationKey),
           let location = try? JSONDecoder().decode(Location.self, from: data) {
            currentLocation = location
        }
    }
    
    private func saveToUserDefaults() {
        if let data = try? JSONEncoder().encode(savedLocations) {
            userDefaults.set(data, forKey: locationsKey)
        }
    }
    
    private func saveCurrentLocationToUserDefaults() {
        if let location = currentLocation,
           let data = try? JSONEncoder().encode(location) {
            userDefaults.set(data, forKey: currentLocationKey)
        }
    }
}

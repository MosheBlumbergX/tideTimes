import SwiftUI

struct LocationSearchView: View {
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var tideViewModel: TideViewModel
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var searchResults: [SearchLocation] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.seaside.secondaryText)
                    
                    TextField("Search for a location...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onChange(of: searchText) { oldValue, newValue in
                            Task {
                                await searchLocations(query: newValue)
                            }
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            searchResults = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.seaside.secondaryText)
                        }
                    }
                }
                .padding()
                .background(Color.seaside.secondaryBackground)
                .cornerRadius(12)
                .padding(.horizontal)
                
                if isSearching {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.seaside.oceanBlue)
                        Text("Searching...")
                            .font(.subheadline)
                            .foregroundColor(.seaside.secondaryText)
                    }
                    .padding()
                }
                
                // Saved locations section
                if !locationManager.savedLocations.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Saved Locations")
                                .font(.headline)
                                .foregroundColor(.seaside.primaryText)
                            
                            Spacer()
                            
                            Button("Clear All") {
                                locationManager.clearAllLocations()
                            }
                            .font(.caption)
                            .foregroundColor(.seaside.error)
                        }
                        .padding(.horizontal)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(locationManager.savedLocations) { location in
                                SavedLocationRow(
                                    location: location,
                                    isCurrent: locationManager.currentLocation?.id == location.id,
                                    onSelect: {
                                        locationManager.setCurrentLocation(location)
                                    },
                                    onRemove: {
                                        locationManager.removeLocation(location)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Search results
                if !searchResults.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Search Results")
                            .font(.headline)
                            .foregroundColor(.seaside.primaryText)
                            .padding(.horizontal)
                        
                        List(searchResults, id: \.lat) { location in
                            Button(action: {
                                selectLocation(location)
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(location.name)
                                        .font(.headline)
                                        .foregroundColor(.seaside.primaryText)
                                    Text(location.country)
                                        .font(.caption)
                                        .foregroundColor(.seaside.secondaryText)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .scrollContentBackground(.hidden)
                        .background(Color.seaside.mainBackground)
                    }
                } else if searchText.isEmpty && locationManager.savedLocations.isEmpty {
                    // Welcome state when no locations are saved
                    VStack(spacing: 20) {
                        Image(systemName: "location.circle")
                            .font(.system(size: 80))
                            .foregroundColor(.seaside.oceanBlue)
                        
                        Text("Welcome to Tide Times")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.seaside.primaryText)
                        
                        Text("Search for a location to see tide information")
                            .font(.body)
                            .foregroundColor(.seaside.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                Spacer()
            }
            .padding()
        }
        .background(Color.seaside.mainBackground)
        .navigationTitle("Location")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func searchLocations(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        
        do {
            let results = try await TideAPIService().searchLocations(query: query)
            await MainActor.run {
                searchResults = results
                isSearching = false
            }
        } catch {
            await MainActor.run {
                searchResults = []
                isSearching = false
            }
        }
    }
    
    private func selectLocation(_ searchLocation: SearchLocation) {
        let location = Location(
            name: searchLocation.name,
            latitude: searchLocation.lat,
            longitude: searchLocation.lon,
            country: searchLocation.country
        )
        
        locationManager.addLocation(location)
        searchText = ""
        searchResults = []
    }
}

struct SavedLocationRow: View {
    let location: Location
    let isCurrent: Bool
    let onSelect: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(location.name)
                        .font(.headline)
                        .foregroundColor(.seaside.primaryText)
                    
                    if isCurrent {
                        Text("• Current")
                            .font(.caption)
                            .foregroundColor(.seaside.oceanBlue)
                            .fontWeight(.semibold)
                    }
                }
                
                Text(location.country)
                    .font(.caption)
                    .foregroundColor(.seaside.secondaryText)
            }
            
            Spacer()
            
            if !isCurrent {
                Button("Switch") {
                    onSelect()
                }
                .font(.caption)
                .foregroundColor(.seaside.oceanBlue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.seaside.oceanBlue.opacity(0.1))
                .cornerRadius(8)
            }
            
            Button(action: onRemove) {
                Image(systemName: "trash")
                    .foregroundColor(.seaside.error)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color.seaside.secondaryBackground)
        .cornerRadius(12)
    }
}

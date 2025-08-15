import SwiftUI

struct TideInfoView: View {
    @ObservedObject var tideViewModel: TideViewModel
    @ObservedObject var locationManager: LocationManager
    @Binding var selectedTab: Int
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Welcome state when no location is set
                if locationManager.currentLocation == nil {
                    VStack(spacing: 32) {
                        // Welcome icon and title
                        VStack(spacing: 20) {
                            Image(systemName: "water.waves.and.arrow.up")
                                .font(.system(size: 80))
                                .foregroundColor(.seaside.oceanBlue)
                            
                            Text("Welcome to Tide Times")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.seaside.primaryText)
                        }
                        
                        // Welcome message
                        VStack(spacing: 16) {
                            Text("Your personal tide companion")
                                .font(.title2)
                                .foregroundColor(.seaside.secondaryText)
                                .multilineTextAlignment(.center)
                            
                            Text("Get accurate tide predictions for any coastal location around the world")
                                .font(.body)
                                .foregroundColor(.seaside.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        // Call to action
                        VStack(spacing: 12) {
                            Text("To get started:")
                                .font(.headline)
                                .foregroundColor(.seaside.primaryText)
                            
                            HStack(spacing: 20) {
                                VStack(spacing: 8) {
                                    Image(systemName: "location.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.seaside.oceanBlue)
                                    Text("1. Add Location")
                                        .font(.caption)
                                        .foregroundColor(.seaside.secondaryText)
                                }
                                
                                Image(systemName: "arrow.right")
                                    .font(.title2)
                                    .foregroundColor(.seaside.driftwoodGray)
                                
                                VStack(spacing: 8) {
                                    Image(systemName: "water.waves")
                                        .font(.title)
                                        .foregroundColor(.seaside.oceanBlue)
                                    Text("2. View Tides")
                                        .font(.caption)
                                        .foregroundColor(.seaside.secondaryText)
                                }
                            }
                        }
                        .padding()
                        .background(Color.seaside.secondaryBackground)
                        .cornerRadius(16)
                        
                        // Location button
                        Button(action: {
                            selectedTab = 1 // Switch to Location tab
                        }) {
                            HStack {
                                Image(systemName: "location.circle.fill")
                                Text("Add Your First Location")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.seaside.oceanBlue)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    // Existing tide data view when location is set
                    tideDataContent
                }
            }
            .padding()
        }
        .background(Color.seaside.mainBackground)
        .navigationTitle("Tide Times")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // Extracted tide data content for when location is set
    private var tideDataContent: some View {
        VStack(spacing: 24) {
            // Location header with location switcher
            if let location = locationManager.currentLocation {
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(location.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.seaside.primaryText)
                            
                            Text(location.country)
                                .font(.subheadline)
                                .foregroundColor(.seaside.secondaryText)
                        }
                        
                        Spacer()
                        
                        // Enhanced location switcher
                        if locationManager.savedLocations.count > 1 {
                            Menu {
                                ForEach(locationManager.savedLocations) { savedLocation in
                                    Button(action: {
                                        locationManager.setCurrentLocation(savedLocation)
                                    }) {
                                        HStack {
                                            Text(savedLocation.name)
                                            if savedLocation.id == location.id {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                    }
                                }
                                
                                Divider()
                                
                                Button("Manage Locations") {
                                    selectedTab = 1 // Switch to Location tab
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "location.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                    
                                    Text("Switch")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.blue)
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            // Current tide info
            if let currentHeight = tideViewModel.currentTideHeight {
                VStack(spacing: 16) {
                    Text("Current Tide")
                        .font(.headline)
                        .foregroundColor(.seaside.primaryText)
                    
                    HStack(spacing: 20) {
                        VStack(spacing: 4) {
                            Text(String(format: "%.1fm", currentHeight))
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.seaside.oceanBlue)
                            Text("Height")
                                .font(.caption)
                                .foregroundColor(.seaside.secondaryText)
                        }
                        
                        if let nextHigh = tideViewModel.nextHighTide {
                            VStack(spacing: 4) {
                                Text(nextHigh.formattedTime)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.seaside.primaryText)
                                Text("Next High")
                                    .font(.caption)
                                    .foregroundColor(.seaside.secondaryText)
                            }
                        }
                        
                        if let nextLow = tideViewModel.nextLowTide {
                            VStack(spacing: 4) {
                                Text(nextLow.formattedTime)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.seaside.primaryText)
                                Text("Next Low")
                                    .font(.caption)
                                    .foregroundColor(.seaside.secondaryText)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.seaside.cardBackground)
                .cornerRadius(16)
                .shadow(color: .seaside.deepSea.opacity(0.1), radius: 8, x: 0, y: 4)
            }
            
            // Tide graph - only show when there's valid data and no errors
            if !tideViewModel.get24HourTideData().isEmpty && tideViewModel.errorMessage == nil {
                VStack(alignment: .leading, spacing: 16) {
                    Text("24-Hour Tide Graph")
                        .font(.headline)
                        .foregroundColor(.seaside.primaryText)
                    
                    TideGraphView(
                        tideData: tideViewModel.get24HourTideData(),
                        currentHeight: tideViewModel.currentTideHeight,
                        width: UIScreen.main.bounds.width - 48,
                        height: 200
                    )
                }
            }
            
            // Tide table - only show when there's valid data and no errors
            if !tideViewModel.get24HourTideData().isEmpty && tideViewModel.errorMessage == nil {
                VStack(alignment: .leading, spacing: 16) {
                    Text("24-Hour Tide Data")
                        .font(.headline)
                        .foregroundColor(.seaside.primaryText)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(tideViewModel.get24HourTideData()) { tidePoint in
                            TideRowView(tidePoint: tidePoint)
                        }
                    }
                }
            }
            
            // Loading state
            if tideViewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(.seaside.oceanBlue)
                    Text("Loading tide data...")
                        .font(.subheadline)
                        .foregroundColor(.seaside.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            
            // Error state - show this prominently when there's an error
            if let errorMessage = tideViewModel.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.seaside.warning)
                    
                    Text("Tide Data Unavailable")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.seaside.primaryText)
                    
                    Text(errorMessage)
                        .font(.body)
                        .foregroundColor(.seaside.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Action button to go to Settings
                    Button(action: {
                        selectedTab = 2 // Switch to Settings tab
                    }) {
                        HStack {
                            Image(systemName: "gear")
                            Text("Check API Settings")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.seaside.oceanBlue)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.seaside.secondaryBackground)
                .cornerRadius(16)
            }
        }
    }
}

struct TideRowView: View {
    let tidePoint: TidePoint
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(tidePoint.formattedTime)
                    .font(.headline)
                    .foregroundColor(.seaside.primaryText)
                
                Text(tidePoint.formattedDate)
                    .font(.caption)
                    .foregroundColor(.seaside.secondaryText)
            }
            
            Spacer()
            
            Text(String(format: "%.1fm", tidePoint.height))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(tidePoint.height > 0 ? .seaside.oceanBlue : .seaside.seafoamGreen)
        }
        .padding()
        .background(Color.seaside.secondaryBackground)
        .cornerRadius(12)
    }
}

import SwiftUI

struct MainTabView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var tideViewModel: TideViewModel
    @State private var selectedTab = 0 // Start with Tides tab (index 0) to show welcome message
    
    init() {
        let locationManager = LocationManager()
        self._locationManager = StateObject(wrappedValue: locationManager)
        self._tideViewModel = StateObject(wrappedValue: TideViewModel(locationManager: locationManager))
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                TideInfoView(tideViewModel: tideViewModel, locationManager: locationManager, selectedTab: $selectedTab)
            }
            .tabItem {
                Image(systemName: "water.waves")
                Text("Tides")
            }
            .tag(0)
            
            LocationSearchView(locationManager: locationManager, tideViewModel: tideViewModel)
                .tabItem {
                    Image(systemName: "location")
                    Text("Location")
                }
                .tag(1)
            
            SettingsView(apiService: tideViewModel.apiService)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(2)
        }
        .accentColor(.seaside.oceanBlue)
        .background(Color.seaside.mainBackground)
        .onAppear {
            // Always start with Tides tab to show welcome message
            selectedTab = 0
        }
        .onChange(of: locationManager.currentLocation) { _, newLocation in
            // When location is set, stay on Tides tab to show the new data
            if newLocation != nil {
                selectedTab = 0
            }
        }
    }
}

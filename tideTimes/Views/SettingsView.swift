import SwiftUI

struct SettingsView: View {
    @ObservedObject var apiService: TideAPIService
    @State private var apiKey: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isAlertSuccess = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Stormglass API Key")
                            .font(.headline)
                            .foregroundColor(.seaside.primaryText)
                        
                        Text("Get your free API key from stormglass.io")
                            .font(.caption)
                            .foregroundColor(.seaside.secondaryText)
                        
                        SecureField("Enter your API key", text: $apiKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onAppear {
                                apiKey = apiService.getCurrentAPIKey()
                            }
                        
                        HStack {
                            Button("Update API Key") {
                                updateAPIKey()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.seaside.oceanBlue)
                            
                            Spacer()
                            
                            Button("Test Connection") {
                                testAPIKey()
                            }
                            .buttonStyle(.bordered)
                            .foregroundColor(.seaside.oceanBlue)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("API Configuration")
                        .foregroundColor(.seaside.primaryText)
                        .font(.headline)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.seaside.oceanBlue)
                            Text("Free Tier: 50 requests per day")
                                .foregroundColor(.seaside.primaryText)
                        }
                        
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.seaside.warning)
                            Text("Resets daily at midnight UTC")
                                .foregroundColor(.seaside.primaryText)
                        }
                        
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.seaside.seafoamGreen)
                            Text("Global tide data coverage")
                                .foregroundColor(.seaside.primaryText)
                        }
                        
                        HStack {
                            Image(systemName: "link")
                                .foregroundColor(.seaside.coralAccent)
                            Text("Get your key at stormglass.io")
                                .foregroundColor(.seaside.primaryText)
                        }
                    }
                    .font(.subheadline)
                } header: {
                    Text("API Information")
                        .foregroundColor(.seaside.primaryText)
                        .font(.headline)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How to get your API key:")
                            .font(.headline)
                            .foregroundColor(.seaside.primaryText)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("1. Visit stormglass.io")
                                .foregroundColor(.seaside.secondaryText)
                            Text("2. Sign up for a free account")
                                .foregroundColor(.seaside.secondaryText)
                            Text("3. Copy your API key")
                                .foregroundColor(.seaside.secondaryText)
                            Text("4. Paste it above and tap Update")
                                .foregroundColor(.seaside.secondaryText)
                        }
                        .font(.caption)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Help")
                        .foregroundColor(.seaside.primaryText)
                        .font(.headline)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .scrollContentBackground(.hidden) // Hide default form background
            .background(Color.seaside.mainBackground)
            .alert(isAlertSuccess ? "Success" : "Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func updateAPIKey() {
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAlert("Please enter a valid API key", success: false)
            return
        }
        
        apiService.updateAPIKey(apiKey.trimmingCharacters(in: .whitespacesAndNewlines))
        showAlert("API key updated successfully!", success: true)
    }
    
    private func testAPIKey() {
        Task {
            do {
                let testLocation = Location(name: "Test", latitude: 51.1279, longitude: 1.3134, country: "UK")
                _ = try await apiService.fetchTideData(for: testLocation)
                await MainActor.run {
                    showAlert("API key is working! Connection test successful.", success: true)
                }
            } catch {
                await MainActor.run {
                    showAlert("Connection test failed: \(error.localizedDescription)", success: false)
                }
            }
        }
    }
    
    private func showAlert(_ message: String, success: Bool) {
        alertMessage = message
        isAlertSuccess = success
        showingAlert = true
    }
}

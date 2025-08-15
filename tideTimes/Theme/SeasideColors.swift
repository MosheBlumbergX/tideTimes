import SwiftUI

struct SeasideColors {
    // Primary ocean colors
    static let oceanBlue = Color(red: 0.2, green: 0.5, blue: 0.8)      // Deep ocean blue
    static let seaBlue = Color(red: 0.3, green: 0.6, blue: 0.9)        // Medium sea blue
    static let skyBlue = Color(red: 0.4, green: 0.7, blue: 1.0)        // Light sky blue
    
    // Calm seaside colors
    static let sandBeige = Color(red: 0.95, green: 0.93, blue: 0.88)   // Warm sand color
    static let coralAccent = Color(red: 0.98, green: 0.6, blue: 0.5)   // Soft coral accent
    static let seafoamGreen = Color(red: 0.7, green: 0.9, blue: 0.8)   // Seafoam green
    
    // Neutral seaside colors
    static let driftwoodGray = Color(red: 0.6, green: 0.6, blue: 0.6)  // Driftwood gray
    static let shellWhite = Color(red: 0.98, green: 0.98, blue: 0.98)  // Pure shell white
    static let deepSea = Color(red: 0.1, green: 0.3, blue: 0.5)        // Deep sea dark
    
    // Semantic colors with seaside theme
    static let success = seafoamGreen
    static let warning = coralAccent
    static let error = Color(red: 0.9, green: 0.4, blue: 0.4)          // Soft coral red
    
    // Background colors
    static let primaryBackground = shellWhite
    static let secondaryBackground = sandBeige
    static let cardBackground = Color.white
    
    // New background options
    static let mainBackground = Color(red: 0.96, green: 0.98, blue: 1.0)  // Very light blue tint
    static let welcomeBackground = Color(red: 0.94, green: 0.97, blue: 1.0)  // Slightly more blue for welcome
    static let cardBackgroundWithTint = Color(red: 0.98, green: 0.99, blue: 1.0)  // Subtle blue tint for cards
    
    // Gradient backgrounds
    static let oceanGradient = LinearGradient(
        colors: [Color(red: 0.94, green: 0.97, blue: 1.0), Color(red: 0.98, green: 0.99, blue: 1.0)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let sandGradient = LinearGradient(
        colors: [Color(red: 0.97, green: 0.95, blue: 0.92), Color(red: 0.99, green: 0.98, blue: 0.96)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Text colors
    static let primaryText = deepSea
    static let secondaryText = driftwoodGray
    static let accentText = oceanBlue
}

// Extension to make colors easily accessible
extension Color {
    static let seaside = SeasideColors.self
}

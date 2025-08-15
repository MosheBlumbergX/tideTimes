# Tide Times iOS App

A beautiful iOS app for viewing tide information with location search and 24-hour tide graphs.

## Features

- 🌊 Real-time tide data from Stormglass API (Free Global Tide Data!)
- 📍 Location search with autosuggest
- 💾 Persistent location storage
- 📊 Beautiful tide curve graph with current position indicator
- 📋 24-hour tide data table
- 🎨 Modern UI following Apple Design Guidelines
- 📱 Tab-based navigation

## Setup

### 1. Get Stormglass API Key (Free!)

1. Visit [Stormglass API](https://stormglass.io/)
2. Sign up for a **free account**
3. Get your API key (50 free requests per day)

### 2. Configure API Key

1. Open `tideTimes/Services/TideAPIService.swift`
2. Replace `YOUR_STORMGLASS_API_KEY` with your actual API key:

```swift
private let apiKey = "your_actual_stormglass_api_key_here"
```

### 3. Build and Run

1. Open `tideTimes.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run the project

## App Structure

- **Models**: Data structures for tide information and locations
- **Services**: API service for fetching tide data and location search
- **ViewModels**: Business logic and data management
- **Views**: SwiftUI views for the user interface

## API Usage

The app uses the **Stormglass API** to fetch:
- Real tide heights for the next 24 hours
- Actual high and low tide times
- Global tide data (works for Dover, UK and worldwide)

**Benefits of Stormglass API:**
- ✅ **Free Tier**: 50 requests per day
- ✅ **Global Coverage**: Works for Dover, UK and worldwide
- ✅ **Real Data**: Actual tide measurements and predictions
- ✅ **Easy Setup**: Simple API key registration
- ✅ **Reliable**: Used by many weather and marine apps

## Design Features

- **Curved Tide Graph**: Shows tide curve with current position indicator
- **Responsive Layout**: Adapts to different screen sizes
- **Modern UI Elements**: Cards, shadows, and rounded corners
- **Color Coding**: Blue for high tides, green for low tides
- **Accessibility**: Proper contrast and readable fonts

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## License

This project is for educational purposes. The Stormglass API is free for up to 50 requests per day.



## Reference 

[YouTube](https://www.youtube.com/watch?v=oe3Jn6FRoII)
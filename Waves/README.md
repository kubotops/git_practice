# Waves

A native iOS app built with SwiftUI to help you track and manage temptations using visual analytics and goal setting.

## Features

- Track temptations with custom triggers
- Set weekly goals for maximum temptations
- View progress with beautiful charts
- Analyze patterns by trigger, time of day, and day of week
- Glass morphism UI with gradient backgrounds
- Data persistence using @AppStorage

## Requirements

- iOS 16.0+
- Xcode 14.0+
- Swift 5.7+

## How to Open in Xcode

Since this is a SwiftUI App without an `.xcodeproj` file, follow these steps:

### Option 1: Create New Xcode Project

1. Open Xcode
2. Select "Create a new Xcode project"
3. Choose "iOS" → "App" → Click "Next"
4. Enter the following:
   - Product Name: `Waves`
   - Team: Select your development team
   - Organization Identifier: `com.yourname` (or your preference)
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Click "Next" and choose a location

5. Replace the generated files:
   - Delete the generated `WavesApp.swift` and `ContentView.swift`
   - Copy the files from this `Waves/Waves/` directory into your Xcode project:
     - `WavesApp.swift`
     - `GlassEffect.swift`
   - Replace the `Info.plist` and `Assets.xcassets` folder with the ones from this directory

### Option 2: Use Swift Package

You can also add these files to any existing iOS project:

1. Copy `WavesApp.swift` and `GlassEffect.swift` to your project
2. Make sure your deployment target is iOS 16.0 or higher
3. Ensure the Charts framework is imported

## File Structure

```
Waves/
├── Waves/
│   ├── WavesApp.swift    # Main app file with all views
│   ├── GlassEffect.swift        # Custom glass effect modifier
│   ├── Info.plist               # App configuration
│   └── Assets.xcassets/         # App assets
│       ├── AppIcon.appiconset/
│       ├── AccentColor.colorset/
│       └── Contents.json
└── README.md
```

## App Structure

The app consists of several main views:

- **WavesApp**: Main app entry point
- **ContentView**: Tab view container with floating action button
- **UrgesTab**: Shows weekly progress and logged temptations
- **ProgressTab**: Displays charts and analytics
- **LogTemptationView**: Sheet for logging new temptations
- **DatePickerSheet**: Date/time picker for temptations
- **SettingsView**: Configure weekly goal

## Data Model

- **Temptation**: Codable struct with id, timestamp, and trigger
- Data is persisted using `@AppStorage` with JSON encoding

## UI Components

- Glass morphism effects using `.ultraThinMaterial`
- Custom gradient backgrounds (cyan to deep blue)
- SwiftUI Charts for data visualization
- Responsive layouts with ScrollView and VStack/HStack

## Building and Running

1. Open the project in Xcode
2. Select a simulator or connected device
3. Press Cmd+R to build and run

## Customization

You can customize:
- Gradient colors in the background
- Common trigger options in `LogTemptationView`
- Weekly goal range in `SettingsView`
- Glass effect styling in `GlassEffect.swift`

## License

This project is provided as-is for educational purposes.

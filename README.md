# Garbage Guardian – Citizen App

A smart waste management application that helps citizens monitor nearby smart garbage bins, view their real-time status, and navigate to available bins through an interactive map.

The Garbage Guardian Citizen App aims to make waste disposal more convenient by connecting citizens with smart waste management infrastructure.

## Features

### 🗺️ Interactive Smart Bin Map
- View smart garbage bins on an interactive map.
- Explore bin locations around the user.
- View individual bin markers and their current status.
- Map powered by OpenStreetMap.

### 📍 In-App Navigation
- Navigate to a selected smart bin directly within the application.
- Get your current location using GPS.
- Display the route to the selected bin.
- View estimated distance and travel time.
- Uses OSRM routing services.

### 🗑️ Smart Bin Information
- View individual bin details.
- Monitor bin fill levels.
- Check bin availability and status.
- View the latest available sensor information.

### 🔄 Real-Time Updates
- Retrieve bin information from the backend API.
- Receive live updates through Socket.IO.
- Synchronize bin information with the application.

### 🔔 Notifications
- Access notifications related to smart bin updates and waste management activities.

### 📱 User-Friendly Interface
- Clean and responsive Flutter interface.
- Easy navigation between application screens.
- Designed for Android devices.

## Technology Stack

| Category | Technology |
|---|---|
| Mobile Framework | Flutter |
| Programming Language | Dart |
| Maps | flutter_map |
| Map Data | OpenStreetMap |
| Coordinates | latlong2 |
| Routing | OSRM |
| Location Services | Geolocator |
| API Communication | HTTP / REST API |
| Real-Time Communication | Socket.IO |
| Backend | Node.js |
| Version Control | Git & GitHub |

## Project Structure

```text
garbage_guardian/
│
├── android/
├── ios/
├── linux/
├── macos/
├── web/
├── windows/
│
├── lib/
│   ├── app/
│   │   ├── app.dart
│   │   └── routes.dart
│   │
│   ├── models/
│   │   └── bin.dart
│   │
│   ├── screens/
│   │   ├── bins/
│   │   │   └── bin_details_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── map/
│   │   │   └── map_screen.dart
│   │   └── notifications/
│   │       └── notifications_screen.dart
│   │
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── bin_store.dart
│   │   └── socket_service.dart
│   │
│   └── main.dart
│
├── assets/
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
└── README.md
```

## Prerequisites

Before running the application, install:

- Flutter SDK
- Dart SDK (included with Flutter)
- Android Studio or Visual Studio Code
- Android SDK
- Git

Verify your Flutter installation:

```bash
flutter doctor
```

## Installation and Setup

### 1. Clone the Repository

```bash
git clone https://github.com/pranav-n29/garbage_guardian.git
```

### 2. Navigate to the Project

```bash
cd garbage_guardian
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the Application

Connect an Android device or start an emulator.

```bash
flutter run
```

## Build APK

Generate a release APK:

```bash
flutter build apk --release
```

The generated APK will be available at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Install the release APK on a connected Android device:

```bash
flutter install --release
```

## Required Permissions

The application uses location services for GPS-based navigation.

Android location permissions are configured in:

```text
android/app/src/main/AndroidManifest.xml
```

Required permissions:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

Users must grant location access for current-location and navigation features to work.

## Map and Routing Services

This application uses:

- **OpenStreetMap** for map tiles and geographical data.
- **flutter_map** for displaying interactive maps.
- **OSRM** for retrieving road routes and navigation geometry.

These services may require internet connectivity. Public service endpoints are subject to their usage policies and availability.

## Backend Integration

The application communicates with the Garbage Guardian backend to retrieve smart bin information and receive real-time updates.

Integrated communication includes:

- REST API requests.
- Socket.IO connections.
- Smart bin status synchronization.
- Live sensor information.

Make sure the backend server is running and accessible from the device before testing live functionality.

## Development Commands

| Command | Description |
|---|---|
| `flutter pub get` | Install dependencies |
| `flutter run` | Run the application |
| `flutter analyze` | Analyze Dart code |
| `flutter test` | Run project tests |
| `flutter clean` | Clean build files |
| `flutter build apk --release` | Build release APK |

## Future Enhancements

- Push notifications for important bin updates.
- Waste collection reporting.
- Citizen feedback and complaint reporting.
- Additional smart bin analytics.
- Improved route optimization.
- Expanded coverage across more locations.

## Contributing

Contributions, suggestions, and improvements are welcome.

1. Fork the repository.
2. Create a feature branch.
3. Implement your changes.
4. Commit your changes.
5. Open a Pull Request.

## License

A license has not yet been specified for this project. All rights are reserved unless a license is added to the repository.

---

**Garbage Guardian – Smarter Waste Management for Cleaner Communities.**

# Truck Logistics - Fleet Owner Desktop Program (Flutter Windows)

A single-screen live desktop application for fleet owners to monitor active fleet vehicles, view live trip status, check total earnings in LKR, review complete trip logs, and register new trucks.

---

## 💻 Dashboard Features

- **Summary Metric Cards**: Live active trip counter, total fleet count, and total earnings sum from completed trips (LKR).
- **Live Fleet Table**: Cross-references `GET /trucks` with `GET /trips/active` by `truck_id` to show whether each truck is "🟢 On Trip" (with active route) or "🅿️ Idle".
- **Trip Log**: Complete history from `GET /trips` (newest first) with distance, fare, and status tags.
- **Auto-Sync Polling**: Automatically refreshes data every 5 seconds (`Timer.periodic`) with explicit `TODO` hook for WebSockets upgrade.
- **Truck Management (FR1)**: "Add Truck" dialog form calling `POST /trucks`.

---

## ⚙️ Configuration & Execution Commands

### 1. Enable Windows Desktop Support (Once)
```bash
flutter config --enable-windows-desktop
```

### 2. Set Backend Base URL
Edit [lib/config/api_config.dart](file:///c:/Users/User/Downloads/Project_NEO/Truck_Logistics/owner_app/lib/config/api_config.dart):
- **Same Windows Machine**: `static const String baseUrl = 'http://localhost:8000';`
- **Network Laptop**: `static const String baseUrl = 'http://192.168.1.15:8000';`

### 3. Commands to Run & Build
```bash
cd owner_app

# Get dependencies
flutter pub get

# Run native Windows desktop app
flutter run -d windows

# Build standalone Windows executable
flutter build windows
```
Standalone executable generated at: `build/windows/runner/Release/owner_app.exe`

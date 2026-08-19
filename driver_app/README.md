# Truck Logistics - Driver Mobile App (Flutter)

A functional Flutter mobile application designed for truck drivers to pick their assigned vehicle, initiate active trips, track simulated driving distance & live estimated LKR fares, and submit manual distance overrides when completing a trip.

---

## 📱 App Screens & Workflow

1. **Truck/Driver Selection Screen**: Fetches `GET /trucks` and displays available fleet vehicles.
2. **Idle / Start Trip Screen**: Form to enter `start_location` and `end_location`. Calls `POST /trips/start`.
3. **Active Trip Screen**: Displays live route, simulated distance counter (increments 1-3 km every 2s via `Timer.periodic`), live estimated fare calculation in LKR, and explicit `TODO` hook for real GPS location streams.
4. **Confirm / Review Screen**: Manual distance override input field, live recalculated fare, and "Confirm and close trip" button calling `POST /trips/{trip_id}/end`.
5. **Driver History Screen**: Log of past trips with status badges ("active" / "completed").

---

## ⚙️ Configuration & Execution Commands

### 1. Set Backend Base URL
Edit [lib/config/api_config.dart](file:///c:/Users/User/Downloads/Project_NEO/Truck_Logistics/driver_app/lib/config/api_config.dart):
- **Android Emulator**: `static const String baseUrl = 'http://10.0.2.2:8000';`
- **Physical Phone (Local Wi-Fi)**: `static const String baseUrl = 'http://192.168.1.15:8000';` (replace with your laptop's IPv4 address from `ipconfig`).

### 2. Commands to Run & Build
```bash
cd driver_app

# Get dependencies
flutter pub get

# Run on Android emulator or connected device
flutter run -d android

# Build standalone APK for direct installation
flutter build apk --release
```
Standalone APK generated at: `build/app/outputs/flutter-apk/app-release.apk`

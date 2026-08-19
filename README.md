# Truck Trip Logging System - FastAPI Backend

A lightweight, high-performance Python FastAPI backend for tracking fleet trucks, logging active trips, and automatically calculating trip fares in Sri Lankan Rupees (LKR).

Uses **SQLite** for instant local execution with zero setup, **SQLAlchemy 2.0**, **Pydantic v2**, and includes **CORS support** for mobile apps (e.g. Flutter).

---

## 🚀 Features & Business Logic

- **Truck Fleet Management**: Create and list trucks with drivers and custom rates (`LKR/km`).
- **Trip Lifecycle Tracking**: Start trips (`status="active"`) and end trips (`status="completed"`).
- **Validation**: Prevents a truck from starting multiple concurrent active trips and prevents double-ending trips.
- **Automatic Fare Calculation**: When a trip ends with `distance_km`, `fare` is computed automatically: `fare = distance_km * truck.rate_per_km`.
- **Live Dashboard Support**: Endpoint `/trips/active` returns only ongoing trips.
- **Flutter / Cross-Device Ready**: CORS is enabled for all origins (`*`) and binding `0.0.0.0` allows physical devices or emulators on the same Wi-Fi network to call the API.

---

## 🛠️ Endpoints Overview

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/trucks` | Create a new truck profile |
| `GET` | `/trucks` | List all trucks |
| `POST` | `/trips/start` | Start a new trip for a truck (`status="active"`) |
| `POST` | `/trips/{trip_id}/end` | End an active trip (calculates `fare = distance_km * rate_per_km`) |
| `GET` | `/trips` | List all trips (newest first) |
| `GET` | `/trips/active` | List only currently active trips (for live dashboard) |
| `GET` | `/docs` | Interactive OpenAPI / Swagger UI |

---

## 📋 Requirements & Setup

### 1. Prerequisites
- Python 3.9+ installed on your system.

### 2. Create Virtual Environment & Install Dependencies

```bash
# Navigate to project directory
cd Truck_Logistics

# Create virtual environment (optional but recommended)
python -m venv venv

# Activate virtual environment
# Windows (PowerShell):
.\venv\Scripts\Activate.ps1
# macOS / Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

---

## 🌱 Seeding Initial Sample Data

To populate your local SQLite database (`truck_logistics.db`) with sample trucks and active/completed trips:

```bash
python seed.py
```

Sample trucks created:
- `WP CAD-1024` (Driver: Kamal Perera, Rate: 180.0 LKR/km)
- `SP ND-4509` (Driver: Sunil Shantha, Rate: 220.0 LKR/km)
- `CP LA-8812` (Driver: Nimal Fernando, Rate: 150.0 LKR/km)
- `WP GA-3390` (Driver: Anura Jayasinghe, Rate: 200.0 LKR/km)

---

## 🏃 Running the Backend Server

Start the application with Uvicorn:

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

- `--host 0.0.0.0`: Makes the server accessible to other devices (e.g. Flutter mobile app, tablets, laptops) on the same Wi-Fi network.
- `--port 8000`: Runs on port 8000.
- `--reload`: Auto-reloads server on code changes.

Once running:
- **API Base URL**: `http://localhost:8000` (or `http://<YOUR_LOCAL_IP>:8000`)
- **Interactive Swagger Documentation**: [http://localhost:8000/docs](http://localhost:8000/docs)
- **Alternative ReDoc Documentation**: [http://localhost:8000/redoc](http://localhost:8000/redoc)

---

##📱 Connecting from a Flutter App

To connect a Flutter mobile app running on a physical Android/iOS phone or emulator:

1. **Find your computer's local IP address**:
   - **Windows**: Run `ipconfig` in CMD/PowerShell (look for `IPv4 Address`, e.g., `192.168.1.15`).
   - **macOS / Linux**: Run `ifconfig` or `ip a` (e.g., `192.168.1.15`).

2. **In Flutter**:
   Use `http://192.168.1.15:8000` as your `baseUrl` instead of `localhost` (since `localhost` inside an emulator or phone refers to the device itself).

   *Example Dart/Flutter API call:*
   ```dart
   final response = await http.get(Uri.parse('http://192.168.1.15:8000/trips/active'));
   ```

---

## 🧪 Running Automated Tests

Run unit & integration tests using pytest:

```bash
pytest test_api.py -v
```

All endpoints, business validations, active-trip constraints, and fare calculation logic are verified.

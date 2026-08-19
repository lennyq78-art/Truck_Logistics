# Hosting on Hugging Face Spaces (100% Free 24/7 Cloud Hosting)

Hugging Face Spaces allows you to host Python FastAPI + Docker web applications completely **FREE 24/7** with automatic HTTPS encryption!

---

## 🚀 How to Create a Hugging Face Space

1. Sign in to **[https://huggingface.co](https://huggingface.co)**.
2. Click **New Space** or go to **[https://huggingface.co/new-space](https://huggingface.co/new-space)**.
3. Configure your Space:
   - **Owner**: `lennyq78-art`
   - **Space Name**: `truck-logistics`
   - **License**: `mit`
   - **Space SDK**: Select **Docker** -> **Blank Docker**
   - **Visibility**: `Public`
4. Click **Create Space**.

---

## 📡 Live Public URL Structure

Once created, Hugging Face gives your backend a permanent public URL:  
👉 **`https://lennyq78-art-truck-logistics.hf.space`**

---

## 🚚 How Owner & Driver Work with Hugging Face

### 1. Fleet Owner (Web Dashboard / App)
- **URL**: Open **`https://lennyq78-art-truck-logistics.hf.space`** in any web browser on laptop or phone!
- **Features**:
  - Live summary metrics (Active Trips, Fleet Count, Total LKR Revenue)
  - Interactive OpenStreetMap GPS tracking map with real-time truck markers
  - Full trip history & truck dispatching

### 2. Drivers (Redmi Note 9 Pro on 4G Mobile Data)
- Set `baseUrl` in `driver_app/lib/config/api_config.dart`:
  ```dart
  class ApiConfig {
    static const String baseUrl = 'https://lennyq78-art-truck-logistics.hf.space';
  }
  ```
- **Driver Workflow on Road**:
  1. Open Driver App on Redmi Note 9 Pro over 4G.
  2. Select Truck -> Enter Start & End Locations -> Tap **Start Trip**.
  3. Live distance meter increments, sending GPS coordinates to Hugging Face.
  4. Tap **End Trip** -> Confirm -> Fare calculated in LKR automatically!

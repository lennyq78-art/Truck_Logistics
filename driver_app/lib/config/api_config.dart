/// API Configuration for Truck Logistics Driver App
///
/// HOW TO CHANGE BASE URL FOR TESTING:
/// 1. Testing on Android Emulator: Use 'http://10.0.2.2:8000' (10.0.2.2 points to host machine localhost).
/// 2. Testing on Physical Android Phone: Change to your laptop's local IP (e.g., 'http://192.168.1.15:8000').
/// 3. Testing on Windows / Desktop / Web: Use 'http://localhost:8000'.
class ApiConfig {
  // Production Hugging Face Space URL (Works on 4G/5G mobile data 24/7!)
  static const String baseUrl = 'https://lennyq78-art-truck-logistics.hf.space';
  
  // Timeout for network requests
  static const Duration timeoutDuration = Duration(seconds: 10);
}

/// API Configuration for Fleet Owner Desktop App
///
/// For Windows Desktop app running on the same laptop as FastAPI backend:
/// Use 'http://localhost:8000'.
/// If backend is hosted on another machine on local network:
/// Change to 'http://192.168.X.X:8000'.
class ApiConfig {
  static const String baseUrl = 'http://localhost:8000';
  static const Duration timeoutDuration = Duration(seconds: 10);
  
  // Auto-refresh polling interval in seconds
  static const int autoRefreshSeconds = 5;
}

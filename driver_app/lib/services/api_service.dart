import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/truck.dart';
import '../models/trip.dart';

class ApiService {
  final String _baseUrl;

  ApiService({String? baseUrl}) : _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  /// Parse backend error messages from response body (e.g., {"detail": "..."})
  String _extractErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data.containsKey('detail')) {
        final detail = data['detail'];
        if (detail is String) return detail;
        if (detail is List && detail.isNotEmpty) {
          // Handle Pydantic validation errors list
          return detail.map((e) => e['msg'] ?? e.toString()).join(', ');
        }
      }
    } catch (_) {}
    return 'Server error (${response.statusCode}): ${response.reasonPhrase}';
  }

  /// GET /trucks - List all registered trucks
  Future<List<Truck>> getTrucks() async {
    final uri = Uri.parse('$_baseUrl/trucks');
    try {
      final response = await http.get(uri).timeout(ApiConfig.timeoutDuration);
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Truck.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network connection error: $e');
    }
  }

  /// POST /trips/start - Start a trip for a truck
  Future<Trip> startTrip({
    required int truckId,
    required String startLocation,
    required String endLocation,
  }) async {
    final uri = Uri.parse('$_baseUrl/trips/start');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'truck_id': truckId,
          'start_location': startLocation,
          'end_location': endLocation,
        }),
      ).timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Trip.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network connection error: $e');
    }
  }

  /// POST /trips/{trip_id}/end - End an active trip with distance_km
  Future<Trip> endTrip({
    required int tripId,
    required double distanceKm,
  }) async {
    final uri = Uri.parse('$_baseUrl/trips/$tripId/end');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'distance_km': distanceKm,
        }),
      ).timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 200) {
        return Trip.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network connection error: $e');
    }
  }

  /// GET /trips - List all trips (newest first)
  Future<List<Trip>> getTrips() async {
    final uri = Uri.parse('$_baseUrl/trips');
    try {
      final response = await http.get(uri).timeout(ApiConfig.timeoutDuration);
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Trip.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network connection error: $e');
    }
  }
}

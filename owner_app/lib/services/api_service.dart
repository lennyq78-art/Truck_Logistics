import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/truck.dart';
import '../models/trip.dart';

class ApiService {
  final String _baseUrl;

  ApiService({String? baseUrl}) : _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  String _extractErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data.containsKey('detail')) {
        final detail = data['detail'];
        if (detail is String) return detail;
        if (detail is List && detail.isNotEmpty) {
          return detail.map((e) => e['msg'] ?? e.toString()).join(', ');
        }
      }
    } catch (_) {}
    return 'Server error (${response.statusCode}): ${response.reasonPhrase}';
  }

  /// GET /trucks - List all trucks
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

  /// GET /trips/active - List only active trips
  Future<List<Trip>> getActiveTrips() async {
    final uri = Uri.parse('$_baseUrl/trips/active');
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

  /// POST /trucks - Create a new truck profile (FR1)
  Future<Truck> createTruck({
    required String plateNumber,
    required String driverName,
    required double ratePerKm,
  }) async {
    final uri = Uri.parse('$_baseUrl/trucks');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'plate_number': plateNumber,
          'driver_name': driverName,
          'rate_per_km': ratePerKm,
        }),
      ).timeout(ApiConfig.timeoutDuration);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Truck.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network connection error: $e');
    }
  }
}

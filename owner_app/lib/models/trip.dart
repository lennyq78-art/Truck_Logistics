import 'truck.dart';

class Trip {
  final int id;
  final int truckId;
  final String startLocation;
  final String endLocation;
  final String status;
  final DateTime startedAt;
  final double? distanceKm;
  final double? fare;
  final DateTime? endedAt;
  final Truck? truck;

  Trip({
    required this.id,
    required this.truckId,
    required this.startLocation,
    required this.endLocation,
    required this.status,
    required this.startedAt,
    this.distanceKm,
    this.fare,
    this.endedAt,
    this.truck,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as int,
      truckId: json['truck_id'] as int,
      startLocation: json['start_location'] as String,
      endLocation: json['end_location'] as String,
      status: json['status'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      distanceKm: json['distance_km'] != null ? (json['distance_km'] as num).toDouble() : null,
      fare: json['fare'] != null ? (json['fare'] as num).toDouble() : null,
      endedAt: json['ended_at'] != null ? DateTime.tryParse(json['ended_at'] as String) : null,
      truck: json['truck'] != null ? Truck.fromJson(json['truck'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'truck_id': truckId,
      'start_location': startLocation,
      'end_location': endLocation,
      'status': status,
      'started_at': startedAt.toIso8601String(),
      'distance_km': distanceKm,
      'fare': fare,
      'ended_at': endedAt?.toIso8601String(),
      'truck': truck?.toJson(),
    };
  }
}

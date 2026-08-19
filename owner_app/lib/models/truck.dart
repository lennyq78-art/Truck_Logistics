class Truck {
  final int id;
  final String plateNumber;
  final String driverName;
  final double ratePerKm;
  final DateTime? createdAt;

  Truck({
    required this.id,
    required this.plateNumber,
    required this.driverName,
    required this.ratePerKm,
    this.createdAt,
  });

  factory Truck.fromJson(Map<String, dynamic> json) {
    return Truck(
      id: json['id'] as int,
      plateNumber: json['plate_number'] as String,
      driverName: json['driver_name'] as String,
      ratePerKm: (json['rate_per_km'] as num).toDouble(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plate_number': plateNumber,
      'driver_name': driverName,
      'rate_per_km': ratePerKm,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

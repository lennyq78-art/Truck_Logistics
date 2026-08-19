import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../models/truck.dart';
import 'trip_confirm_screen.dart';

class ActiveTripScreen extends StatefulWidget {
  final Trip trip;
  final Truck truck;

  const ActiveTripScreen({
    Key? key,
    required this.trip,
    required this.truck,
  }) : super(key: key);

  @override
  State<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends State<ActiveTripScreen> {
  Timer? _simulationTimer;
  double _currentDistanceKm = 0.0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startDistanceSimulation();
  }

  /// Timer simulating distance growth during active drive.
  /// 
  /// =========================================================================
  /// TODO: REAL GPS / ROUTING INTEGRATION PLUG-IN LOCATION
  /// =========================================================================
  /// Replace this simulation timer with a real GPS location stream service
  /// (e.g. Geolocator package `Geolocator.getPositionStream()`) or Google Maps /
  /// OSRM Distance Matrix API.
  /// Example:
  ///   Geolocator.getPositionStream().listen((Position position) {
  ///     double delta = calculateHaversineDistance(_lastPos, position);
  ///     setState(() { _currentDistanceKm += delta; });
  ///   });
  /// =========================================================================
  void _startDistanceSimulation() {
    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;
      setState(() {
        // Increment distance by 1.0 to 3.0 km every 2 seconds
        double increment = 1.0 + _random.nextDouble() * 2.0;
        _currentDistanceKm += double.parse(increment.toStringAsFixed(1));
      });
    });
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }

  double get _estimatedFare => _currentDistanceKm * widget.truck.ratePerKm;

  void _handleEndTripPressed() {
    _simulationTimer?.cancel();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripConfirmScreen(
          trip: widget.trip,
          truck: widget.truck,
          simulatedDistanceKm: _currentDistanceKm,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Active Trip #${widget.trip.id}'),
        automaticallyImplyLeading: false, // Prevent going back while on active trip
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(Icons.circle, color: Colors.green, size: 14),
                  const SizedBox(width: 8),
                  const Text(
                    'TRIP IS ACTIVE - LIVE LOGGING',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Route Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.truck.plateNumber,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Driver: ${widget.truck.driverName}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.my_location, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.trip.startLocation,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(Icons.more_vert, color: Colors.grey, size: 20),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.trip.endLocation,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Live Meter Display
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade900,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'SIMULATED LIVE DISTANCE',
                    style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_currentDistanceKm.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Estimated Fare:',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      Text(
                        'LKR ${_estimatedFare.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // End Trip Button
            ElevatedButton.icon(
              onPressed: _handleEndTripPressed,
              icon: const Icon(Icons.flag),
              label: const Text('End Trip & Review', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

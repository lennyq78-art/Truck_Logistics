import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../services/api_service.dart';

class DriverHistoryScreen extends StatefulWidget {
  const DriverHistoryScreen({Key? key}) : super(key: key);

  @override
  State<DriverHistoryScreen> createState() => _DriverHistoryScreenState();
}

class _DriverHistoryScreenState extends State<DriverHistoryScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Trip>> _tripsFuture;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  void _loadTrips() {
    setState(() {
      _tripsFuture = _apiService.getTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrips,
          ),
        ],
      ),
      body: FutureBuilder<List<Trip>>(
        future: _tripsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Failed to load history:\n${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final trips = snapshot.data ?? [];
          if (trips.isEmpty) {
            return const Center(
              child: Text('No trip history found.'),
            );
          }

          return ListView.builder(
            itemCount: trips.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              final trip = trips[index];
              final isCompleted = trip.status == 'completed';
              final truckPlate = trip.truck?.plateNumber ?? 'Truck #${trip.truckId}';

              return Card(
                margin: const EdgeInsets.only(bottom: 12.0),
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Trip #${trip.id} - $truckPlate',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Chip(
                        label: Text(
                          trip.status.toUpperCase(),
                          style: TextStyle(
                            color: isCompleted ? Colors.green.shade900 : Colors.blue.shade900,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: isCompleted ? Colors.green.shade100 : Colors.blue.shade100,
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${trip.startLocation} ➔ ${trip.endLocation}'),
                      if (isCompleted) ...[
                        Text(
                          'Distance: ${trip.distanceKm?.toStringAsFixed(1) ?? "0"} km',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Fare: LKR ${trip.fare?.toStringAsFixed(2) ?? "0.00"}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

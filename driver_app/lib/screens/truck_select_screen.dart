import 'package:flutter/material.dart';
import '../models/truck.dart';
import '../services/api_service.dart';
import 'trip_start_screen.dart';
import 'driver_history_screen.dart';

class TruckSelectScreen extends StatefulWidget {
  const TruckSelectScreen({Key? key}) : super(key: key);

  @override
  State<TruckSelectScreen> createState() => _TruckSelectScreenState();
}

class _TruckSelectScreenState extends State<TruckSelectScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Truck>> _trucksFuture;

  @override
  void initState() {
    super.initState();
    _loadTrucks();
  }

  void _loadTrucks() {
    setState(() {
      _trucksFuture = _apiService.getTrucks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Truck'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Trip History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DriverHistoryScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrucks,
          ),
        ],
      ),
      body: FutureBuilder<List<Truck>>(
        future: _trucksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load trucks:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadTrucks,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final trucks = snapshot.data ?? [];
          if (trucks.isEmpty) {
            return const Center(
              child: Text('No trucks registered in the backend.'),
            );
          }

          return ListView.builder(
            itemCount: trucks.length,
            padding: const EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              final truck = trucks[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.local_shipping, color: Colors.blue),
                  ),
                  title: Text(
                    truck.plateNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text('Driver: ${truck.driverName}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'LKR ${truck.ratePerKm}/km',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TripStartScreen(truck: truck),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

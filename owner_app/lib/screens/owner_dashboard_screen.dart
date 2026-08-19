import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/api_config.dart';
import '../models/truck.dart';
import '../models/trip.dart';
import '../services/api_service.dart';
import '../widgets/add_truck_dialog.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final ApiService _apiService = ApiService();
  Timer? _autoRefreshTimer;

  List<Truck> _trucks = [];
  List<Trip> _activeTrips = [];
  List<Trip> _allTrips = [];

  bool _isLoading = true;
  String? _errorMessage;
  DateTime? _lastRefreshedAt;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
    _startAutoRefresh();
  }

  /// Periodic polling for live updates.
  /// 
  /// =========================================================================
  /// TODO: WEBSOCKET / PUSH NOTIFICATION UPGRADE LOCATION
  /// =========================================================================
  /// Current Implementation: 5-second polling interval via Timer.periodic.
  /// Next Phase Upgrade: Replace periodic polling with a WebSocket client connection
  /// (e.g., `web_socket_channel` package connecting to `ws://localhost:8000/ws/dashboard`)
  /// for instant real-time event-driven updates.
  /// =========================================================================
  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: ApiConfig.autoRefreshSeconds),
      (timer) {
        _fetchDashboardData(isBackground: true);
      },
    );
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchDashboardData({bool isBackground = false}) async {
    if (!isBackground) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final results = await Promise.all([
        _apiService.getTrucks(),
        _apiService.getActiveTrips(),
        _apiService.getTrips(),
      ]);

      if (!mounted) return;

      setState(() {
        _trucks = results[0] as List<Truck>;
        _activeTrips = results[1] as List<Trip>;
        _allTrips = results[2] as List<Trip>;
        _isLoading = false;
        _errorMessage = null;
        _lastRefreshedAt = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;
      if (!isBackground) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  // Derived Metrics
  int get _activeCount => _activeTrips.length;

  double get _totalEarnings {
    double total = 0.0;
    for (final trip in _allTrips) {
      if (trip.status == 'completed' && trip.fare != null) {
        total += trip.fare!;
      }
    }
    return total;
  }

  void _openAddTruckDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTruckDialog(
        onTruckAdded: () {
          _fetchDashboardData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Truck added successfully!'), backgroundColor: Colors.green),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: 'LKR ', decimalDigits: 2);
    final timeFormatter = DateFormat('hh:mm:ss a');

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.dashboard, color: Colors.blue),
            SizedBox(width: 8),
            Text('Fleet Owner Live Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          if (_lastRefreshedAt != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Center(
                child: Text(
                  'Auto-Sync: ${timeFormatter.format(_lastRefreshedAt!)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
          ElevatedButton.icon(
            onPressed: _openAddTruckDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Truck'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Manual Refresh',
            onPressed: () => _fetchDashboardData(),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TOP: Metrics Summary Row
                      _buildSummaryRow(currencyFormatter),

                      const SizedBox(height: 24),

                      // MIDDLE: Live Fleet Status Table
                      const Text(
                        '🚛 Live Fleet Vehicles Status',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _buildFleetStatusCard(),

                      const SizedBox(height: 28),

                      // BOTTOM: Complete Trip Log Table
                      const Text(
                        '📜 Complete Fleet Trip Log (Newest First)',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _buildTripLogCard(currencyFormatter),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 54),
            const SizedBox(height: 12),
            Text(
              'Dashboard Sync Error:\n$_errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _fetchDashboardData(),
              child: const Text('Retry Connection'),
            ),
          ],
        ),
      ),
    );
  }

  // TOP: Summary Cards
  Widget _buildSummaryRow(NumberFormat currencyFormatter) {
    return Row(
      children: [
        // Active Trips Count Card
        Expanded(
          child: Card(
            elevation: 3,
            color: Colors.green.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.navigation, color: Colors.green, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ACTIVE TRIPS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(height: 4),
                      Text('$_activeCount', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Total Fleet Count Card
        Expanded(
          child: Card(
            elevation: 3,
            color: Colors.blue.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.local_shipping, color: Colors.blue, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('FLEET TRUCKS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                      const SizedBox(height: 4),
                      Text('${_trucks.length}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Total Earnings Card
        Expanded(
          child: Card(
            elevation: 3,
            color: Colors.amber.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.payments, color: Colors.amber, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TOTAL EARNINGS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber)),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(_totalEarnings),
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // MIDDLE: Fleet Status Table
  Widget _buildFleetStatusCard() {
    // Map active trips by truck_id for quick lookup
    final Map<int, Trip> activeTripsByTruck = {
      for (var trip in _activeTrips) trip.truckId: trip
    };

    if (_trucks.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: Text('No trucks found in fleet. Click "Add Truck" above to register one.')),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
          columns: const [
            DataColumn(label: Text('Truck ID', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Plate Number', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Driver Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Rate (LKR/km)', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Live Status & Route', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _trucks.map((truck) {
            final activeTrip = activeTripsByTruck[truck.id];
            final bool isOnTrip = activeTrip != null;

            return DataRow(
              cells: [
                DataCell(Text('#${truck.id}')),
                DataCell(Text(truck.plateNumber, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(truck.driverName)),
                DataCell(Text('LKR ${truck.ratePerKm.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600))),
                DataCell(
                  isOnTrip
                      ? Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(6)),
                              child: const Text('🟢 On Trip', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${activeTrip.startLocation} ➔ ${activeTrip.endLocation}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)),
                          child: const Text('🅿️ Idle', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // BOTTOM: All Trips Log Table
  Widget _buildTripLogCard(NumberFormat currencyFormatter) {
    if (_allTrips.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: Text('No trip records logged yet.')),
        ),
      );
    }

    final Map<int, Truck> truckMap = {
      for (var t in _trucks) t.id: t
    };

    return Card(
      elevation: 2,
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
          columns: const [
            DataColumn(label: Text('Trip ID', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Truck / Driver', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Route', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Distance', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Fare (LKR)', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _allTrips.map((trip) {
            final truck = trip.truck ?? truckMap[trip.truckId];
            final plate = truck?.plateNumber ?? 'Truck #${trip.truckId}';
            final driver = truck?.driverName ?? '-';
            final isCompleted = trip.status == 'completed';

            return DataRow(
              cells: [
                DataCell(Text('#${trip.id}')),
                DataCell(Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plate, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(driver, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                )),
                DataCell(Text('${trip.startLocation} ➔ ${trip.endLocation}')),
                DataCell(Text(trip.distanceKm != null ? '${trip.distanceKm!.toStringAsFixed(1)} km' : '-')),
                DataCell(Text(
                  trip.fare != null ? currencyFormatter.format(trip.fare) : '-',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                )),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.blue.shade100 : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      trip.status.toUpperCase(),
                      style: TextStyle(
                        color: isCompleted ? Colors.blue.shade900 : Colors.green.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Helper class for Future.wait with typed records
class Promise {
  static Future<List<dynamic>> all(List<Future<dynamic>> futures) {
    return Future.wait(futures);
  }
}

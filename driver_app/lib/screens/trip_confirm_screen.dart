import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../models/truck.dart';
import '../services/api_service.dart';
import 'truck_select_screen.dart';

class TripConfirmScreen extends StatefulWidget {
  final Trip trip;
  final Truck truck;
  final double simulatedDistanceKm;

  const TripConfirmScreen({
    Key? key,
    required this.trip,
    required this.truck,
    required this.simulatedDistanceKm,
  }) : super(key: key);

  @override
  State<TripConfirmScreen> createState() => _TripConfirmScreenState();
}

class _TripConfirmScreenState extends State<TripConfirmScreen> {
  late TextEditingController _distanceController;
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;
  late double _finalDistanceKm;

  @override
  void initState() {
    super.initState();
    _finalDistanceKm = widget.simulatedDistanceKm;
    _distanceController = TextEditingController(
      text: _finalDistanceKm.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _distanceController.dispose();
    super.dispose();
  }

  double get _calculatedFare => _finalDistanceKm * widget.truck.ratePerKm;

  Future<void> _handleConfirmAndClose() async {
    final dist = double.tryParse(_distanceController.text.trim());
    if (dist == null || dist <= 0) {
      setState(() {
        _errorMessage = 'Please enter a valid distance greater than 0 km.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _apiService.endTrip(
        tripId: widget.trip.id,
        distanceKm: dist,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Trip #${widget.trip.id} completed! Final Fare: LKR ${_calculatedFare.toStringAsFixed(2)}'),
          backgroundColor: Colors.green,
        ),
      );

      // Return all the way to TruckSelectScreen / Idle Start
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const TruckSelectScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Trip #${widget.trip.id}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Route & Truck Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Truck: ${widget.truck.plateNumber} (${widget.truck.driverName})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('Route: ${widget.trip.startLocation} ➔ ${widget.trip.endLocation}'),
                    Text('Rate: LKR ${widget.truck.ratePerKm} / km'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Distance Override Input Field
            const Text(
              'Confirm Final Distance (Manual Override):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _distanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Distance (km)',
                suffixText: 'km',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_road),
              ),
              onChanged: (val) {
                final d = double.tryParse(val);
                if (d != null && d > 0) {
                  setState(() {
                    _finalDistanceKm = d;
                  });
                }
              },
            ),

            const SizedBox(height: 24),

            // Live Calculated Fare Card
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade400),
              ),
              child: Column(
                children: [
                  const Text(
                    'CALCULATED TOTAL FARE',
                    style: TextStyle(color: Colors.brown, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'LKR ${_calculatedFare.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
                  ),
                  Text(
                    '(${_finalDistanceKm.toStringAsFixed(1)} km × LKR ${widget.truck.ratePerKm}/km)',
                    style: const TextStyle(color: Colors.brown, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Confirm Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleConfirmAndClose,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_circle),
              label: Text(
                _isLoading ? 'Completing Trip...' : 'Confirm and Close Trip',
                style: const TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/truck.dart';
import '../services/api_service.dart';
import 'active_trip_screen.dart';

class TripStartScreen extends StatefulWidget {
  final Truck truck;

  const TripStartScreen({Key? key, required this.truck}) : super(key: key);

  @override
  State<TripStartScreen> createState() => _TripStartScreenState();
}

class _TripStartScreenState extends State<TripStartScreen> {
  final _formKey = GlobalKey<FormState>();
  final _startLocationController = TextEditingController();
  final _endLocationController = TextEditingController();
  final _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _startLocationController.dispose();
    _endLocationController.dispose();
    super.dispose();
  }

  Future<void> _handleStartTrip() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final trip = await _apiService.startTrip(
        truckId: widget.truck.id,
        startLocation: _startLocationController.text.trim(),
        endLocation: _endLocationController.text.trim(),
      );

      if (!mounted) return;

      // Navigate to Active Trip screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ActiveTripScreen(
            trip: trip,
            truck: widget.truck,
          ),
        ),
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
        title: Text('Start Trip: ${widget.truck.plateNumber}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Selected Truck Summary Card
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_shipping, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            widget.truck.plateNumber,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Driver: ${widget.truck.driverName}'),
                      Text(
                        'Rate: LKR ${widget.truck.ratePerKm} / km',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

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
                      const Icon(Icons.warning_amber_rounded, color: Colors.red),
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

              // Start Location Input
              TextFormField(
                controller: _startLocationController,
                decoration: const InputDecoration(
                  labelText: 'Start Location',
                  hintText: 'e.g. Colombo Fort',
                  prefixIcon: Icon(Icons.location_on_outlined, color: Colors.green),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a start location';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // End Location Input
              TextFormField(
                controller: _endLocationController,
                decoration: const InputDecoration(
                  labelText: 'Destination / End Location',
                  hintText: 'e.g. Kandy Town',
                  prefixIcon: Icon(Icons.flag_outlined, color: Colors.red),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a destination location';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 28),

              // Submit Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleStartTrip,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(
                  _isLoading ? 'Starting Trip...' : 'Start Trip',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

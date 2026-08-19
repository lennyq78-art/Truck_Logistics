import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddTruckDialog extends StatefulWidget {
  final VoidCallback onTruckAdded;

  const AddTruckDialog({Key? key, required this.onTruckAdded}) : super(key: key);

  @override
  State<AddTruckDialog> createState() => _AddTruckDialogState();
}

class _AddTruckDialogState extends State<AddTruckDialog> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final _driverController = TextEditingController();
  final _rateController = TextEditingController();
  final _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _plateController.dispose();
    _driverController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rate = double.parse(_rateController.text.trim());
      await _apiService.createTruck(
        plateNumber: _plateController.text.trim(),
        driverName: _driverController.text.trim(),
        ratePerKm: rate,
      );

      if (!mounted) return;
      widget.onTruckAdded();
      Navigator.of(context).pop();
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
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.local_shipping, color: Colors.blue),
          SizedBox(width: 8),
          Text('Add New Truck to Fleet'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _plateController,
                decoration: const InputDecoration(
                  labelText: 'Plate Number / Name',
                  hintText: 'e.g. WP CAD-9999',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter plate number' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _driverController,
                decoration: const InputDecoration(
                  labelText: 'Driver Full Name',
                  hintText: 'e.g. Nuwan Silva',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter driver name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rateController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Rate Per Km (LKR)',
                  hintText: 'e.g. 180.0',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter rate per km';
                  final r = double.tryParse(val.trim());
                  if (r == null || r <= 0) return 'Enter valid rate > 0';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
          child: _isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Add Truck'),
        ),
      ],
    );
  }
}

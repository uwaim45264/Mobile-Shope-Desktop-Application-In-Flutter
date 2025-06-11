import 'package:flutter/material.dart';
import '../models/mobile.dart';

class AddMobileScreen extends StatefulWidget {
  @override
  _AddMobileScreenState createState() => _AddMobileScreenState();
}

class _AddMobileScreenState extends State<AddMobileScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'model': TextEditingController(),
    'price': TextEditingController(),
    'barcode': TextEditingController(),
    'imei1': TextEditingController(),
    'imei2': TextEditingController(),
    'ram': TextEditingController(),
    'storage': TextEditingController(),
    'cpu': TextEditingController(),
    'color': TextEditingController(),
    'chipset': TextEditingController(),
    'gpu': TextEditingController(),
    'camera': TextEditingController(),
    'screenSize': TextEditingController(),
    'battery': TextEditingController(),
    'stockQuantity': TextEditingController(),
  };

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Add Mobile Phone',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.indigo[700],
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Enter Mobile Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                ),
              ),
              const SizedBox(height: 20),
              ..._controllers.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextFormField(
                  controller: entry.value,
                  decoration: InputDecoration(
                    labelText: entry.key[0].toUpperCase() +
                        entry.key.substring(1).replaceAllMapped(
                          RegExp(r'([A-Z])'),
                              (match) => ' ${match[1]}',
                        ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(
                      _getIconForField(entry.key),
                      color: Colors.indigo[700],
                    ),
                  ),
                  keyboardType: entry.key == 'price' || entry.key == 'stockQuantity'
                      ? TextInputType.number
                      : TextInputType.text,
                  validator: (value) {
                    if (value!.isEmpty) return 'Required';
                    if (entry.key == 'stockQuantity' &&
                        (int.tryParse(value) == null || int.parse(value) < 0)) {
                      return 'Enter a valid number';
                    }
                    if (entry.key == 'price' && double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
              )),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final mobile = Mobile(
                          model: _controllers['model']!.text,
                          price: double.parse(_controllers['price']!.text),
                          barcode: _controllers['barcode']!.text,
                          imei1: _controllers['imei1']!.text,
                          imei2: _controllers['imei2']!.text,
                          ram: _controllers['ram']!.text,
                          storage: _controllers['storage']!.text,
                          cpu: _controllers['cpu']!.text,
                          color: _controllers['color']!.text,
                          chipset: _controllers['chipset']!.text,
                          gpu: _controllers['gpu']!.text,
                          camera: _controllers['camera']!.text,
                          screenSize: _controllers['screenSize']!.text,
                          battery: _controllers['battery']!.text,
                          stockQuantity: int.parse(_controllers['stockQuantity']!.text),
                        );
                        Navigator.pop(context, mobile);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForField(String field) {
    switch (field) {
      case 'model':
        return Icons.phone_android;
      case 'price':
        return Icons.attach_money;
      case 'barcode':
        return Icons.qr_code;
      case 'imei1':
      case 'imei2':
        return Icons.confirmation_number;
      case 'ram':
        return Icons.memory;
      case 'storage':
        return Icons.storage;
      case 'cpu':
        return Icons.speed;
      case 'color':
        return Icons.color_lens;
      case 'chipset':
        return Icons.developer_board;
      case 'gpu':
        return Icons.videocam;
      case 'camera':
        return Icons.camera_alt;
      case 'screenSize':
        return Icons.fullscreen;
      case 'battery':
        return Icons.battery_full;
      case 'stockQuantity':
        return Icons.inventory;
      default:
        return Icons.info;
    }
  }
}
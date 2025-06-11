import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mobile.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  _InvoiceScreenState createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  List<List<Mobile>> invoices = [];

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  _loadInvoices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? invoiceList = prefs.getStringList('invoices');
    if (invoiceList != null) {
      setState(() {
        invoices = invoiceList
            .map((e) => (jsonDecode(e) as List)
            .map((i) => Mobile.fromJson(i))
            .toList())
            .toList();
      });
    }
  }

  _resetInvoices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('invoices');
    setState(() {
      invoices = [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All invoices have been reset.'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  _showLoginForReset() {
    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _passcodeController = TextEditingController();
    final String _correctUsername = 'uwaim';
    final String _correctPasscode = '1';
    bool _isPasswordVisible = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Authorize Reset', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passcodeController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Passcode',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_usernameController.text == _correctUsername &&
                    _passcodeController.text == _correctPasscode) {
                  Navigator.pop(context);
                  _showResetConfirmation();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Incorrect username or passcode'),
                      backgroundColor: Colors.red.shade600,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Invoices', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to reset all invoices? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              _resetInvoices();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Invoices', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore, color: Colors.white),
            tooltip: 'Reset Invoices',
            onPressed: invoices.isNotEmpty ? _showLoginForReset : null,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: invoices.isEmpty
            ? Center(
          child: Text(
            'No invoices available.',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: invoices.length,
          itemBuilder: (context, index) {
            final invoice = invoices[index];
            return ExpansionTile(
              backgroundColor: Colors.white,
              collapsedBackgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                'Invoice #${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(
                'Total: \RS ${invoice.fold(0.0, (sum, item) => sum + item.price).toStringAsFixed(2)}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              children: invoice
                  .map(
                    (mobile) => Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mobile.model,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow('Price', '\RS ${mobile.price}', Colors.green.shade600),
                        _buildDetailRow('Barcode', mobile.barcode),
                        _buildDetailRow('IMEI 1', mobile.imei1),
                        _buildDetailRow('IMEI 2', mobile.imei2),
                        _buildDetailRow('RAM', mobile.ram),
                        _buildDetailRow('Storage', mobile.storage),
                        _buildDetailRow('CPU', mobile.cpu),
                        _buildDetailRow('Color', mobile.color),
                        _buildDetailRow('Chipset', mobile.chipset),
                        _buildDetailRow('GPU', mobile.gpu),
                        _buildDetailRow('Camera', mobile.camera),
                        _buildDetailRow('Screen Size', mobile.screenSize),
                        _buildDetailRow('Battery', mobile.battery),
                      ],
                    ),
                  ),
                ),
              )
                  .toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: valueColor ?? Colors.black87,
              fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
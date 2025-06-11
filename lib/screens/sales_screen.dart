import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List<Map<String, dynamic>> sales = [];
  double totalSalesPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  _loadSales() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? salesList = prefs.getStringList('sales');
    if (salesList != null) {
      setState(() {
        sales = salesList.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
        _calculateTotalPriceSilently();
      });
    }
  }

  List<Map<String, dynamic>> _getSoldItems() => sales;

  void _calculateTotalPriceSilently() {
    double sum = 0.0;
    for (var sale in sales) {
      sum += (sale['price'] as num?)?.toDouble() ?? 0.0;
    }
    totalSalesPrice = sum;
  }

  void _calculateTotalPrice() {
    _calculateTotalPriceSilently();
    _showTotalPriceDialog(totalSalesPrice);
  }

  void _showTotalPriceDialog(double total) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calculate, size: 50, color: Colors.indigo[700]),
              const SizedBox(height: 10),
              Text(
                'Total Sales Price',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Total price of all sold mobiles:',
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 5),
              Text(
                '\RS ${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetSalesData() {
    final usernameController = TextEditingController();
    final passcodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reset Sales Data',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Enter credentials to reset all sales data:',
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                  prefixIcon: Icon(Icons.person, color: Colors.indigo[700]),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passcodeController,
                decoration: InputDecoration(
                  labelText: 'Passcode',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                  prefixIcon: Icon(Icons.lock, color: Colors.indigo[700]),
                ),
                obscureText: true,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (usernameController.text == 'uwaim' && passcodeController.text == '1') {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.remove('sales');
                        setState(() {
                          sales.clear();
                          totalSalesPrice = 0.0;
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sales data reset successfully')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid username or passcode')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Reset', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final soldItems = _getSoldItems();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Sales Report',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.indigo[700],
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate, color: Colors.white),
            tooltip: 'Calculate Total Price',
            onPressed: _calculateTotalPrice,
          ),
          IconButton(
            icon: const Icon(Icons.restore, color: Colors.white),
            tooltip: 'Reset Sales Data',
            onPressed: _resetSalesData,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey[300]!, blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Sales:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo[900]),
                ),
                Text(
                  '\RS ${totalSalesPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700]),
                ),
              ],
            ),
          ),
          Expanded(
            child: soldItems.isEmpty
                ? Center(
              child: Text(
                'No mobiles sold yet',
                style: TextStyle(fontSize: 18, color: Colors.grey[600], fontStyle: FontStyle.italic),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: soldItems.length,
              itemBuilder: (context, index) {
                final sale = soldItems[index];
                final model = sale['model'] as String;
                final timestamp = DateTime.parse(sale['timestamp'] as String);
                final price = (sale['price'] as num?)?.toDouble() ?? 0.0;
                return _buildSaleCard(model, timestamp, price);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleCard(String model, DateTime timestamp, double price) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.phone_android, color: Colors.indigo[700], size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo[900]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sold on: ${timestamp.toString().substring(0, 19)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    'Price: \RS ${price.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 14, color: Colors.green[700], fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
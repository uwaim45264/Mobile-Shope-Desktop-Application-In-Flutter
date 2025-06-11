import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mobile.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<Map<String, dynamic>> sales = [];
  List<Mobile> mobiles = [];
  DateTime lastUpdated = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? salesList = prefs.getStringList('sales');
    List<String>? mobileList = prefs.getStringList('mobiles');
    setState(() {
      if (salesList != null) {
        sales = salesList.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
      }
      if (mobileList != null) {
        mobiles = mobileList.map((e) => Mobile.fromJson(jsonDecode(e))).toList();
      }
      lastUpdated = DateTime.now();
    });
  }

  // Reset both sales and mobiles data
  void _resetData() async {
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
                'Reset Analytics Data',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Enter credentials to reset all analytics data:',
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
                        await prefs.remove('mobiles');
                        setState(() {
                          sales.clear();
                          mobiles.clear();
                          lastUpdated = DateTime.now();
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Analytics data reset successfully')),
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

  List<PieChartSectionData> _getSalesPieData() {
    Map<String, double> salesByModel = {};
    for (var sale in sales) {
      final model = sale['model'] as String;
      final price = (sale['price'] as num?)?.toDouble() ?? 0.0;
      salesByModel[model] = (salesByModel[model] ?? 0) + price;
    }

    final totalSales = salesByModel.values.fold(0.0, (a, b) => a + b);
    if (totalSales == 0) {
      return [
        PieChartSectionData(
          value: 1,
          color: Colors.grey[400],
          title: 'No Sales',
          radius: 100,
          titleStyle: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
        )
      ];
    }

    return salesByModel.entries.map((entry) {
      final percentage = (entry.value / totalSales) * 100;
      return PieChartSectionData(
        value: entry.value,
        title: '${entry.key}\n${percentage.toStringAsFixed(1)}%',
        color: Colors.primaries[salesByModel.keys.toList().indexOf(entry.key) % Colors.primaries.length],
        radius: 100,
        titleStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
      );
    }).toList();
  }

  List<PieChartSectionData> _getStockPieData() {
    Map<String, int> stockByModel = {};
    for (var mobile in mobiles) {
      stockByModel[mobile.model] = (stockByModel[mobile.model] ?? 0) + mobile.stockQuantity;
    }

    final totalStock = stockByModel.values.fold(0, (a, b) => a + b);
    if (totalStock == 0) {
      return [
        PieChartSectionData(
          value: 1,
          color: Colors.grey[400],
          title: 'No Stock',
          radius: 100,
          titleStyle: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
        )
      ];
    }

    return stockByModel.entries.map((entry) {
      final percentage = (entry.value / totalStock) * 100;
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.key}\n${percentage.toStringAsFixed(1)}%',
        color: Colors.primaries[stockByModel.keys.toList().indexOf(entry.key) % Colors.primaries.length],
        radius: 100,
        titleStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Analytics Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.indigo[700],
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore, color: Colors.white),
            tooltip: 'Reset Analytics Data',
            onPressed: _resetData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
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
                    'Last Updated:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo[900]),
                  ),
                  Text(
                    lastUpdated.toString().substring(0, 19),
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            _buildChartSection(
              title: 'Sales Distribution',
              subtitle: 'Breakdown of sales by model (based on price)',
              pieData: _getSalesPieData(),
            ),
            _buildChartSection(
              title: 'Stock Distribution',
              subtitle: 'Breakdown of stock by model',
              pieData: _getStockPieData(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection({
    required String title,
    required String subtitle,
    required List<PieChartSectionData> pieData,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey[300]!, blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sections: pieData,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
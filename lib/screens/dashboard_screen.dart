import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mobile.dart';
import 'add_mobile_screen.dart';
import 'analytics_screen.dart';
import 'cart_screen.dart';
import 'sales_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  List<Mobile> mobiles = [];
  List<Mobile> cart = [];
  TextEditingController searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    _loadMobiles();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _blinkAnimation =
        Tween<double>(begin: 0.2, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    searchController.dispose();
    super.dispose();
  }

  _loadMobiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? mobileList = prefs.getStringList('mobiles');
    if (mobileList != null) {
      setState(() {
        mobiles = mobileList.map((e) => Mobile.fromJson(jsonDecode(e))).toList();
      });
    }
  }

  _saveMobiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> mobileList = mobiles.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('mobiles', mobileList);
  }

  _recordSale(Mobile mobile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> sales = prefs.getStringList('sales') ?? [];
    Map<String, dynamic> saleData = {
      'model': mobile.model,
      'price': mobile.price,
      'timestamp': DateTime.now().toIso8601String(),
    };
    sales.add(jsonEncode(saleData));
    await prefs.setStringList('sales', sales);
  }

  bool _hasLowStock() {
    return mobiles
        .any((mobile) => mobile.stockQuantity <= 3 && mobile.stockQuantity > 0);
  }

  String _getLowStockMessage() {
    final lowStockItems = mobiles
        .where((mobile) => mobile.stockQuantity <= 3 && mobile.stockQuantity > 0)
        .map((mobile) => '${mobile.model} (${mobile.stockQuantity} left)')
        .toList();
    return 'Low Stock Alert:\n${lowStockItems.join('\n')}';
  }

  bool _matchesSearch(Mobile mobile, String searchText) {
    if (searchText.isEmpty) return true;
    final lowerSearch = searchText.toLowerCase();
    return mobile.model.toLowerCase().contains(lowerSearch) ||
        mobile.price.toString().contains(lowerSearch) ||
        mobile.barcode.toLowerCase().contains(lowerSearch) ||
        mobile.imei1.toLowerCase().contains(lowerSearch) ||
        mobile.imei2.toLowerCase().contains(lowerSearch) ||
        mobile.ram.toLowerCase().contains(lowerSearch) ||
        mobile.storage.toLowerCase().contains(lowerSearch) ||
        mobile.cpu.toLowerCase().contains(lowerSearch) ||
        mobile.color.toLowerCase().contains(lowerSearch) ||
        mobile.chipset.toLowerCase().contains(lowerSearch) ||
        mobile.gpu.toLowerCase().contains(lowerSearch) ||
        mobile.camera.toLowerCase().contains(lowerSearch) ||
        mobile.screenSize.toLowerCase().contains(lowerSearch) ||
        mobile.battery.toLowerCase().contains(lowerSearch);
  }

  void _showEditDialog(Mobile mobile, int index) {
    final _formKey = GlobalKey<FormState>();
    final controllers = {
      'model': TextEditingController(text: mobile.model),
      'price': TextEditingController(text: mobile.price.toString()),
      'barcode': TextEditingController(text: mobile.barcode),
      'imei1': TextEditingController(text: mobile.imei1),
      'imei2': TextEditingController(text: mobile.imei2),
      'ram': TextEditingController(text: mobile.ram),
      'storage': TextEditingController(text: mobile.storage),
      'cpu': TextEditingController(text: mobile.cpu),
      'color': TextEditingController(text: mobile.color),
      'chipset': TextEditingController(text: mobile.chipset),
      'gpu': TextEditingController(text: mobile.gpu),
      'camera': TextEditingController(text: mobile.camera),
      'screenSize': TextEditingController(text: mobile.screenSize),
      'battery': TextEditingController(text: mobile.battery),
      'stockQuantity': TextEditingController(text: mobile.stockQuantity.toString()),
    };

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Mobile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[900],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...controllers.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TextFormField(
                      controller: entry.value,
                      decoration: InputDecoration(
                        labelText: entry.key[0].toUpperCase() + entry.key.substring(1).replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match[1]}'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      keyboardType: entry.key.contains('price') || entry.key.contains('stockQuantity') ? TextInputType.number : TextInputType.text,
                      validator: (value) => value!.isEmpty ? 'Required' : (entry.key == 'stockQuantity' && (int.tryParse(value) == null || int.parse(value) < 0) ? 'Enter a valid number' : null),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              mobiles[index] = Mobile(
                                model: controllers['model']!.text,
                                price: double.parse(controllers['price']!.text),
                                barcode: controllers['barcode']!.text,
                                imei1: controllers['imei1']!.text,
                                imei2: controllers['imei2']!.text,
                                ram: controllers['ram']!.text,
                                storage: controllers['storage']!.text,
                                cpu: controllers['cpu']!.text,
                                color: controllers['color']!.text,
                                chipset: controllers['chipset']!.text,
                                gpu: controllers['gpu']!.text,
                                camera: controllers['camera']!.text,
                                screenSize: controllers['screenSize']!.text,
                                battery: controllers['battery']!.text,
                                stockQuantity: int.parse(controllers['stockQuantity']!.text),
                              );
                              _saveMobiles();
                            });
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo[700],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Save', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showOutOfStockDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, size: 50, color: Colors.red[400]),
              const SizedBox(height: 10),
              Text(
                'Out of Stock',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo[900]),
              ),
              const SizedBox(height: 10),
              Text(
                'This item is out of stock and cannot be added to the cart.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
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

  void _showDeleteConfirmation(Mobile mobile, int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, size: 50, color: Colors.red[400]),
              const SizedBox(height: 10),
              Text(
                'Confirm Deletion',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo[900]),
              ),
              const SizedBox(height: 10),
              Text(
                'Are you sure you want to delete "${mobile.model}"? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
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
                    onPressed: () {
                      setState(() {
                        mobiles.removeAt(index);
                        _saveMobiles();
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Delete', style: TextStyle(color: Colors.white)),
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Mohsin Mobile Shop Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.indigo[700],
        elevation: 0,
        leading: _hasLowStock()
            ? FadeTransition(
          opacity: _blinkAnimation,
          child: Tooltip(
            message: _getLowStockMessage(),
            child: IconButton(
              icon: Icon(Icons.warning_amber_rounded, color: Colors.red[400]),
              onPressed: () {},
            ),
          ),
        )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SalesScreen())),
            tooltip: 'Sales Report',
          ),
          IconButton(
            icon: const Icon(Icons.analytics, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AnalyticsScreen())),
            tooltip: 'Analytics',
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart, color: Colors.white),
                if (cart.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${cart.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CartScreen(cart: cart))).then((value) {
                if (value != null) setState(() => cart = value);
              });
            },
            tooltip: 'Cart',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text(
                    'Developer Info',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Developer: Muhammad Uwaim Qureshi', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                      Text('Role: Software Engineer, Flutter Developer', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                      Text('Contact: unknownmuq@gmail.com', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close', style: TextStyle(color: Colors.indigo)),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'About Developer',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Mobile',
                      hintText: 'Search by any detail...',
                      prefixIcon: Icon(Icons.search, color: Colors.indigo[700]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddMobileScreen())).then((newMobile) {
                      if (newMobile != null) {
                        setState(() {
                          mobiles.add(newMobile);
                          _saveMobiles();
                        });
                      }
                    });
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Add Mobile', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: mobiles.isEmpty
                ? Center(
              child: Text(
                'No mobiles added yet',
                style: TextStyle(fontSize: 18, color: Colors.grey[600], fontStyle: FontStyle.italic),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: mobiles.length,
              itemBuilder: (context, index) {
                final mobile = mobiles[index];
                if (!_matchesSearch(mobile, searchController.text)) return const SizedBox.shrink();
                return _buildMobileCard(mobile, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCard(Mobile mobile, int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  mobile.model,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo[900]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: mobile.stockQuantity <= 3 ? Colors.red[100] : Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Stock: ${mobile.stockQuantity}',
                    style: TextStyle(
                      color: mobile.stockQuantity <= 3 ? Colors.red[700] : Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildSpecRow('Price', '\RS ${mobile.price}', Colors.green[700]!),
            _buildSpecRow('Barcode', mobile.barcode, Colors.grey[800]!),
            _buildSpecRow('IMEI 1', mobile.imei1, Colors.grey[800]!),
            _buildSpecRow('IMEI 2', mobile.imei2, Colors.grey[800]!),
            _buildSpecRow('RAM', mobile.ram, Colors.grey[800]!),
            _buildSpecRow('Storage', mobile.storage, Colors.grey[800]!),
            _buildSpecRow('Color', mobile.color, Colors.grey[800]!),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  icon: Icons.add_shopping_cart,
                  color: Colors.teal[400]!,
                  onPressed: () {
                    setState(() {
                      if (mobile.stockQuantity > 0) {
                        mobile.stockQuantity--;
                        cart.add(mobile);
                        _recordSale(mobile);
                        _saveMobiles();
                        if (mobile.stockQuantity == 0) _showOutOfStockDialog();
                      } else {
                        _showOutOfStockDialog();
                      }
                    });
                  },
                  tooltip: 'Add to Cart',
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.edit,
                  color: Colors.blue[400]!,
                  onPressed: () => _showEditDialog(mobile, index),
                  tooltip: 'Edit',
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.delete,
                  color: Colors.red[400]!,
                  onPressed: () => _showDeleteConfirmation(mobile, index),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required Color color, required VoidCallback onPressed, required String tooltip}) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
      ),
    );
  }
}
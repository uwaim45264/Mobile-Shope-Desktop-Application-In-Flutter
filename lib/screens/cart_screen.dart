import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/mobile.dart';
import 'invoice_screen.dart';

class CartScreen extends StatefulWidget {
  final List<Mobile> cart;

  CartScreen({required this.cart});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Soft background
      appBar: AppBar(
        title: const Text(
          'Your Cart',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo[700],
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.cart.isEmpty
                ? Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.cart.length,
              itemBuilder: (context, index) {
                final mobile = widget.cart[index];
                return _buildCartItem(mobile, index);
              },
            ),
          ),
          _buildCheckoutSection(context),
        ],
      ),
    );
  }

  Widget _buildCartItem(Mobile mobile, int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mobile.model,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSpecRow('Price', 'RS ${mobile.price}', Colors.green[700]!),
                  _buildSpecRow('Barcode', mobile.barcode, Colors.grey[800]!),
                  _buildSpecRow('IMEI 1', mobile.imei1, Colors.grey[800]!),
                  _buildSpecRow('IMEI 2', mobile.imei2, Colors.grey[800]!),
                  _buildSpecRow('RAM', mobile.ram, Colors.grey[800]!),
                  _buildSpecRow('Storage', mobile.storage, Colors.grey[800]!),
                  _buildSpecRow('Color', mobile.color, Colors.grey[800]!),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.remove_circle, color: Colors.red[400]),
              onPressed: () {
                setState(() {
                  widget.cart.removeAt(index);
                });
              },
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
          Text(
            '$label: ',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey[300]!, blurRadius: 10, offset: const Offset(0, -5))],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo[900]),
              ),
              Text(
                'RS ${widget.cart.fold(0.0, (sum, item) => sum + item.price).toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700]),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: widget.cart.isEmpty
                ? null
                : () => _showInvoiceDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo[700],
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 5,
            ),
            child: const Text(
              'Place Order',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showInvoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invoice Preview',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[900],
                  ),
                ),
                const SizedBox(height: 15),
                ...widget.cart.map((mobile) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        mobile.model,
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                      Text(
                        'RS ${mobile.price}',
                        style: TextStyle(fontSize: 16, color: Colors.green[700]),
                      ),
                    ],
                  ),
                )),
                Divider(color: Colors.grey[300]),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo[900]),
                    ),
                    Text(
                      'RS ${widget.cart.fold(0.0, (sum, item) => sum + item.price).toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDialogButton('Save', Colors.blue, () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      List<String> invoices = prefs.getStringList('invoices') ?? [];
                      invoices.add(jsonEncode(widget.cart.map((e) => e.toJson()).toList()));
                      await prefs.setStringList('invoices', invoices);
                      Navigator.pop(dialogContext);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const InvoiceScreen()));
                    }),
                    _buildDialogButton('Print', Colors.teal, () async {
                      await _printInvoice();
                      Navigator.pop(dialogContext);
                    }),
                    _buildDialogButton('Close', Colors.grey, () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context, widget.cart);
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  Future<void> _printInvoice() async {
    final pdf = pw.Document();
    const PdfColor headerColor = PdfColor.fromInt(0xFF1E88E5);
    const PdfColor accentColor = PdfColor.fromInt(0xFFBBDEFB);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: headerColor,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Mobile Shop Invoice',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.Text(
                'Date: ${DateTime.now().toString().substring(0, 19)}',
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.white),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ),
        build: (pw.Context context) => [
          pw.SizedBox(height: 20),
          pw.Text(
            'Invoice Details',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: headerColor,
            ),
          ),
          pw.SizedBox(height: 15),
          ...widget.cart.map((mobile) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 10),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: headerColor),
              borderRadius: pw.BorderRadius.circular(8),
              color: accentColor,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  mobile.model,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: headerColor,
                  ),
                ),
                pw.Divider(color: headerColor),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Price: RS ${mobile.price.toStringAsFixed(2)}'),
                    pw.Text('Barcode: ${mobile.barcode}'),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('IMEI 1: ${mobile.imei1}'),
                    pw.Text('IMEI 2: ${mobile.imei2}'),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Text('RAM: ${mobile.ram}'),
                pw.Text('Storage: ${mobile.storage}'),
                pw.Text('CPU: ${mobile.cpu}'),
                pw.SizedBox(height: 5),
                pw.Text('Color: ${mobile.color}'),
                pw.Text('Chipset: ${mobile.chipset}'),
                pw.Text('GPU: ${mobile.gpu}'),
                pw.SizedBox(height: 5),
                pw.Text('Camera: ${mobile.camera}'),
                pw.Text('Screen Size: ${mobile.screenSize}'),
                pw.Text('Battery: ${mobile.battery}'),
              ],
            ),
          )),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: headerColor,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Total Amount',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.Text(
                  'RS ${widget.cart.fold(0.0, (sum, item) => sum + item.price).toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Thank you for your purchase!',
            style: pw.TextStyle(
              fontSize: 12,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey700,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      bool printed = false;
      try {
        printed = await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
        if (printed) return;
      } catch (e) {
        print('Direct printing error: $e');
      }

      if (Platform.isWindows) {
        final result = await Process.run('start', ['""', file.path], runInShell: true);
        if (result.exitCode != 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved to ${file.path}. Open manually to print.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to ${file.path}. Open manually to print.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to process print: $e')),
      );
    }
  }
}
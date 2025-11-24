import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class OrganizerTicketScannerPage extends StatefulWidget {
  const OrganizerTicketScannerPage({super.key});

  @override
  State<OrganizerTicketScannerPage> createState() => _OrganizerTicketScannerPageState();
}

class _OrganizerTicketScannerPageState extends State<OrganizerTicketScannerPage> {
  bool _scanned = false;
  Map<String, dynamic>? _ticketData;
  bool _hasPermission = false;
  bool _checkingPermission = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    setState(() {
      _checkingPermission = true;
    });
    final status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
        _checkingPermission = false;
      });
    } else {
      final result = await Permission.camera.request();
      setState(() {
        _hasPermission = result.isGranted;
        _checkingPermission = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue ?? '';
    if (code.isEmpty) return;

    setState(() {
      _scanned = true;
    });

    try {
      final data = jsonDecode(code) as Map<String, dynamic>;
      setState(() {
        _ticketData = data;
      });
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid ticket QR'), backgroundColor: Colors.red),
      );
      setState(() {
        _scanned = false;
      });
    }
  }

  void _resetScan() {
    setState(() {
      _scanned = false;
      _ticketData = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Ticket QR'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: _checkingPermission
                ? const Center(child: CircularProgressIndicator())
                : !_hasPermission
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Camera permission is required to scan tickets.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _checkPermission,
                                child: const Text('Allow Camera'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : MobileScanner(
                        onDetect: _onDetect,
                      ),
          ),
          Expanded(
            flex: 3,
            child: _ticketData == null
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Point the camera at a ticket QR code to view its details.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ticket Details',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Text('Event ID: ${_ticketData!['eventId'] ?? ''}'),
                            const SizedBox(height: 4),
                            Text('Title: ${_ticketData!['title'] ?? ''}'),
                            const SizedBox(height: 4),
                            Text('Amount: Rs. ${_ticketData!['amount'] ?? ''}'),
                            const SizedBox(height: 4),
                            Text('Transaction ID: ${_ticketData!['transactionId'] ?? ''}'),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: _resetScan,
                                icon: const Icon(Icons.qr_code_scanner),
                                label: const Text('Scan Another'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../services/ticket_api_service.dart';
import 'ticket_page.dart';

class YourTicketsPage extends StatefulWidget {
  const YourTicketsPage({super.key});

  @override
  State<YourTicketsPage> createState() => _YourTicketsPageState();
}

class _YourTicketsPageState extends State<YourTicketsPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _tickets = [];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await TicketApiService.getMyTickets();
    if (!mounted) return;
    if (res['success'] == true) {
      setState(() {
        _tickets = (res['tickets'] as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
        _error = res['message']?.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Tickets'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _tickets.isEmpty
                  ? const Center(child: Text('You have not booked any tickets yet.'))
                  : RefreshIndicator(
                      onRefresh: _loadTickets,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _tickets.length,
                        itemBuilder: (context, index) {
                          final ticket = _tickets[index];
                          final event = (ticket['event'] ?? {}) as Map<String, dynamic>;
                          final title = (event['title'] ?? 'Event').toString();
                          final location = (event['location'] ?? '').toString();
                          final price = (event['price'] ?? ticket['amount'] ?? '').toString();
                          final createdAt = (ticket['createdAt'] ?? '').toString();
                          final eventId = (event['_id'] ?? event['id'] ?? ticket['eventId'] ?? '').toString();
                          final amountDouble = double.tryParse(price.toString()) ?? 0.0;
                          final transactionId = (ticket['transactionId'] ?? '').toString();

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: const Icon(Icons.confirmation_number_outlined, color: Colors.blue),
                              title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (location.isNotEmpty)
                                    Text(
                                      location,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 4),
                                  Text('Amount: Rs $price'),
                                  if (createdAt.isNotEmpty)
                                    Text(
                                      'Booked on: ${createdAt.split('T').first}',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                ],
                              ),
                              onTap: () {
                                if (eventId.isEmpty) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TicketPage(
                                      eventId: eventId,
                                      eventTitle: title,
                                      amount: amountDouble,
                                      transactionId: transactionId.isEmpty ? null : transactionId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

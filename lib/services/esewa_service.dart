import 'package:flutter/material.dart';
import 'package:esewa_flutter/esewa_flutter.dart';
import '../pages/ticket_page.dart';
import 'ticket_api_service.dart';

class EsewaService {
  static Future<void> payForEvent({
    required BuildContext context,
    required String eventId,
    required String title,
    required String priceText,
  }) async {
    // Parse numeric amount from price string (e.g. "Rs 500" or "500" -> 500)
    final cleaned = priceText.toLowerCase().contains('free')
        ? ''
        : priceText.replaceAll(RegExp(r'[^0-9.]'), '');
    final amount = double.tryParse(cleaned) ?? 0;

    // If no valid amount or zero, treat as free entry and do not open eSewa
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This event is free entry. No payment required.'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    try {
      final result = await Esewa.i.init(
        context: context,
        eSewaConfig: ESewaConfig.dev(
          amount: amount,
          successUrl: 'https://developer.esewa.com.np/success',
          failureUrl: 'https://developer.esewa.com.np/failure',
          secretKey: '8gBm/:&EnhH.1/q',
          // productCode defaults to EPAYTEST in dev; you can set eventId here if needed
        ),
      );

      if (result.hasData && result.data != null) {
        // Plugin returns an EsewaPaymentResponse object; we don't parse fields here yet.
        String? transactionId;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful via eSewa'),
            backgroundColor: Colors.green,
          ),
        );

        // Save ticket booking in backend (best-effort)
        TicketApiService.createTicket(
          eventId: eventId,
          amount: amount,
          transactionId: transactionId,
        );

        // Navigate to a simple ticket/invoice page for this event
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TicketPage(
              eventId: eventId,
              eventTitle: title,
              amount: amount,
              transactionId: transactionId,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${result.error ?? 'Unknown error'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

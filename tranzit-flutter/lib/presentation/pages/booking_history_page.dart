import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../infrastructure/providers/Auth.Providers/booking.provider.dart';

class BookingHistory extends StatefulWidget {
  const BookingHistory({super.key});

  @override
  State<BookingHistory> createState() => _BookingHistoryState();
}

class _BookingHistoryState extends State<BookingHistory> {
  @override
  void initState() {
    super.initState();

    // Call fetchAllTickets once here to populate provider state
    final bookingProvider = context.read<BookingProvider>();
    bookingProvider.fetchAllTickets();
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final bookingHistory = bookingProvider.BookingHistory;
    final isLoading = bookingProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Tickets",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF05424C),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookingHistory.isEmpty
          ? const Center(
        child: Text("No tickets found.",
            style: TextStyle(fontSize: 20)),
      )
          : ListView.builder(
        itemCount: bookingHistory.length,
        itemBuilder: (context, index) {
          final ticket = bookingHistory[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading:
              const Icon(Icons.directions_bus, color: Colors.blue),
              title: Text("Vehicle: ${ticket['vehicleId'] ?? 'Unknown'}"),
              subtitle: Text(
                "From: ${ticket['fromStop']?['name'] ?? 'Unknown'} "
                    "To: ${ticket['toStop']?['name'] ?? 'Unknown'}",
              ),
              trailing: Text(ticket['status'] ?? ''),
            ),
          );
        },
      ),
    );
  }
}

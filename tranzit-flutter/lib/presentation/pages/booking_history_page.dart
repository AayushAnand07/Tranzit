import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tranzit/presentation/pages/ticket_detail_screen.dart';

import '../../infrastructure/helper/date_format_helper.dart';
import '../../infrastructure/providers/Auth.Providers/booking.provider.dart';

class BookingHistory extends StatefulWidget {
  const BookingHistory({super.key});

  @override
  State<BookingHistory> createState() => _BookingHistoryState();
}

class _BookingHistoryState extends State<BookingHistory> {
  String selectedStatus = 'ACTIVE';

  @override
  void initState() {
    super.initState();
    final bookingProvider = context.read<BookingProvider>();
    bookingProvider.fetchAllTickets();
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final bookingHistory = bookingProvider.BookingHistory;

    bool isLoading = bookingProvider.isLoading;

    List filteredTickets = bookingHistory.where((ticket) {
      if (selectedStatus == 'ACTIVE') {
        return ticket['status'] != 'BOOKED';
      } else {
        return ticket['status'] == 'BOOKED';
      }
    }).toList();

    if (selectedStatus == 'ACTIVE') {
      filteredTickets.sort((a, b) {
        final aCreatedAt = a['createdAt'] as String?;
        final bCreatedAt = b['createdAt'] as String?;

        final aDate = DateTime.tryParse(aCreatedAt ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = DateTime.tryParse(bCreatedAt ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);

        return bDate.compareTo(aDate);
      });
    }

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text("Active"),
                  selected: selectedStatus == 'ACTIVE',
                  selectedColor: Color(0xFF05424C),
                  showCheckmark: false,
                  onSelected: (selected) {
                    setState(() {
                      selectedStatus = 'ACTIVE';
                    });
                  },
                  labelStyle: TextStyle(
                      color: selectedStatus == 'ACTIVE' ? Colors.white : Colors.black),
                ),
                const SizedBox(width: 14),
                ChoiceChip(
                  label: const Text("Booked"),
                  selected: selectedStatus == 'BOOKED',
                  selectedColor: Color(0xFF05424C),
                  showCheckmark: false,
                  onSelected: (selected) {
                    setState(() {
                      selectedStatus = 'BOOKED';
                    });
                  },
                  labelStyle: TextStyle(
                      color: selectedStatus == 'BOOKED' ? Colors.white : Colors.black),
                ),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTickets.isEmpty
                ? const Center(
              child: Text("No tickets found.",
                  style: TextStyle(fontSize: 20)),
            )
                : ListView.builder(
              itemCount: filteredTickets.length,
              itemBuilder: (context, index) {
                final ticket = filteredTickets[index];

                final routeStop = {
                  'fromStop': ticket['fromStop']?['name'] ?? '',
                  'toStop': ticket['toStop']?['name'] ?? '',
                };

                final qrPayload = ticket['qrPayload'] ?? '';

                String travelDate = DateTimeFormatHelper.formatDate(ticket['journeyDate']);
                String travelTimeFrom = DateTimeFormatHelper.formatTime(ticket['vehicle']['departure']);
                String travelTimeTo = DateTimeFormatHelper.formatTime(ticket['vehicle']['arrival']);
                String duration = DateTimeFormatHelper.formatTripDuration(ticket['vehicle']['departure'], ticket['vehicle']['arrival']);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TicketDetailsPage(
                          ticket['vehicle'],
                          routeStop,
                          qrPayload,
                          ticket['passengers'],
                          ticket['price']
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.lime[200],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "${ticket['vehicle']['vehicleId'] ?? ' '}",
                                style: const TextStyle(
                                  color: Color(0xFF3A4602),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 0.7,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.lime[200],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child:  Text(
                                ticket['status'],
                                style:const TextStyle(
                                  color: Color(0xFF3A4602),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ticket['fromStop']?['name']?.toString() ?? '--',
                                  style: const TextStyle(
                                    color: Color(0xFF1C5579),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  travelTimeFrom ?? '--:--',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 14),
                                      child: Icon(Icons.directions_bus, color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                                Text(
                                  duration ?? '',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  ticket['toStop']?['name']?.toString() ?? '--',
                                  style: const TextStyle(
                                    color: Color(0xFF1C5579),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  travelTimeTo ?? '--:--',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 16),
                          child: Divider(
                            color: Colors.grey[300],
                            thickness: 1,
                            height: 1,
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Date', style: TextStyle(fontWeight: FontWeight.w600)),
                                Text(travelDate ?? '--', style: TextStyle(color: Colors.grey[700])),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text('Passengers', style: TextStyle(fontWeight: FontWeight.w600)),
                                Row(
                                  children: [
                                    Icon(Icons.people, size: 16, color: Colors.grey[700]),
                                    const SizedBox(width: 4),
                                    Text((ticket['passengers']?.toString() ?? '1'),
                                        style: TextStyle(color: Colors.grey[700])),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Price', style: TextStyle(fontWeight: FontWeight.w600)),
                                Text('₹ ${ticket['price'].toString() ?? '--'}', style: TextStyle(color: Colors.grey[700])),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

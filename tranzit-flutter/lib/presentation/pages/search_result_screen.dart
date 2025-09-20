import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../infrastructure/providers/Auth.Providers/route.provider.dart';
import 'booking_detail_screen.dart';

class SearchResultsScreen extends StatefulWidget {

  SearchResultsScreen({Key? key}) : super(key: key);

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final darkTeal = const Color(0xFF165E5A);
  final yellow = const Color(0xFFEFE973);
  final lightGrey = const Color(0xFFF5F5F5);

  String formatTime(String dateStr) {
    final dt = DateTime.tryParse(dateStr);
      if (dt == null) return dateStr;
    return DateFormat.jm().format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final stops = context.watch<RouteProvider>().stops;

    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor: darkTeal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Search Results',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.tune, color: darkTeal),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Showing count
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              children: [
                Text('Showing ${stops.length} results',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16)),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.green[200],
                      borderRadius: BorderRadius.circular(16)),
                  padding:
                  const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                  child: Text('One way',
                      style: TextStyle(
                          color: darkTeal,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
                const SizedBox(width: 6),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16)),
                  padding:
                  const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                  child: Text('Round',
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              ],
            ),
          ),
          // List of stops
          Expanded(
            child: ListView.builder(
              itemCount: stops.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                final routeStop = stops[index];
                final route = routeStop['route'];
                final vehicle = routeStop['vehicle'];

                return GestureDetector(
                  onTap: ()async{
                    final routeProvider = Provider.of<RouteProvider>(context, listen: false);

                    await routeProvider.fetchStopsBetween(
                      routeId: route['id'],
                      from: routeStop['fromStop'] ?? '',
                      to: routeStop['toStop'] ?? '',
                    ).then((value) => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BookingDetailPage(route, vehicle)),
                    ));
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    color: Colors.white,
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(right: 6),
                            child: Icon(
                              Icons.directions_bus,
                              color: yellow,
                              size: 40,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: yellow,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        route['name'] ?? '',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: darkTeal),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Ticket Price',
                                      style: TextStyle(
                                          color: Colors.grey[500], fontSize: 12),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '\$${vehicle['price']?.toStringAsFixed(2) ?? '0.00'}',
                                      style: TextStyle(
                                          color: darkTeal,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                // Departure & arrival
                                Row(
                                  children: [
                                    Text(
                                      'Arriving by ',
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.grey[700]),
                                    ),
                                    Text(
                                      formatTime(vehicle['arrival'] ?? ''),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: darkTeal),
                                    ),
                                    Text(
                                      '  →  ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[600]),
                                    ),
                                    Text(
                                      formatTime(vehicle['departure'] ?? ''),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: darkTeal),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                // Direction
                                Row(
                                  children: [
                                    Text(
                                      'Direction: ${vehicle['direction'] ?? ''}',
                                      style: TextStyle(
                                          color: Colors.red[700],
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 7),
                                // Placeholder rating & reviews
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.amber, size: 18),
                                    Text(
                                      ' 3.7 ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: darkTeal),
                                    ),
                                    Text(
                                      '| 45 reviews',
                                      style: TextStyle(color: darkTeal),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

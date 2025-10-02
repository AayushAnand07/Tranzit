import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../infrastructure/helper/date_format_helper.dart';

class SearchResultCard extends StatelessWidget {
  final Map<String, dynamic> route;
  final Map<String, dynamic> vehicle;
  final Map<String, dynamic> routeStop;
  final int passengerCount;

  const SearchResultCard({
    required this.route,
    required this.vehicle,
    required this.routeStop,
    required this.passengerCount,
    Key? key,
  }) : super(key: key);

  String formatTime(String? timeStr) {
    if (timeStr == null) return '';
    try {
      var dt = DateTime.parse(timeStr);
      return DateFormat.jm().format(dt);
    } catch (_) {
      return timeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkTeal = const Color(0xFF165E5A);
    final yellow = const Color(0xFFEFE973);

    DateTime? journeyDate;
    if (vehicle['journeyDate'] != null) {
      try {
        journeyDate = DateTime.parse(vehicle['journeyDate']);
      } catch (_) {
        journeyDate = null;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 12),
              child: Icon(Icons.directions_bus, color: darkTeal, size: 38),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: yellow,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          route['name'] ?? '',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, color: darkTeal),
                        ),
                      ),
                      Spacer(),
                      Text(
                        '₹${vehicle['price']?.toStringAsFixed(2) ?? '0.00'}',
                        style: TextStyle(
                          color: darkTeal,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  if (journeyDate != null)
                    Text(
                      DateFormat('EEE, MMM d, yyyy').format(journeyDate),
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600),
                    ),
                  SizedBox(height: 12),


                  SizedBox(
                    height: 100, 
                    child: Column(
                      children: [
                        Expanded(
                          child: TimelineTile(
                            alignment: TimelineAlign.start,
                            isFirst: true,
                            indicatorStyle: IndicatorStyle(
                              color: darkTeal,
                              width: 12,
                              height: 12,
                            ),
                            beforeLineStyle: LineStyle(
                              color: Colors.grey.shade300,
                              thickness: 2,
                            ),
                            endChild: Container(
                              padding: const EdgeInsets.only(left: 16),
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    routeStop['fromStop'] ?? '',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: darkTeal),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    DateTimeFormatHelper.formatTime(vehicle['departure']),
                                    style: TextStyle(
                                        color: Colors.grey[700], fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TimelineTile(
                            alignment: TimelineAlign.start,
                            isLast: true,
                            indicatorStyle: IndicatorStyle(
                              color: darkTeal,
                              width: 12,
                              height: 12,
                            ),
                            beforeLineStyle: LineStyle(
                              color: Colors.grey.shade300,
                              thickness: 2,
                            ),
                            endChild: Container(
                              padding: const EdgeInsets.only(left: 16),
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    routeStop['toStop'] ?? '',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: darkTeal),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    DateTimeFormatHelper.formatTime(vehicle['arrival']),
                                    style: TextStyle(
                                        color: Colors.grey[700], fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 15),

                  Row(
                    children: [
                      Icon(Icons.people, color: darkTeal, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'x$passengerCount',
                        style: TextStyle(
                            color: darkTeal, fontWeight: FontWeight.w700),
                      ),
                    ],
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
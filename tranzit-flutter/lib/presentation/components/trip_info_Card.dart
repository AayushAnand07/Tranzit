import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TripInfoCard extends StatelessWidget {
  final route;
  final vehicles;
  final stopsCount;
  const TripInfoCard(this.route,this.vehicles,this.stopsCount);


  String formatTime(String dateStr) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    return DateFormat.jm().format(dt);
  }

  @override
  Widget build(BuildContext context) {
    const darkTeal = Color(0xFF165E5A);
    const yellow = Color(0xFFEFE973);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.white,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [

            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 10),
              alignment: Alignment.center,
              child: Icon(
                Icons.directions_bus,
                color: yellow,
                size: 30,
              ),
            ),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: yellow,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                             route['name'],
                          style: TextStyle(
                            color: darkTeal,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const Spacer(),


                    ],
                  ),
                  const SizedBox(height: 6),
                  // Middle: Time row
                  Row(
                    children: [
                      Text(
                        "Departure by",
                        style: TextStyle(color: Colors.grey[400],fontSize: 13),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatTime(vehicles['departure'] ?? ''),
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.arrow_right_alt, size: 18, color: Colors.grey),
                      ),
                      Text(
                        formatTime(vehicles['arrival'] ?? ''),
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        "$stopsCount Stops",
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                      const Spacer(),

                      const SizedBox(width: 4),
                      Text(
                        ' ₹${vehicles['price']?.toStringAsFixed(2) ?? '0.00'}',
                        style: TextStyle(
                          color: darkTeal,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

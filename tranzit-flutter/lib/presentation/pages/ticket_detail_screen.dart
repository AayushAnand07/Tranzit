import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tranzit/infrastructure/providers/Auth.Providers/booking.provider.dart';

import '../../infrastructure/helper/date_format_helper.dart';
import '../../infrastructure/providers/Auth.Providers/route.provider.dart'; // Add qr_flutter in pubspec.yaml

class TicketDetailsPage extends StatefulWidget {
  final vehicles;
  final routeStop;
  final qrPayload;
  final passengerCount;
  final int? totalPrice;
  TicketDetailsPage(this.vehicles,this.routeStop,this.qrPayload,this.passengerCount,this.totalPrice);

  @override
  State<TicketDetailsPage> createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {

  String getDateFromQR(String qrPayload) {
    List<String> parts = qrPayload.split('-');
    if (parts.length >= 4) {
      String dateString = parts.sublist(3).join('-');
      DateTime date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    }
    return '';
  }
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ticket Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 22),
        ),
        backgroundColor: Color(0xFF05424C),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22.0),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Ticket Conformation',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28, // increased
                        ),
                      ),
                      SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFCEEF68),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Text(
                              '${widget.vehicles['vehicleId'] ?? ''}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF05424C),
                                fontSize: 14, // increased
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFCEEF68),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Row(
                              children: [
                                Icon(Icons.people),
                                SizedBox(width: 3,),
                                Text(
                                 widget.passengerCount.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF05424C),
                                    fontSize: 14, // increased
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${widget.routeStop['fromStop'] ?? ''}',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                            ),
                          ),
                          Column(
                            children: [
                              Icon(Icons.train, color: Colors.grey[700], size: 45),
                              Text(
                                DateTimeFormatHelper.formatTripDuration(widget.vehicles['departure'],widget.vehicles['arrival']),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Text(
                              '${widget.routeStop['toStop'] ?? ''}',
                              textAlign: TextAlign.end,
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20), // increased
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              DateTimeFormatHelper.formatTime(widget.vehicles['departure']),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w700,
                                fontSize: 16, // increased
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              DateTimeFormatHelper.formatTime(widget.vehicles['arrival']),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w700,
                                fontSize: 16, // increased
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Divider(thickness: 1),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Date',
                            style: TextStyle(color: Colors.grey[800], fontSize: 16),
                          ),
                          Text(
                            'Price',
                            style: TextStyle(color: Colors.grey[800], fontSize: 16),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateTimeFormatHelper.getDateFromQR(widget.qrPayload),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '₹ ${(widget.totalPrice==null)?widget.vehicles['price']:widget.totalPrice?.toStringAsFixed(2) ?? '0.00'}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Center(
                        child: QrImageView(
                          data: widget.qrPayload,
                          size: 220, // slightly bigger
                          backgroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Scan this code to verify',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15, // increased
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF05424C),
                  padding: EdgeInsets.symmetric(horizontal: 44, vertical: 18), // slightly bigger
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'DOWNLOAD TICKET',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16), // increased
                ),
                onPressed: () {

                },
              ),
              SizedBox(height: 6),
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFF05424C), fontWeight: FontWeight.bold, fontSize: 16), // increased
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

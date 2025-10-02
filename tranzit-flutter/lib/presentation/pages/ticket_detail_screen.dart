import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';
import 'package:tranzit/infrastructure/providers/Auth.Providers/booking.provider.dart';

import '../../infrastructure/helper/date_format_helper.dart';
import '../../infrastructure/providers/Auth.Providers/route.provider.dart';

class TicketDetailsPage extends StatefulWidget {
  final vehicles;
  final routeStop;
  final qrPayload;
  final passengerCount;
  final int? totalPrice;
  TicketDetailsPage(this.vehicles, this.routeStop, this.qrPayload, this.passengerCount, this.totalPrice);

  @override
  State<TicketDetailsPage> createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {
  bool isDownloading = false;

  String getDateFromQR(String qrPayload) {
    List<String> parts = qrPayload.split('-');
    if (parts.length >= 4) {
      String dateString = parts.sublist(3).join('-');
      DateTime date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    }
    return '';
  }

  Future<void> downloadTicketAsPDF() async {
    setState(() {
      isDownloading = true;
    });

    try {
      final pdf = pw.Document();

      final qrImage = await QrPainter(
        data: widget.qrPayload,
        version: QrVersions.auto,
        gapless: true,
        color: const Color(0xFF000000),
        emptyColor: const Color(0xFFFFFFFF),
      ).toImageData(300);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Container(
              padding: pw.EdgeInsets.all(30),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [

                  pw.Text(
                    'Ticket Confirmation',
                    style: pw.TextStyle(
                      fontSize: 32,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 30),


                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Container(
                        padding: pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#CEEF68'),
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Text(
                          'Vehicle: ${widget.vehicles['vehicleId'] ?? ''}',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#CEEF68'),
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Text(
                          'Passengers: ${widget.passengerCount}',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 30),

                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          '${widget.routeStop['fromStop'] ?? ''}',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Text(
                        '→',
                        style: pw.TextStyle(fontSize: 24),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          '${widget.routeStop['toStop'] ?? ''}',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 10),


                  pw.Text(
                    'Duration: ${DateTimeFormatHelper.formatTripDuration(widget.vehicles['departure'], widget.vehicles['arrival'])}',
                    style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
                  ),
                  pw.SizedBox(height: 20),


                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Departure: ${DateTimeFormatHelper.formatTime(widget.vehicles['departure'])}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Arrival: ${DateTimeFormatHelper.formatTime(widget.vehicles['arrival'])}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 30),
                  pw.Divider(thickness: 2),
                  pw.SizedBox(height: 20),

                  // Date and Price
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Date:', style: pw.TextStyle(fontSize: 14)),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            DateTimeFormatHelper.getDateFromQR(widget.qrPayload),
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('Price:', style: pw.TextStyle(fontSize: 14)),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            '₹ ${(widget.totalPrice == null) ? widget.vehicles['price'] : widget.totalPrice?.toStringAsFixed(2) ?? '0.00'}',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 40),


                  if (qrImage != null)
                    pw.Center(
                      child: pw.Column(
                        children: [
                          pw.Container(
                            width: 200,
                            height: 200,
                            child: pw.Image(
                              pw.MemoryImage(qrImage.buffer.asUint8List()),
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            'Scan this code to verify',
                            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                          ),
                        ],
                      ),
                    ),

                  pw.Spacer(),


                  pw.Text(
                    'Thank you for choosing our service!',
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                  ),
                ],
              ),
            );
          },
        ),
      );


      Directory directory;
      if (Platform.isAndroid) {
        directory = (await getTemporaryDirectory());
      } else {
        directory = await getApplicationDocumentsDirectory();
      }


      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'ticket_${widget.vehicles['vehicleId']}_$timestamp.pdf';
      final filePath = '${directory.path}/$fileName';


      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ticket generated successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );


      await OpenFilex.open(filePath);


      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 8),
                Text('Ticket Ready'),
              ],
            ),
            content: Text('Your ticket has been generated.\n\nYou can share it or view it now.'),
            actions: [
              TextButton(
                child: Text('CLOSE', style: TextStyle(color: Colors.grey)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF05424C),
                ),
                icon: Icon(Icons.share, color: Colors.white, size: 18),
                label: Text('SHARE', style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  Navigator.of(context).pop();
                  // await Share.shareXFiles([XFile(filePath)], text: 'My Ticket - ${widget.vehicles['vehicleId']}');
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download ticket: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
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
                          fontSize: 28,
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
                                fontSize: 14,
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
                                SizedBox(width: 3),
                                Text(
                                  widget.passengerCount.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF05424C),
                                    fontSize: 14,
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
                                DateTimeFormatHelper.formatTripDuration(
                                    widget.vehicles['departure'], widget.vehicles['arrival']),
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
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
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
                                fontSize: 16,
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
                                fontSize: 16,
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
                          Text(
                            DateTimeFormatHelper.getDateFromQR(widget.qrPayload),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '₹ ${(widget.totalPrice == null) ? widget.vehicles['price'] : widget.totalPrice?.toStringAsFixed(2) ?? '0.00'}',
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
                          size: 220,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Scan this code to verify',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15,
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
                  padding: EdgeInsets.symmetric(horizontal: 44, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isDownloading
                    ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  'DOWNLOAD TICKET',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                ),
                onPressed: isDownloading ? null : downloadTicketAsPDF,
              ),
              SizedBox(height: 6),
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFF05424C), fontWeight: FontWeight.bold, fontSize: 16),
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

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ModernTicketScreen extends StatelessWidget {
  const ModernTicketScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final qrData = "09324|Mumbai→Pune|Indb Pune Spl|12:20|3:10|2nd AC|2 Adults|Pet:Yes|Disability:No|Food:No";

    final Color mainPurple = Color(0xFF5867DD); // Your theme color
    final Color accentOrange = Color(0xFFFFB94B);

    return Scaffold(
      backgroundColor: mainPurple,
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 380),
          padding: EdgeInsets.symmetric(vertical: 26, horizontal: 14),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 14, offset: Offset(0, 7)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row: train number & route
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("09324", style: TextStyle(fontWeight: FontWeight.bold, color: mainPurple)),
                      Text("Mumbai  →  Pune", style: TextStyle(fontSize: 15, color: Colors.black87)),
                    ],
                  ),
                ),
                // QR code and train name
                Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 6),
                  child: QrImageView(
                    data: qrData,
                    size: 100,
                    version: QrVersions.auto,
                    backgroundColor: Colors.white,
                    eyeStyle: QrEyeStyle(color: mainPurple, eyeShape: QrEyeShape.circle),
                    dataModuleStyle: QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black87),
                  ),
                ),
                Text(
                  "Indb Pune Spl",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: mainPurple,
                  ),
                ),
                SizedBox(height: 16),
                // Route with duration tag
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text("12:20",
                                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black87)),
                            SizedBox(height: 2),
                            Text("Kalyan Jn", style: TextStyle(fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(color: mainPurple, width: 1),
                        ),
                        child: Text("2h 50m", style: TextStyle(color: mainPurple, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text("3:10",
                                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black87)),
                            SizedBox(height: 2),
                            Text("Pune Jn", style: TextStyle(fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                // Dotted line
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 9),
                  child: Divider(
                    color: Colors.grey.shade300,
                    thickness: 1,
                  ),
                ),
                // Details section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                  child: Column(
                    children: [
                      _detailRow("Type", "2nd AC"),
                      _detailRow("Passengers", "2 Adults"),
                      _detailRow("Pet", "Yes"),
                      _detailRow("Disability", "No"),
                      _detailRow("Food", "No"),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                // Download ticket button
                Padding(
                  padding: const EdgeInsets.only(left: 26, right: 26, bottom: 14, top: 0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.download, color: Colors.black87),
                      label: Text(
                        "Download Ticket",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 17,
                        ),
                      ),
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentOrange,
                        padding: EdgeInsets.symmetric(vertical: 18),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: Colors.black54, fontSize: 15))),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

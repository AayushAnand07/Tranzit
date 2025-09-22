import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../infrastructure/providers/Auth.Providers/booking.provider.dart';
import '../../presentation/pages/login_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scanResult;
  bool scanned = false;
  bool isScannerOpen = false;

  bool isCheckInMode = true;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginSignupScreen()),
            (route) => false,
      );
    } catch (e) {
      print("Error logging out: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logout failed. Try again.")),
      );
    }
  }

  void _onQRViewCreated(QRViewController qrController) {
    final ticketProvider = Provider.of<BookingProvider>(context, listen: false);
    controller = qrController;
    controller!.scannedDataStream.listen((scanData) async {
      if (!scanned) {
        scanned = true;
        setState(() => scanResult = scanData.code);

        final ticketId = parseTicketIdFromQr(scanData.code!);
        if (ticketId != null) {

           bool verified = await ticketProvider.verifyTicketCheckIn(ticketID: ticketId,isCheckInMode: isCheckInMode);


          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(verified
                  ? "✅ Ticket Verified"
                  : "❌ Invalid Ticket"),
              content: Text("QR Code: ${scanData.code}"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    scanned = false;
                    controller?.resumeCamera();
                  },
                  child: const Text("Scan Next"),
                ),
              ],
            ),
          );

          controller?.pauseCamera();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid QR code format.")),
          );
          scanned = false;
          controller?.resumeCamera();
        }
      }
    });
  }

  int? parseTicketIdFromQr(String qrPayload) {
    List<String> parts = qrPayload.split('-');
    if (parts.length >= 4) {
      try {
        return int.parse(parts[2]);
      } catch (e) {
        print("Error parsing ticketId: $e");
        return null;
      }
    } else {
      print("Invalid QR payload format");
      return null;
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void openScanner() {
    setState(() {
      isScannerOpen = true;
      scanResult = null;
      scanned = false;
    });
  }

  void closeScanner() {
    setState(() {
      isScannerOpen = false;
      controller?.dispose();
      controller = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin QR Scanner", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF05424C),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: isScannerOpen
          ? Column(
        children: [
          // Toggle switch row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Check-In"),
                Switch(
                  value: isCheckInMode,
                  onChanged: (val) {
                    setState(() {
                      isCheckInMode = val;
                    });
                  },
                ),
                const Text("Check-Out"),
              ],
            ),
          ),

          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blue,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                scanResult != null
                    ? "Last scanned: $scanResult"
                    : "Scan a QR code",
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ElevatedButton(
              onPressed: closeScanner,
              child: const Text("Close Scanner"),
            ),
          ),
        ],
      )
          : Center(
        child: ElevatedButton(
          onPressed: openScanner,
          child: const Text("Open QR Scanner"),
        ),
      ),
    );
  }
}

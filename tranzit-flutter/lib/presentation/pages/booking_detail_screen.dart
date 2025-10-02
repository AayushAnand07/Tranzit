import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pay/pay.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:tranzit/presentation/pages/ticket_detail_screen.dart';
import 'package:tranzit/presentation/theme/colors.dart';

import '../../infrastructure/providers/Auth.Providers/booking.provider.dart';
import '../../infrastructure/providers/Auth.Providers/route.provider.dart';
import '../components/trip_info_Card.dart';

class BookingDetailPage extends StatefulWidget {
  final dynamic routes;
  final dynamic vehicles;
  final dynamic routeStop;
  final int passengerCount;

  const BookingDetailPage(this.routes, this.vehicles, this.routeStop,this.passengerCount);

  static  Color darkTeal = ColourHelper.mainThemeColour;

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  @override
  Widget build(BuildContext context) {
    final routeProvider = Provider.of<RouteProvider>(context);
    final stops = routeProvider.betweenStops;
    final stopsCount = routeProvider.betweenCount;
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Booking Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: ColourHelper.mainThemeColour,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TripInfoCard(widget.routes, widget.vehicles, stopsCount),
                  const SizedBox(height: 18),
                  const Text(
                    "Metro Map",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/maps.png',
                      fit: BoxFit.cover,
                      height: 120,
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Route Stops",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: List.generate(stops.length, (index) {
                      final stopName = stops[index];

                      Color indicatorColor = Colors.grey[600]!;
                      TextStyle nameStyle = const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      );

                      if (index == 0 || index == stops.length - 1) {
                        indicatorColor = BookingDetailPage.darkTeal;
                        nameStyle = nameStyle.copyWith(color: BookingDetailPage.darkTeal);
                      } else if (stopName.toLowerCase().contains('flower')) {
                        indicatorColor = Colors.red[400]!;
                        nameStyle = nameStyle.copyWith(color: indicatorColor);
                      }
                      if (index == stops.length - 1) {
                        nameStyle = nameStyle.copyWith(fontWeight: FontWeight.bold);
                      }

                      return TimelineTile(
                        alignment: TimelineAlign.start,
                        isFirst: index == 0,
                        isLast: index == stops.length - 1,
                        indicatorStyle: IndicatorStyle(
                          width: 25,
                          color: indicatorColor,
                        ),
                        beforeLineStyle: LineStyle(color: Colors.grey[300]!, thickness: 3),
                        afterLineStyle: LineStyle(color: Colors.grey[300]!, thickness: 3),
                        endChild: Padding(
                          padding: const EdgeInsets.only(left: 8, top: 12, bottom: 12),
                          child: Text(stopName, style: nameStyle),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹ ${widget.vehicles['price']?.toStringAsFixed(2) ?? '0.00'}',
                  style:  TextStyle(
                    color: BookingDetailPage.darkTeal,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                SizedBox(
                  width: 180,
                  height: 48,
                  child: GooglePayButton(
                    paymentConfigurationAsset: 'payment_config_google_pay.json',
                    paymentItems: [
                      PaymentItem(
                        label: 'Total',
                        amount: '${widget.vehicles['price']?.toStringAsFixed(2) ?? '0.00'}',
                        status: PaymentItemStatus.final_price,
                      ),
                    ],
                    type: GooglePayButtonType.book,
                    onError: (error) {
                      debugPrint("Payment Failed: $error");
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text("Payment Failed ❌: $error")));
                    },
                    onPaymentResult: (result) async {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                      debugPrint("Payment Result: $result");

                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      debugPrint("Payment Result: $uid");
                      if (uid != null) {
                        print(widget.routeStop['fromStop']);
                        print(widget.routeStop['toStop']);
                        await bookingProvider
                            .fetchTicketBookingResponse(
                          vehicleId: widget.vehicles['id'],
                          fromStopName: routeProvider.getStopIdByName(widget.routeStop['fromStop'])!,
                          toStopName: routeProvider.getStopIdByName(widget.routeStop['toStop'])!,
                          userId: uid,
                          journeyDate: widget.vehicles['departure'],
                          passengers: widget.passengerCount,
                          price:(widget.vehicles['price'] as num).toInt()
                        )
                            .then((_) {
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TicketDetailsPage(
                                   widget.vehicles, widget.routeStop, bookingProvider.qrPayload!,widget.passengerCount,null),
                            ),
                          );
                        });
                      }
                    },
                    loadingIndicator: const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

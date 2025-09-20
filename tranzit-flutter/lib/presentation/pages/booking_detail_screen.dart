import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../infrastructure/providers/Auth.Providers/route.provider.dart';
import '../components/trip_info_Card.dart';
 // Adjust filename/path if needed

class BookingDetailPage extends StatelessWidget {
  final dynamic routes;
  final dynamic vehicles;

  const BookingDetailPage(this.routes, this.vehicles, {Key? key}) : super(key: key);

  static const Color darkTeal = Color(0xFF165E5A);

  @override
  Widget build(BuildContext context) {
    final stops = context.watch<RouteProvider>().betweenStops;
    final stopsCount = context.watch<RouteProvider>().betweenCount;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Booking Details ",style:TextStyle(color: Colors.white,fontWeight: FontWeight.w500),),
        backgroundColor: darkTeal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.white,),
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
                  TripInfoCard(routes, vehicles,stopsCount),
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
                    "Train Routes",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: List.generate(stops.length, (index) {
                      final stopName = stops[index];

                      Color indicatorColor = Colors.grey[600]!;
                      TextStyle nameStyle = const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16);
                      if (index == 0 || index == stops.length - 1) {
                        indicatorColor = darkTeal;
                        nameStyle = nameStyle.copyWith(color: darkTeal);
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
                        beforeLineStyle: LineStyle(
                          color: Colors.grey[300]!,
                          thickness: 3,
                        ),
                        afterLineStyle: LineStyle(
                          color: Colors.grey[300]!,
                          thickness: 3,
                        ),
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
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '\$58.00',
                  style: TextStyle(
                    color: darkTeal,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                SizedBox(
                  width: 180,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkTeal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "BOOK TICKET",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                    onPressed: () {},
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

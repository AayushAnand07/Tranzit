import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../infrastructure/helper/date_format_helper.dart';
import '../../infrastructure/providers/Auth.Providers/route.provider.dart';
import '../components/SearchResultCard.dart';
import 'booking_detail_screen.dart';
import '../theme/colors.dart';

class SearchResultsScreen extends StatefulWidget {

  final int passengerCount;
  SearchResultsScreen(this.passengerCount);

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final darkTeal = const Color(0xFF165E5A);
  final yellow = const Color(0xFFEFE973);
  final lightGrey = const Color(0xFFF5F5F5);



  @override
  Widget build(BuildContext context) {
    final stops = context.watch<RouteProvider>().stops;
    //final searchProvider= context.watch<RouteProvider>();

    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor:ColourHelper.mainThemeColour,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close,color: Colors.white,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Search Results',
          style: TextStyle(color:Colors.white,fontWeight: FontWeight.w500, fontSize: 20),
        ),

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

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                    try {
                      await routeProvider.fetchStopsBetween(
                        routeId: route['id'],
                        from: routeStop['fromStop'] ?? '',
                        to: routeStop['toStop'] ?? '',
                        direction: vehicle['direction'] ??''
                      );

                      Navigator.of(context).pop();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BookingDetailPage(route, vehicle, routeStop,widget.passengerCount),
                        ),
                      );
                    } catch (e) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  },
                  child: SearchResultCard(route: route,routeStop: routeStop,vehicle: vehicle,passengerCount: widget.passengerCount),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

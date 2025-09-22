import 'package:flutter/material.dart';

class RouteCard extends StatelessWidget {
  final String fromCity;
  final String toCity;
  final String departureTime;
  final String arrivalTime;
  final List<IconData> transportModes;

  const RouteCard({
    Key? key,
    required this.fromCity,
    required this.toCity,
    required this.departureTime,
    required this.arrivalTime,
    required this.transportModes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 25, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$fromCity → $toCity',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text('$departureTime - $arrivalTime', style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          // Row(
          //   children: transportModes
          //       .map((icon) => Padding(
          //     padding: const EdgeInsets.only(right: 8),
          //     child: Icon(icon, size: 20, color: Colors.teal),
          //   ))
          //       .toList(),
          // ),
        ],
      ),
    );
  }
}

// Section to display multiple routes
class PopularRoutesSection extends StatelessWidget {
  final List<Map<String, dynamic>> routes = [
    {
      'fromCity': 'Mumbai',
      'toCity': 'Bangalore',
      'departureTime': '08:30',
      'arrivalTime': '15:00',
      'transportModes': [Icons.directions_bus, Icons.train],
    },
    {
      'fromCity': 'Bangalore',
      'toCity': 'Chennai',
      'departureTime': '09:00',
      'arrivalTime': '14:30',
      'transportModes': [Icons.train],
    },

  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            "Popular Routes",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        SizedBox(

          height: 100,
          child: ListView.builder(
            clipBehavior: Clip.none,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final route = routes[index];
              return RouteCard(
                fromCity: route['fromCity'],
                toCity: route['toCity'],
                departureTime: route['departureTime'],
                arrivalTime: route['arrivalTime'],
                transportModes: List<IconData>.from(route['transportModes']),
              );
            },
          ),
        ),
      ],
    );
  }
}

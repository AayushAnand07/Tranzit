class RouteInfo {
  final int id;
  final String name;
  final String transport;

  RouteInfo({required this.id, required this.name, required this.transport});

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    return RouteInfo(
      id: json['id'],
      name: json['name'],
      transport: json['transport'],
    );
  }
}

class Vehicle {
  final int id;
  final String vehicleId;
  final DateTime departure;
  final DateTime arrival;
  final double price;
  final String direction;

  Vehicle({
    required this.id,
    required this.vehicleId,
    required this.departure,
    required this.arrival,
    required this.price,
    required this.direction,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      vehicleId: json['vehicleId'],
      departure: DateTime.parse(json['departure']),
      arrival: DateTime.parse(json['arrival']),
      price: json['price'].toDouble(),
      direction: json['direction'],
    );
  }
}

class RouteStop {
  final RouteInfo route;
  final Vehicle vehicle;
  final String fromStop;
  final String toStop;

  RouteStop({
    required this.route,
    required this.vehicle,
    required this.fromStop,
    required this.toStop,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      route: RouteInfo.fromJson(json['route']),
      vehicle: Vehicle.fromJson(json['vehicle']),
      fromStop: json['fromStop'],
      toStop: json['toStop'],
    );
  }
}
import 'package:flutter/material.dart';
import '../../services/route.service.dart';


class RouteProvider with ChangeNotifier {
  final RouteService _routeService = RouteService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _stops = [];
  List<Map<String, dynamic>> get stops => _stops;

  List<Map<String, dynamic>> _allStops = [];
  List<Map<String, dynamic>> get allStops => _allStops;

  String? _fromStop;
  String? get fromStop => _fromStop;

  String? _toStop;
  String? get toStop => _toStop;

  DateTime _searchDate = DateTime.now();
  DateTime get searchDate => _searchDate;

  List<String> _transportTypes = [];
  List<String> get transportTypes => _transportTypes;

  List<String> _betweenStops = [];
  List<String> get betweenStops => _betweenStops;

  int _betweenCount = 0;
  int get betweenCount => _betweenCount;


  Future<void> getAllStops() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _routeService.getaAllStops();
      _allStops = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print("Error fetching stops: $e");
      _allStops = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> fetchStopsForRoute({
    required String from,
    required String to,
    String? transportType,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _routeService.getStopsForRouteAndType(
        from: from,
        to: to,
        transportType: transportType,
      );
      _stops = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print("Error fetching stops for route: $e");
      _stops = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> fetchStopsBetween({
    required int routeId,
    required String from,
    required String to,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _routeService.getStopsBetween(
        routeId: routeId,
        from: from,
        to: to,
      );
      print("Result $result");

      _betweenStops = List<String>.from(result['stops']);
      _betweenCount = result['count'];
    } catch (e) {
      print("Error fetching stops between: $e");
      _betweenStops = [];
      _betweenCount = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFromStop(String? from) {
    _fromStop = from;
    notifyListeners();
  }

  void setToStop(String? to) {
    _toStop = to;
    notifyListeners();
  }

  void setSearchDate(DateTime date) {
    _searchDate = date;
    notifyListeners();
  }

  // void setTransportTypes(List<String> types) {
  //   _transportTypes = types;
  //   notifyListeners();
  // }




}




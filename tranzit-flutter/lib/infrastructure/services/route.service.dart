

import 'package:dio/dio.dart';

import '../helper/firebaseJwtHelper.dart';
import 'base.service.dart';

class RouteService{

  final Dio _dio;

  RouteService() : _dio = BaseService().dio;

  Future<List<dynamic>> getaAllStops() async {
    try {
      final response = await _dio.get('routes/allStops');
      return response.data;
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic> && errorData.containsKey('error')) {
        throw Exception(errorData['error']);
      } else {
        throw Exception('Failed to fetch stops');
      }
    }
  }


  Future<List<dynamic>> getStopsForRouteAndType({
    required String from,
    required String to,
    String? transportType,
  }) async {
    try {
      final response = await _dio.get(
        'routes',
        queryParameters: {
          'from': from,
          'to': to,
          if (transportType != null) 'transportType': transportType,
        },
      );
      print(response.data['results']);
      return response.data['results'];
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic> && errorData.containsKey('error')) {
        throw Exception(errorData['error']);
      } else {
        throw Exception('Failed to fetch route stops');
      }
    }
  }


  Future<Map<String, dynamic>> getStopsBetween({
    required int routeId,
    required String from,
    required String to,
    required String direction,
  }) async {
    try {
      final response = await _dio.get(
        'routes/between',
        queryParameters: {
          'routeId': routeId,
          'from': from,
          'to': to,
        },
      );

      List<String> stops = List<String>.from(response.data);

      if (direction.toLowerCase() == "reverse") {

        stops = stops.reversed.toList();
      }

      return {
        "count": stops.length > 2 ? stops.length - 2 : 0,
        "stops": stops,
      };
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic> && errorData.containsKey('error')) {
        throw Exception(errorData['error']);
      } else {
        throw Exception('Failed to fetch stops between');
      }
    }
  }
}




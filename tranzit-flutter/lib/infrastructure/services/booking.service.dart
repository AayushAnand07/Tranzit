

import 'package:dio/dio.dart';

import 'base.service.dart';

class BookingService{

  final Dio _dio;

  BookingService() : _dio = BaseService().dio;
  
  
  Future<Map<String, dynamic>> postTicketBookingDetails({
    required int vehicleId,
    required int fromStopId,
    required int toStopId,
    required String userId,
})async{

    try{
      final response =  await _dio.post('ticket/book',
      data: {
        'vehicleId': vehicleId,
        'fromStopId': fromStopId,
        'toStopId': toStopId,
        'userId': userId,
      });
      final data = response.data as Map<String, dynamic>;
      return data;
    }
    on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic> && errorData.containsKey('error')) {
        throw Exception(errorData['error']);
      } else {
        throw Exception('Failed to fetch stops');
      }
    }
    
  }



  Future<Map<String, dynamic>> VerifyCheckIn({
    required int ticketId,
    required bool isCheckedIn

})async{

    try{
      final endpoint = isCheckedIn ? 'ticket/checkin' : 'ticket/checkout';

      final response =  await _dio.post(
          endpoint,
          data: {
            'ticketId': ticketId,
      });
      final data = response.data as Map<String, dynamic>;
      print(data["success"]);
      return data;
    }
    on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic> && errorData.containsKey('error')) {
        throw Exception(errorData['error']);
      } else {
        throw Exception('Failed to fetch stops');
      }
    }

  }

  Future<List<dynamic>> FetchAllTickets() async {
    try {
      final endpoint = 'ticket/';
      final response = await _dio.get(endpoint);

      final data = response.data as Map<String, dynamic>;
      print(data);

      // Extract tickets list
      if (data.containsKey('tickets') && data['tickets'] is List) {
        return data['tickets'] as List<dynamic>;
      } else {
        return [];
      }
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic> && errorData.containsKey('error')) {
        throw Exception(errorData['error']);
      } else {
        throw Exception('Failed to fetch tickets');
      }
    }
  }






}
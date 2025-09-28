
import 'package:dio/dio.dart';
import 'package:tranzit/infrastructure/services/base.service.dart';

class ChatService{

  final Dio _dio;

  ChatService() : _dio = BaseService().dio;




  Future<void> postQueryForProcessing(String query,String token)async{
    if (query == null || query.trim().isEmpty) {
      print("Error posting query: Message is required and cannot be empty");
      return;
    }
    try{
       await _dio.post('chat/book',
           data: {
         'message':query,
         'token':token
       });
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
}
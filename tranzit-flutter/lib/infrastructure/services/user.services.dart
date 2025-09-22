import 'package:dio/dio.dart';


import '../helper/firebaseJwtHelper.dart';
import 'base.service.dart';

class UserService {
  final Dio _dio;

  UserService() : _dio = BaseService().dio;


  Future<Map<String, dynamic>> createUser(String id, String name) async {
    try {
      final response = await _dio.post(
        'users/create',
        data: {
          'id': id,
          'name': name,
        },
      );
      return response.data;
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic> && errorData.containsKey('error')) {
        throw Exception(errorData['error']);
      } else {
        throw Exception('Failed to create user');
      }
    }
  }


  Future<String>getUserByUid(String id)async{
    try {
      final response = await _dio.get('users/$id');
      print("This is response from getUserByUid $response");
      return response.toString();
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic> && errorData.containsKey('error')) {
        throw Exception(errorData['error']);
      } else {
        throw Exception('Failed to create user');
      }
    }
  }

}

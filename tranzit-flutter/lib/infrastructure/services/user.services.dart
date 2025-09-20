import 'package:dio/dio.dart';


import '../helper/firebaseJwtHelper.dart';

class UserService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://7e161d4a964f.ngrok-free.app',
    headers: {'Content-Type': 'application/json'},
  ));

  UserService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await FirebaseJwtHelper.getJwtToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

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

}

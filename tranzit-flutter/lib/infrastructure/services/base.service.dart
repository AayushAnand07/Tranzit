import 'package:dio/dio.dart';
import '../helper/firebaseJwtHelper.dart';

class BaseService {
  final Dio dio;

  BaseService()
      : dio = Dio(BaseOptions(
    baseUrl: 'https://tranzitbackend-1032077500528.asia-south1.run.app/api/v1/',
    headers: {'Content-Type': 'application/json'},
  )) {
    dio.interceptors.add(
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
}

import 'package:dio/dio.dart';
import '../helper/firebaseJwtHelper.dart';

class BaseService {
  final Dio dio;

  BaseService()
      : dio = Dio(BaseOptions(
    baseUrl: 'https://666693079fdb.ngrok-free.app/api/v1/',
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

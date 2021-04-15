import 'package:dio/dio.dart';

import 'http_intercept.dart';

class HttpClient {

  Dio get mobileDataHttp {
    var dio = Dio();
    dio.interceptors.add(MobileDataInterceptor());
    return dio;
  }

  Dio get http {
    var dio = Dio();
    return dio;
  }
}

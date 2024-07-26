// ignore_for_file: prefer_conditional_assignment

import 'package:dio/dio.dart';
import 'package:dio_http_cache_extension/dio_http_cache_extension.dart';

class DioHelper {
  static Dio? _dio;
  static HttpCacheManager? _manager;
  static const baseUrl = 'https://www.wanandroid.com/';

  static Dio getDio() {
    if (null == _dio) {
      _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          contentType: 'application/x-www-form-urlencoded; charset=utf-8'))
//        ..httpClientAdapter = _getHttpClientAdapter()
        ..interceptors.add(getCacheManager().interceptor)
        ..interceptors.add(LogInterceptor(responseBody: true));
    }
    return _dio!;
  }

  static HttpCacheManager getCacheManager() {
    if (null == _manager) {
      _manager = HttpCacheManager(
          setting: HttpCacheSetting(baseUrl: 'https://www.wanandroid.com/'));
    }
    return _manager!;
  }

  // set proxy
  // static HttpClientAdapter _getHttpClientAdapter() {
  //   final httpClientAdapter = HttpClientAdapter();
  //   // httpClientAdapter.onHttpClientCreate = (HttpClient client) {
  //   //   client.findProxy = (uri) {
  //   //     return 'PROXY 10.0.0.103:6152';
  //   //   };
  //   //   client.badCertificateCallback =
  //   //       (X509Certificate cert, String host, int port) {
  //   //     return true;
  //   //   };
  //   // };
  //   return httpClientAdapter;
  // }
}

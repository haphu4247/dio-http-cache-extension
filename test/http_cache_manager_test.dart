import 'package:dio/dio.dart';
import 'package:dio_http_cache_extension/dio_http_cache_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const String baseUrl = 'https://jsonplaceholder.typicode.com';
void main() {
  setupDB();
  ///test Database cache.
  final setting = HttpCacheSetting(
    baseUrl: baseUrl,
    defaultMaxAge: Duration(days: 3),
    defaultMaxStale: Duration(days: 5),
    skipMemoryCache: true,
  );
  final cacheManager = HttpCacheManager(setting: setting);
  final dio = setup(cacheManager);
  test('/users/2', () async {
    await cacheManager.clearAll();
    final dataFromInternet = await dio.get(
      '/users/2',
      options: setting.option,
    );

    ;
    expect(
        dataFromInternet.headers.map
            .containsKey(DioCacheKey.headerKeyDataSource.name),
        false);
    final dataFromCache = await dio.get(
      '/users/2',
      options: setting.option,
    );
    expect(
        dataFromCache.headers.map
            .containsKey(DioCacheKey.headerKeyDataSource.name),
        true);

    expect(dataFromInternet.data, dataFromCache.data);
  });
}

Dio setup(HttpCacheManager cacheManager) {
  final dio = Dio();
  dio.options.baseUrl = baseUrl;
  dio.interceptors.add(cacheManager.interceptor);
  return dio;
}

void setupDB() {
  sqfliteFfiInit();
  // Change the default factory for unit testing calls for SQFlite
  databaseFactory = databaseFactoryFfi;
}

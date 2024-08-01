import 'package:dio/dio.dart';
import 'package:dio_http_cache_extension/dio_http_cache_extension.dart';

class HttpCacheSetting {
  final Duration defaultMaxAge;
  final Duration? defaultMaxStale;
  final String? databasePath;
  final String databaseName;
  final String? baseUrl;
  final String defaultRequestMethod;

  final bool skipMemoryCache;
  final bool skipDbCache;

  final int maxMemoryCacheCount;

  const HttpCacheSetting({
    this.defaultMaxAge = const Duration(days: 7),
    this.defaultMaxStale,
    this.defaultRequestMethod = 'POST',
    this.databasePath,
    this.databaseName = 'DioCache',
    this.baseUrl,
    this.skipDbCache = false,
    this.skipMemoryCache = false,
    this.maxMemoryCacheCount = 100,
  });

  Options get option {
    return buildCacheOptions(
      defaultMaxAge,
      maxStale: defaultMaxStale,
    );
  }

  Options fromOption(Options other) {
    return buildConfigurableCacheOptions(
      options: other,
      maxAge: defaultMaxAge,
      maxStale: defaultMaxStale,
    );
  }
}

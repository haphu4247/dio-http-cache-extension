import 'package:dio_http_cache_extension/src/models/http_cache_obj.dart';
import 'package:dio_http_cache_extension/src/models/http_cache_setting.dart';

import '../cache/http_cache.dart';

abstract class IHttpLocalCacheRepository {
  final HttpCacheSetting setting;
  final IHttpCache? dbCache;
  final IHttpCache? memoryCache;

  const IHttpLocalCacheRepository({
    required this.setting,
    required this.dbCache,
    required this.memoryCache,
  });

  Future<HttpCacheObj?> pullFromCache(String key, {String? subKey});

  Future<HttpCacheObj?> pullFromCacheBeforeMaxAge(String key, {String? subKey});

  Future<HttpCacheObj?> pullFromCacheBeforeMaxStale(String key,
      {String? subKey});

  Future<bool> pushToCache(HttpCacheObj obj);

  Future<bool> delete(String key, {String? subKey});

  Future<bool> clearExpired();

  Future<bool> clearAll();
}

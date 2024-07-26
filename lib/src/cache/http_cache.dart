import '../../dio_http_cache_extension.dart';

abstract class IHttpCache {
  const IHttpCache(this.cacheEncryption);

  final CacheEncryption<dynamic> cacheEncryption;

  Future<HttpCacheObj?> getCacheObj(String key, {String? subKey});

  Future<bool> setCacheObj(HttpCacheObj obj);

  Future<bool> delete(String key, {String? subKey});

  Future<bool> clearExpired();

  Future<bool> clearAll();
}

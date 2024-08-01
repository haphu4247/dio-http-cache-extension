import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_http_cache_extension/dio_http_cache_extension.dart';
import 'package:dio_http_cache_extension/src/cache/impl/http_disk_cache_impl.dart';
import 'package:dio_http_cache_extension/src/cache/impl/http_memory_cache_impl.dart';
import 'package:dio_http_cache_extension/src/extension/request_options_extension.dart';
import 'package:dio_http_cache_extension/src/repository/impl/http_local_cache_repository_impl.dart';

part 'http_cache_manager_impl.dart';

abstract class HttpCacheManager {
  factory HttpCacheManager({
    required HttpCacheSetting setting,
    CacheEncryption<dynamic> cacheEncryption = const CacheEncryption<dynamic>(),
  }) {
    final localCache = HttpLocalCacheRepositoryImpl(
      setting: setting,
      dbCache: setting.skipDbCache
          ? null
          : HttpDiskCacheImpl(
              cacheEncryption,
              databasePath: setting.databasePath,
              databaseName: setting.databaseName,
            ),
      memoryCache: setting.skipMemoryCache
          ? null
          : HttpMemoryCacheImpl(
              cacheEncryption,
              setting.maxMemoryCacheCount,
            ),
    );
    return _HttpCacheManagerImpl(localCache);
  }

  factory HttpCacheManager.custom(
    IHttpLocalCacheRepository customCache,
  ) {
    return _HttpCacheManagerImpl(customCache);
  }

  const HttpCacheManager._(this._localCache);
  final IHttpLocalCacheRepository _localCache;

  InterceptorsWrapper get interceptor;

  String? get _baseUrl => _localCache.setting.baseUrl;

  String _getRequestMethod(String? requestMethod) {
    if (null != requestMethod && requestMethod.isNotEmpty) {
      return requestMethod.toUpperCase();
    }
    return _localCache.setting.defaultRequestMethod.toUpperCase();
  }

  String _getPrimaryKeyFromUri(Uri uri) => '${uri.host}${uri.path}';

  String _getSubKeyFromUri(Uri uri, {dynamic data}) =>
      '${data?.toString()}_${uri.query}';

  RequestOptions _getUriByPath(String? baseUrl, String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) {
    if (!path.startsWith('http')) {
      assert(baseUrl != null && baseUrl.isNotEmpty);
    }
    return RequestOptions(
        baseUrl: baseUrl,
        path: path,
        data: data,
        queryParameters: queryParameters);
  }

  Future<bool> delete(String primaryKey,
      {String? requestMethod, String? subKey});

  Future<bool> deleteByPrimaryKeyWithUri(Uri uri, {String? requestMethod});

  Future<bool> deleteByPrimaryKey(String path, {String? requestMethod});

  Future<bool> deleteByPrimaryKeyAndSubKeyWithUri(Uri uri,
      {String? requestMethod, String? subKey, dynamic data});

  Future<bool> deleteByPrimaryKeyAndSubKey(String path,
      {String? requestMethod,
      Map<String, dynamic>? queryParameters,
      String? subKey,
      dynamic data});

  Future<bool> clearExpired();

  Future<bool> clearAll();
}

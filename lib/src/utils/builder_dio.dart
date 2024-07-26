import 'package:dio/dio.dart';

import '../const/store_cache_key.dart';

/// try to get maxAge and maxStale from response headers.
/// local settings will always overview the value get from service.
Options buildServiceCacheOptions(
        {Options? options,
        Duration? maxStale,
        String? primaryKey,
        String? subKey,
        bool? forceRefresh}) =>
    buildConfigurableCacheOptions(
        options: options,
        maxStale: maxStale,
        primaryKey: primaryKey,
        subKey: subKey,
        forceRefresh: forceRefresh);

/// build a normal cache options
Options buildCacheOptions(Duration maxAge,
        {Duration? maxStale,
        String? primaryKey,
        String? subKey,
        Options? options,
        bool? forceRefresh}) =>
    buildConfigurableCacheOptions(
        maxAge: maxAge,
        options: options,
        primaryKey: primaryKey,
        subKey: subKey,
        maxStale: maxStale,
        forceRefresh: forceRefresh);

/// if null==maxAge, will try to get maxAge and maxStale from response headers.
/// local settings will always overview the value get from service.
Options buildConfigurableCacheOptions(
    {Options? options,
    Duration? maxAge,
    Duration? maxStale,
    String? primaryKey,
    String? subKey,
    bool? forceRefresh}) {
  if (null == options) {
    options = Options();
    options.extra = {};
  } else if (options.responseType == ResponseType.stream) {
    throw Exception("ResponseType.stream is not supported");
  } 
  options.extra ??= {};
  options.extra!.addAll({DioCacheKey.tryCache.name: true});
  if (null != maxAge) {
    options.extra!.addAll({DioCacheKey.maxAge.name: maxAge});
  }
  if (null != maxStale) {
    options.extra!.addAll({DioCacheKey.maxStale.name: maxStale});
  }
  if (null != primaryKey) {
    options.extra!.addAll({DioCacheKey.primaryKey.name: primaryKey});
  }
  if (null != subKey) {
    options.extra!.addAll({DioCacheKey.subKey.name: subKey});
  }
  if (null != forceRefresh) {
    options.extra!.addAll({DioCacheKey.forceRefresh.name: forceRefresh});
  }
  return options;
}

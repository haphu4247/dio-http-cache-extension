import 'package:dio_http_cache_extension/src/models/http_cache_obj.dart';
import 'package:dio_http_cache_extension/src/repository/http_local_cache_repository.dart';
import 'package:dio_http_cache_extension/src/utils/cache_utils.dart';

class HttpLocalCacheRepositoryImpl extends IHttpLocalCacheRepository {
  const HttpLocalCacheRepositoryImpl({
    required super.setting,
    required super.dbCache,
    required super.memoryCache,
  });

  @override
  Future<bool> clearAll() {
    return _getCacheFutureResult([
      memoryCache?.clearAll(),
      dbCache?.clearAll(),
    ]);
  }

  @override
  Future<bool> clearExpired() {
    return _getCacheFutureResult([
      memoryCache?.clearExpired(),
      dbCache?.clearExpired(),
    ]);
  }

  @override
  Future<bool> delete(String key, {String? subKey}) {
    final _key = CacheUtils.convertToMd5(key);
    if (null != subKey) {
      subKey = CacheUtils.convertToMd5(subKey);
    }

    return _getCacheFutureResult([
      memoryCache?.delete(_key, subKey: subKey),
      dbCache?.delete(_key, subKey: subKey),
    ]);
  }

  @override
  Future<HttpCacheObj?> pullFromCache(String key, {String? subKey}) async {
    final _key = CacheUtils.convertToMd5(key);
    if (null != subKey) {
      subKey = CacheUtils.convertToMd5(subKey);
    }
    //get obj from Memory
    var obj = await memoryCache?.getCacheObj(_key, subKey: subKey);
    if (null == obj) {
      //get obj from DB
      obj = await dbCache?.getCacheObj(_key, subKey: subKey);
      if (null != obj) {
        await memoryCache?.setCacheObj(obj);
      }
    }
    if (null != obj) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (null != obj.maxStaleDate && obj.maxStaleDate! > 0) {
        //if maxStaleDate exist, Remove it if maxStaleDate expired.
        if (obj.maxStaleDate! < now) {
          await delete(_key, subKey: subKey);
          return null;
        }
      } else {
        //if maxStaleDate NOT exist, Remove it if maxAgeDate expired.
        if (obj.maxAgeDate! < now) {
          await delete(_key, subKey: subKey);
          return null;
        }
      }
    }
    return obj;
  }

  @override
  Future<HttpCacheObj?> pullFromCacheBeforeMaxAge(String key,
      {String? subKey}) async {
    final obj = await pullFromCache(key, subKey: subKey);
    if (null != obj &&
        null != obj.maxAgeDate &&
        obj.maxAgeDate! < DateTime.now().millisecondsSinceEpoch) {
      return null;
    }
    return obj;
  }

  @override
  Future<HttpCacheObj?> pullFromCacheBeforeMaxStale(String key,
      {String? subKey}) {
    return pullFromCache(key, subKey: subKey);
  }

  @override
  Future<bool> pushToCache(HttpCacheObj obj) {
    if (null == obj.maxAgeDate || obj.maxAgeDate! <= 0) {
      obj.maxAge = setting.defaultMaxAge;
    }
    if (null == obj.maxAgeDate || obj.maxAgeDate! <= 0) {
      return Future.value(false);
    }
    if ((null == obj.maxStaleDate || obj.maxStaleDate! <= 0) &&
        null != setting.defaultMaxStale) {
      obj.maxStale = setting.defaultMaxStale;
    }
    
    obj.toMD5();
    return _getCacheFutureResult([
      memoryCache?.setCacheObj(obj),
      dbCache?.setCacheObj(obj),
    ]);
  }

  Future<bool> _getCacheFutureResult(
    List<Future<bool>?> futures,
  ) async {
    final _futures = futures.whereType<Future<bool>>();
    if (_futures.isNotEmpty) {
      final result = await Future.wait(_futures);
      final trueValue = result.where((element) => element == true);
      return trueValue.length == result.length;
    }
    return false;
  }
}

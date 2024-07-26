import 'dart:collection';

import 'package:dio_http_cache_extension/src/cache/http_cache.dart';
import 'package:dio_http_cache_extension/src/models/http_cache_obj.dart';
import 'package:quiver/cache.dart';

class HttpMemoryCacheImpl extends IHttpCache {
  final int _maxMemoryCacheCount;
  late MapCache<String, HttpCacheObj> _mapCache;
  late Map<String, List<String>> _keys;

  HttpMemoryCacheImpl(super.cacheEncryption, this._maxMemoryCacheCount) {
    _initMap();
  }

  void _initMap() {
    _mapCache = MapCache.lru(maximumSize: _maxMemoryCacheCount);
    _keys = HashMap();
  }

  @override
  Future<bool> clearAll() async {
    _initMap();
    return true;
  }

  @override
  Future<bool> clearExpired() => clearAll();

  @override
  Future<bool> delete(String key, {String? subKey}) async {
    _removeKey(key, subKey: subKey).forEach((key) => _mapCache.invalidate(key));
    return true;
  }

  @override
  Future<HttpCacheObj?> getCacheObj(String key, {String? subKey}) async =>
      _mapCache.get('${key}_$subKey');

  @override
  Future<bool> setCacheObj(HttpCacheObj obj) async {
    _mapCache.set('${obj.key}_${obj.subKey}', obj);
    _storeKey(obj);
    return true;
  }

  void _storeKey(HttpCacheObj obj) {
    List<String>? subKeyList = _keys[obj.key];
    subKeyList ??= [];
    subKeyList.add(obj.subKey ?? '');
    _keys[obj.key] = subKeyList;
  }

  List<String> _removeKey(String key, {String? subKey}) {
    final List<String>? subKeyList = _keys[key];
    if (null == subKeyList || subKeyList.isEmpty) {
      return [];
    }
    if (null == subKey) {
      _keys.remove(key);
      return subKeyList.map((sKey) => '${key}_$sKey').toList();
    } else {
      subKeyList.remove(subKey);
      _keys[key] = subKeyList;
      return ['${key}_$subKey'];
    }
  }
}

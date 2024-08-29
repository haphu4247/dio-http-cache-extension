import 'package:dio_http_cache_extension/dio_http_cache_extension.dart';
import 'package:dio_http_cache_extension/src/utils/cache_utils.dart';

enum HttpTableColumnKey {
  key('key'),
  subKey('subKey'),
  maxAgeDate('max_age_date'),
  maxStaleDate('max_stale_date'),
  content('content'),
  statusCode('statusCode'),
  headers('headers');

  const HttpTableColumnKey(this.name);
  final String name;

  static Future<Map<String, Object?>> mappingObj({
    required HttpCacheObj obj,
  }) async {
    final _convertHeadersToBlob = CacheUtils.convertToBlob(obj.headers?.map);
    final _convertContentToBlob = CacheUtils.convertToBlob(obj.content);
    print('mappingObj key: ${obj.key}');
    print('mappingObj subKey: ${obj.subKey}');
    return {
      key.name: obj.key,
      subKey.name: '${obj.subKey}',
      maxAgeDate.name: obj.maxAgeDate ?? 0,
      maxStaleDate.name: obj.maxStaleDate ?? 0,
      statusCode.name: obj.statusCode,
      content.name: _convertContentToBlob,
      headers.name: _convertHeadersToBlob
    };
  }

  static String createTableSql(String name) => '''
      CREATE TABLE IF NOT EXISTS $name ( 
        ${key.name} text, 
        ${subKey.name} text, 
        ${maxAgeDate.name} integer,
        ${maxStaleDate.name} integer,
        ${content.name} BLOB,
        ${statusCode.name} integer,
        ${headers.name} BLOB,
        PRIMARY KEY (${key.name}, ${subKey.name})
        ) 
      ''';
}

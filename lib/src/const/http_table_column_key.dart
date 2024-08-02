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
    required CacheEncryption<Object?> encryption,
  }) async {
    final _convertHeadersToBlob = CacheUtils.convertToBlob(obj.headers?.map);

    final _encryptedContent =
        await encryption.encryptCacheResponse(obj.content);
    final _convertContentToBlob = CacheUtils.convertToBlob(_encryptedContent);
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
}

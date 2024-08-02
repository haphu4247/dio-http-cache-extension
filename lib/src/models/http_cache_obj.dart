import 'package:dio/dio.dart';
import 'package:dio_http_cache_extension/src/utils/cache_utils.dart';

class HttpCacheObj {
  String key;
  String? subKey;
  int? maxAgeDate;
  int? maxStaleDate;
  int? statusCode;

  dynamic content;
  Headers? headers;

  factory HttpCacheObj(
    String key,
    Object? content, {
    String? subKey = '',
    Duration? maxAge,
    Duration? maxStale,
    int? statusCode = 200,
    Headers? headers,
  }) {
    return HttpCacheObj._(
      key,
      subKey: subKey,
      content: content,
      statusCode: statusCode,
      headers: headers,
    )
      ..maxAge = maxAge
      ..maxStale = maxStale;
  }

  HttpCacheObj._(
    this.key, {
    this.subKey,
    this.content,
    this.statusCode,
    this.headers,
  });

  set maxAge(Duration? duration) {
    if (null != duration) {
      maxAgeDate = CacheUtils.convertDuration(duration);
    }
  }

  set maxStale(Duration? duration) {
    if (null != duration) {
      maxStaleDate = CacheUtils.convertDuration(duration);
    }
  }

  factory HttpCacheObj.fromDatabase({
    required Map<String, dynamic> json,
    Object? content,
  }) {
    final _headers = CacheUtils.parseHeadersFromBlob(json['headers']);
    return HttpCacheObj(
      json['key'] as String,
      content,
      headers: _headers,
      subKey: json['subKey'] as String?,
      statusCode: json['statusCode'] as int?,
    )
      ..maxAgeDate = json['max_age_date'] as int?
      ..maxStaleDate = json['max_stale_date'] as int?;
  }
}

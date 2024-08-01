import 'dart:convert';

import 'package:dio_http_cache_extension/src/utils/cache_encryption.dart';
import 'package:dio_http_cache_extension/src/const/http_table_column_key.dart';

class HttpCacheObj {
  String key;
  String? subKey;
  int? maxAgeDate;
  int? maxStaleDate;
  int? statusCode;

  Object? content;
  List<int>? headers;

  factory HttpCacheObj(String key, Object? content,
      {String? subKey = '',
      Duration? maxAge,
      Duration? maxStale,
      int? statusCode = 200,
      List<int>? headers}) {
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
      maxAgeDate = _convertDuration(duration);
    }
  }

  set maxStale(Duration? duration) {
    if (null != duration) {
      maxStaleDate = _convertDuration(duration);
    }
  }

  int _convertDuration(Duration duration) =>
      DateTime.now().add(duration).millisecondsSinceEpoch;

  factory HttpCacheObj.fromJson(Map<String, dynamic> json) {
    var _content = json['content'];
    if (_content is List) {
      _content = _content.map((e) => e as int).toList();
    }
    final _header = json['headers'] as List<int>?;
    // if (_header != null) {
    //   _header = _header.map((e) => e).toList();
    // }
    return HttpCacheObj(
      json['key'] as String,
      _content,
      headers: _header,
      subKey: json['subKey'] as String?,
      statusCode: json['statusCode'] as int?,
    )
      ..maxAgeDate = json['max_age_date'] as int?
      ..maxStaleDate = json['max_stale_date'] as int?;
  }

  Future<void> setEncryption(CacheEncryption<Object?> _encryption) async {
    if (content != null) {
      content = await _encryption.encryptCacheStr(content);
    }
    if (headers != null) {
      final result = await _encryption.encryptCacheStr(headers);
      if (result is List<int>) {
        headers = result;
      }
    }
  }

  Future<void> setDecryption(CacheEncryption<Object?> _encryption) async {
    if (content != null) {
      content = await _encryption.decryptCacheStr(content);
    }
    if (headers != null) {
      final result = await _encryption.decryptCacheStr(headers);
      if (result is List<int>) {
        headers = result;
      }
    }
  }

  Map<String, Object?> get toHttpTable {
    return {
      HttpTableColumnKey.key.name: key,
      HttpTableColumnKey.subKey.name: '$subKey',
      HttpTableColumnKey.maxAgeDate.name: maxAgeDate ?? 0,
      HttpTableColumnKey.maxStaleDate.name: maxStaleDate ?? 0,
      HttpTableColumnKey.statusCode.name: statusCode,
      HttpTableColumnKey.content.name: jsonEncode(content),
      HttpTableColumnKey.headers.name: headers
    };
  }
}

import 'package:dio/dio.dart';
import 'package:dio_http_cache_extension/src/const/store_cache_key.dart';

final _primaryKey = DioCacheKey.primaryKey.name;
final _subKey = DioCacheKey.subKey.name;

extension RequestOptionsExt on RequestOptions {
  String get primaryKey {
    final primaryKey = extra.containsKey(_primaryKey)
        ? extra[_primaryKey]
        : _getPrimaryKeyFromUri(uri);

    return '$method-$primaryKey';
  }

  String get subKey {
    return extra.containsKey(_subKey)
        ? extra[DioCacheKey.subKey.name].toString()
        : _getSubKeyFromUri(uri, data: data);
  }

  String _getPrimaryKeyFromUri(Uri uri) => uri.toString();

  String _getSubKeyFromUri(Uri uri, {dynamic data}) =>
      '${data?.toString()}_${uri.query}';
}

part of 'http_cache_manager.dart';

class _HttpCacheManagerImpl extends HttpCacheManager {
  _HttpCacheManagerImpl(IHttpLocalCacheRepository localCache)
      : super._(localCache);
  InterceptorsWrapper? _interceptor;

  @override
  InterceptorsWrapper get interceptor {
    _interceptor ??= InterceptorsWrapper(
        onRequest: _onRequest, onResponse: _onResponse, onError: _onError);
    return _interceptor!;
  }

  Future<void> _onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if ((options.extra[DioCacheKey.tryCache.name] ?? false) != true) {
      return handler.next(options);
    }
    if (true == options.extra[DioCacheKey.forceRefresh.name]) {
      return handler.next(options);
    }
    final responseDataFromCache = await _pullFromCacheBeforeMaxAge(options);
    if (null != responseDataFromCache) {
      return handler.resolve(
          _buildResponse(
              responseDataFromCache, responseDataFromCache.statusCode, options),
          true);
    }
    return handler.next(options);
  }

  Future<void> _onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) async {
    if ((response.requestOptions.extra[DioCacheKey.tryCache.name] ?? false) ==
            true &&
        response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      await _pushToCache(response);
    }
    return handler.next(response);
  }

  Future<void> _onError(DioException e, ErrorInterceptorHandler handler) async {
    if ((e.requestOptions.extra[DioCacheKey.tryCache.name] ?? false) == true) {
      final responseDataFromCache =
          await _pullFromCacheBeforeMaxStale(e.requestOptions);
      if (null != responseDataFromCache) {
        final response = _buildResponse(responseDataFromCache,
            responseDataFromCache.statusCode, e.requestOptions);

        return handler.resolve(response);
      }
    }
    return handler.next(e);
  }

  Future<HttpCacheObj?> _pullFromCacheBeforeMaxStale(RequestOptions options) {
    return _localCache.pullFromCacheBeforeMaxStale(
      options.primaryKey,
      subKey: options.subKey,
    );
  }

  Future<bool> _pushToCache(Response<dynamic> response) {
    final RequestOptions options = response.requestOptions;
    var maxAge = options.extra[DioCacheKey.maxAge.name] as Duration?;
    var maxStale = options.extra[DioCacheKey.maxStale.name] as Duration?;
    if (null == maxAge) {
      _tryParseHead(response, maxStale, (_maxAge, _maxStale) {
        maxAge = _maxAge;
        maxStale = _maxStale;
      });
    }
    final obj = HttpCacheObj(
      options.primaryKey,
      response.data,
      subKey: options.subKey,
      maxAge: maxAge,
      maxStale: maxStale,
      statusCode: response.statusCode,
      headers: utf8.encode(jsonEncode(response.headers.map)),
    );
    return _localCache.pushToCache(obj);
  }

  // try to get maxAge and maxStale from http headers
  void _tryParseHead(
    Response<dynamic> response,
    Duration? maxStale,
    void Function(Duration?, Duration?) callback,
  ) {
    Duration? _maxAge;
    final cacheControl = response.headers.value(HttpHeaders.cacheControlHeader);
    if (null != cacheControl) {
      // try to get maxAge and maxStale from cacheControl
      Map<String, String?> parameters;
      try {
        parameters = HeaderValue.parse(
                '${HttpHeaders.cacheControlHeader}: $cacheControl',
                parameterSeparator: ',',
                valueSeparator: '=')
            .parameters;
        _maxAge = _tryGetDurationFromMap(parameters, 's-maxage');
        _maxAge ??= _tryGetDurationFromMap(parameters, 'max-age');
        // if maxStale has valued, don't get max-stale anymore.
        maxStale ??= _tryGetDurationFromMap(parameters, 'max-stale');
      } catch (e) {
        print(e);
      }
    } else {
      // try to get maxAge from expires
      final expires = response.headers.value(HttpHeaders.expiresHeader);
      if (null != expires && expires.length > 4) {
        DateTime? endTime;
        try {
          endTime = HttpDate.parse(expires).toLocal();
        } catch (e) {
          print(e);
        }
        if (null != endTime && endTime.compareTo(DateTime.now()) >= 0) {
          _maxAge = endTime.difference(DateTime.now());
        }
      }
    }
    callback(_maxAge, maxStale);
  }

  Duration? _tryGetDurationFromMap(
      Map<String, String?> parameters, String key) {
    if (parameters.containsKey(key)) {
      final value = int.tryParse(parameters[key]!);
      if (null != value && value >= 0) {
        return Duration(seconds: value);
      }
    }
    return null;
  }

  Future<HttpCacheObj?> _pullFromCacheBeforeMaxAge(RequestOptions options) {
    return _localCache.pullFromCacheBeforeMaxAge(
      options.primaryKey,
      subKey: options.subKey,
    );
  }

  Response<dynamic> _buildResponse(
      HttpCacheObj obj, int? statusCode, RequestOptions options) {
    Headers? headers;
    final _bytes = obj.headers;
    if (null != _bytes) {
      final _parsedBytes = jsonDecode(utf8.decode(_bytes)) as Map?;
      if (_parsedBytes != null) {
        headers = Headers.fromMap(
          Map<String, List<dynamic>>.from(_parsedBytes).map(
            (k, v) => MapEntry(k, List<String>.from(v)),
          ),
        );
      }
    }
    if (null == headers) {
      headers = Headers();
      options.headers.forEach((k, v) => headers!.add(k, '$v'));
    }
    // add flag
    headers.add(DioCacheKey.headerKeyDataSource.name, 'from_cache');
    Object? data = obj.content;
    if (options.responseType != ResponseType.bytes) {
      if (data is List<int>) {
        data = jsonDecode(utf8.decode(data));
      }
    }
    return Response(
        data: data,
        headers: headers,
        requestOptions: options.copyWith(
            extra: options.extra..remove(DioCacheKey.tryCache.name)),
        statusCode: statusCode ?? 200);
  }

  @override
  Future<bool> clearAll() => _localCache.clearAll();

  @override
  Future<bool> clearExpired() => _localCache.clearExpired();

  @override
  Future<bool> delete(String primaryKey,
      {String? requestMethod, String? subKey}) {
    return _localCache.delete('${_getRequestMethod(requestMethod)}-$primaryKey',
        subKey: subKey);
  }

  @override
  Future<bool> deleteByPrimaryKey(String path, {String? requestMethod}) {
    return deleteByPrimaryKeyWithUri(_getUriByPath(_baseUrl, path).uri,
        requestMethod: requestMethod);
  }

  @override
  Future<bool> deleteByPrimaryKeyAndSubKeyWithUri(Uri uri,
      {String? requestMethod, String? subKey, data}) {
    return delete(_getPrimaryKeyFromUri(uri),
        requestMethod: requestMethod,
        subKey: subKey ?? _getSubKeyFromUri(uri, data: data));
  }

  @override
  Future<bool> deleteByPrimaryKeyWithUri(Uri uri, {String? requestMethod}) {
    return delete(_getPrimaryKeyFromUri(uri), requestMethod: requestMethod);
  }

  @override
  Future<bool> deleteByPrimaryKeyAndSubKey(String path,
      {String? requestMethod,
      Map<String, dynamic>? queryParameters,
      String? subKey,
      data}) {
    return deleteByPrimaryKeyAndSubKeyWithUri(
        _getUriByPath(_baseUrl, path,
                data: data, queryParameters: queryParameters)
            .uri,
        requestMethod: requestMethod,
        subKey: subKey,
        data: data);
  }
}

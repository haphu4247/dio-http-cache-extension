class HttpCacheSetting {
  final Duration defaultMaxAge;
  final Duration? defaultMaxStale;
  final String? databasePath;
  final String databaseName;
  final String? baseUrl;
  final String defaultRequestMethod;

  final bool skipMemoryCache;
  final bool skipDbCache;

  final int maxMemoryCacheCount;

  HttpCacheSetting({
    this.defaultMaxAge = const Duration(days: 7),
    this.defaultMaxStale,
    this.defaultRequestMethod = 'POST',
    this.databasePath,
    this.databaseName = 'DioCache',
    this.baseUrl,
    this.skipDbCache = false,
    this.skipMemoryCache = false,
    this.maxMemoryCacheCount = 100,
  });
}

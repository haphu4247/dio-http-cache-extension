enum DioCacheKey {
  tryCache('dio_cache_try_cache'),
  maxAge('dio_cache_max_age'),
  maxStale('dio_cache_max_stale'),
  primaryKey('dio_cache_primary_key'),
  subKey('dio_cache_sub_key'),
  forceRefresh('dio_cache_force_refresh'),
  headerKeyDataSource('dio_cache_header_key_data_source');

  const DioCacheKey(this.name);
  final String name;
}

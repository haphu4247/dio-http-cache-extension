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
}

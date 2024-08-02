class CacheEncryption<T> {
  const CacheEncryption(
      {Future<T> Function(T data)? encrypt,
      Future<T> Function(T data)? decrypt})
      : _encrypt = encrypt,
        _decrypt = decrypt;
  final Future<T> Function(T data)? _encrypt;
  final Future<T> Function(T data)? _decrypt;

  Future<dynamic> encryptCacheResponse(T data) async {
    if (_encrypt != null) {
      return _encrypt!(data);
    }
    return data;
  }

  Future<dynamic> decryptCacheResponse(T data) async {
    if (_decrypt != null) {
      return _decrypt!(data);
    }
    return data;
  }
}

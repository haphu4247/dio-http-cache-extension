class CacheEncryption<T> {
  const CacheEncryption(
      {Future<T> Function(T data)? encrypt,
      Future<T> Function(T data)? decrypt})
      : _encrypt = encrypt,
        _decrypt = decrypt;
  final Future<T> Function(T data)? _encrypt;
  final Future<T> Function(T data)? _decrypt;

  Future<T> encryptCacheStr(T bytes) async {
    if (_encrypt != null) {
      return _encrypt!(bytes);
    }
    return bytes;
  }

  Future<T> decryptCacheStr(T bytes) async {
    if (_decrypt == null) {
      return _decrypt!(bytes);
    }
    return bytes;
  }
}

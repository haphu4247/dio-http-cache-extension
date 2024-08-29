import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:sqflite/utils/utils.dart';

class CacheUtils {
  const CacheUtils._();

  static String convertToMd5(String input) {
    final bytes = md5.convert(utf8.encode(input)).bytes;
    return hex(bytes);
  }

  static Headers? parseHeadersFromBlob(dynamic data) {
    if (data is List) {
      final _bytes = data.map((e) => e as int).toList();
      final _jsonString = utf8.decode(_bytes);
      final _json = jsonDecode(_jsonString) as Map?;
      if (_json != null) {
        return Headers.fromMap(
          Map<String, List<dynamic>>.from(_json).map(
            (k, v) => MapEntry(k, List<String>.from(v)),
          ),
        );
      }
    }
    return null;
  }

  static Object? parseDataFromBlob(dynamic blob) {
    if (blob is List) {
      final _bytes = blob.map((e) => e as int).toList();
      try {
        final _jsonString = utf8.decode(_bytes);
        return jsonDecode(_jsonString);
      } catch (e) {
        return blob;
      }
    }
    return blob;
  }

  static Uint8List convertToBlob(Object? data) {
    if (data is List<int>) {
      return Uint8List.fromList(data);
    }
    return utf8.encode(jsonEncode(data));
  }

  static int convertDuration(Duration duration) =>
      DateTime.now().add(duration).millisecondsSinceEpoch;
}

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sqflite/utils/utils.dart';

class EncryptHelper {
  const EncryptHelper._();

  static String convertToMd5(String input) {
    final bytes = md5.convert(utf8.encode(input)).bytes;
    return hex(bytes);
  }
}

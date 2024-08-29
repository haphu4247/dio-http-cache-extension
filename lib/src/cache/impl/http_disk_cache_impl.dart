import 'dart:io';

import 'package:dio_http_cache_extension/src/const/http_table_column_key.dart';
import 'package:dio_http_cache_extension/src/utils/cache_utils.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../http_cache.dart';
import '../../models/http_cache_obj.dart';

class HttpDiskCacheImpl extends IHttpCache {
  HttpDiskCacheImpl({
    this.databasePath,
    required this.databaseName,
  });

  final String? databasePath;
  final String databaseName;
  final String _tableCacheObject = 'cache_dio';

  Database? _db;
  static const int _curDBVersion = 3;

  Future<Database?> get _database async {
    if (null == _db) {
      var path = databasePath;
      if (null == path || path.isEmpty) {
        path = await getDatabasesPath();
      }
      await Directory(path).create(recursive: true);
      path = join(path, '$databaseName.db');
      _db = await openDatabase(
        path,
        version: _curDBVersion,
        onConfigure: (db) => _tryFixDbNoVersionBug(db, path!),
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
      await _clearExpired(_db);
    }
    return _db;
  }

  Future<dynamic> _tryFixDbNoVersionBug(Database db, String dbPath) async {
    if ((await db.getVersion()) == 0) {
      final isTableUserLogExist = await db
          .rawQuery(
              "select DISTINCT tbl_name from sqlite_master where tbl_name = '$_tableCacheObject'")
          .then((v) => v.isNotEmpty);
      if (isTableUserLogExist) {
        await db.setVersion(1);
      }
    }
  }

  String get _createTableSql =>
      HttpTableColumnKey.createTableSql(_tableCacheObject);

  Future<void> _onCreate(Database db, int version) {
    return db.execute(_createTableSql);
  }

  List<List<String>?> _dbUpgradeList() => [
        // 0 -> 1
        null,
        // 1 -> 2
        [
          'ALTER TABLE $_tableCacheObject ADD COLUMN ${HttpTableColumnKey.statusCode.name} integer;'
        ],
        // 2 -> 3 : Change $_columnContent from text to BLOB
        ['DROP TABLE IF EXISTS $_tableCacheObject;', _createTableSql],
      ];

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    final mergeLength = _dbUpgradeList().length;
    if (oldVersion < 0 || oldVersion >= mergeLength) {
      return;
    }
    await db.transaction((txn) async {
      var tempVersion = oldVersion;
      while (tempVersion < newVersion) {
        if (tempVersion < mergeLength) {
          final sqlList = _dbUpgradeList()[tempVersion];
          if (null != sqlList && sqlList.isNotEmpty) {
            sqlList.forEach((sql) async {
              sql = sql.trim();
              if (sql.isNotEmpty) {
                await txn.execute(sql);
              }
            });
          }
        }
        tempVersion++;
      }
    });
  }

  @override
  Future<HttpCacheObj?> getCacheObj(String key, {String? subKey}) async {
    final db = await _database;
    if (null == db) {
      return null;
    }
    var where = '${HttpTableColumnKey.key.name}="$key"';
    if (null != subKey) {
      where += ' and ${HttpTableColumnKey.subKey.name}="$subKey"';
    }
    final resultList =
        await db.query(_tableCacheObject, where: where, limit: 1);
    if (resultList.isEmpty) {
      return null;
    }
    return _parseObj(resultList.first);
  }

  Future<HttpCacheObj> _parseObj(Map<String, Object?> json) async {
    var _content = CacheUtils.parseDataFromBlob(json['content']);
    // _content = await cacheEncryption.decryptCacheResponse(_content);
    return HttpCacheObj.fromDatabase(
      json: json,
      content: _content,
    );
  }

  @override
  Future<bool> setCacheObj(HttpCacheObj obj) async {
    final db = await _database;
    if (null == db) {
      return false;
    }
    final values = await HttpTableColumnKey.mappingObj(obj: obj);
    final result = await db.insert(_tableCacheObject, values,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return result != 0;
  }

  @override
  Future<bool> delete(String key, {String? subKey}) async {
    final db = await _database;
    if (null == db) {
      return false;
    }
    var where = '${HttpTableColumnKey.key.name}="$key"';
    if (null != subKey) {
      where += ' and ${HttpTableColumnKey.subKey.name}="$subKey"';
    }
    print('delete key: $key');
    print('delete subKey: $subKey');
    //#result ==> number of row is deleted
    final resultRow = await db.delete(_tableCacheObject, where: where);
    return resultRow > 0;
  }

  @override
  Future<bool> clearExpired() async {
    final db = await _database;
    return _clearExpired(db);
  }

  Future<bool> _clearExpired(Database? db) async {
    if (null == db) {
      return false;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final where1 =
        '${HttpTableColumnKey.maxStaleDate.name} > 0 and ${HttpTableColumnKey.maxStaleDate.name} < $now';
    final where2 =
        '${HttpTableColumnKey.maxStaleDate.name} <= 0 and ${HttpTableColumnKey.maxAgeDate.name} < $now';
    return 0 !=
        await db.delete(_tableCacheObject, where: '( $where1 ) or ( $where2 )');
  }

  @override
  Future<bool> clearAll() async {
    final db = await _database;
    if (null == db) {
      return false;
    }
    return 0 != await db.delete(_tableCacheObject);
  }
}

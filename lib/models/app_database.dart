import 'dart:convert';
import 'dart:io';
import 'package:hex/hex.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  var _databaseName;
  var _database;

  AppDatabase(name) {
    _databaseName = name;
  }

  Future<void> open() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, '$_databaseName.db');

    try {
      await Directory(databasesPath).create(recursive: true);
    } catch (_) {
      return;
    }

    _database = await openDatabase(path, version: 1,
        onCreate: (Database _database, int version) async {
      await _database.execute(
          'CREATE TABLE starred (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT , spec TEXT)');
    });
  }

  Future<void> close() async {
    if (_database == null) {
      return;
    }
    await _database.close();
    _database = null;
  }

  Future<List<Map<String, String>>> getStarred() async {
    if (_database == null) {
      return List<Map<String, String>>.empty();
    }

    var rawList = await _database.query('starred', columns: ['name', 'spec']);

    List<Map<String, String>> starred = [];
    for (var item in rawList) {
      String nameHex = item['name'].toString();
      String specHex = item['spec'].toString();
      var name = decodeUtf8Hex(nameHex);
      var spec = decodeUtf8Hex(specHex);
      starred.add({'name': name, 'spec': spec});
    }

    return starred;
  }

  Future<int> addStarred(String name, String spec) async {
    if (_database == null) {
      return 0;
    }

    // TODO: Why does this throw an exception?
    // var row = {
    //   'name': name,
    //   'spec': spec,
    // };
    // await _database.insert('starred', row,
    //     ConflictAlgorithm: ConflictAlgorithm.replace);

    // TODO: until the exception issue is resolved, convert strings to hex
    // to sanitize them for use in raw database operations.
    final nameHex = encodeUtf8Hex(name);
    final specHex = encodeUtf8Hex(spec);

    List<Map> recordList = await _database
        .rawQuery('SELECT * from starred WHERE name = "$nameHex"');
    if (recordList.isEmpty) {
      await _database.rawInsert(
          'INSERT INTO starred (name, spec) VALUES("$nameHex", "$specHex")');
    } else {
      await _database.rawUpdate(
          'UPDATE starred SET spec = ? WHERE name = ?', [specHex, nameHex]);
    }

    return 1;
  }

  Future<int> deleteStarred(name) async {
    if (_database == null) {
      return 0;
    }

    final nameHex = encodeUtf8Hex(name);
    var count = await _database
        .delete('starred', where: 'name = ?', whereArgs: [nameHex]);
    return count;
  }

  static String encodeUtf8Hex(String text) {
    final textUtf8 = Utf8Codec().encoder.convert(text);
    return HexCodec().encoder.convert(textUtf8);
  }

  static String decodeUtf8Hex(String text) {
    final textUtf8 = HexCodec().decoder.convert(text);
    return Utf8Codec().decoder.convert(textUtf8);
  }

  bool get opened => _database != null;
}

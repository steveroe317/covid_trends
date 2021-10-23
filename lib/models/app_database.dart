// Copyright 2021 Stephen Roe
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.import 'dart:collection';

import 'dart:convert';
import 'dart:io';
import 'package:hex/hex.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  var _databaseName;
  var _database;

  AppDatabase(String name) : _databaseName = name;

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

    final hexRegExp = RegExp(r'^[0-9a-fA-F]*$');

    List<Map<String, String>> starred = [];
    for (var item in rawList) {
      String name = item['name'].toString();
      String spec = item['spec'].toString();

      // If fields are stored as hex strings decode them,
      // then update the database to contain the decoded versions.
      // TODO: remove hex decode after all test installations are updated.
      if (hexRegExp.hasMatch(name)) {
        var nameHex = name;
        name = decodeUtf8Hex(name);
        spec = decodeUtf8Hex(spec);
        addStarred(name, spec);
        await _database
            .delete('starred', where: 'name = ?', whereArgs: [nameHex]);
      }

      starred.add({'name': name, 'spec': spec});
    }

    return starred;
  }

  Future<int> addStarred(String name, String spec) async {
    if (_database == null) {
      return 0;
    }

    var row = {
      'name': name,
      'spec': spec,
    };
    await _database.insert('starred', row,
        conflictAlgorithm: ConflictAlgorithm.replace);

    return 1;
  }

  Future<int> deleteStarred(name) async {
    if (_database == null) {
      return 0;
    }

    var count =
        await _database.delete('starred', where: 'name = ?', whereArgs: [name]);

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

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

import 'app_database.dart';
import 'starred_model.dart';

class AppDataCache {
  String _name;
  AppDatabase? _database;
  Map<String, StarredModel> _starred = {};
  bool _initialized = false;

  AppDataCache(String name) : _name = name;

  Future<void> initialize() async {
    _database = AppDatabase(_name);
    await _database?.open();

    _starred = Map<String, StarredModel>();
    var starredData = await _database?.getStarred();
    if (starredData != null) {
      for (var data in starredData) {
        var name = data['name'];
        var jsonSpec = data['spec'];
        if (name != null && jsonSpec != null) {
          _starred[name] = StarredModel.fromJson(jsonDecode(jsonSpec));
        }
      }
    }

    _initialized = true;
  }

  List<String> getStarredNames() {
    if (!_initialized) {
      return List<String>.empty();
    }
    return List<String>.from(_starred.keys);
  }

  void addStarred(String name, StarredModel star) {
    if (!_initialized) {
      return;
    }
    _starred[name] = star;
    _database?.addStarred(name, jsonEncode(star));
  }

  StarredModel? getStarred(String name) {
    if (!_initialized) {
      return null;
    }
    if (!_starred.containsKey(name)) {
      return null;
    }
    return _starred[name];
  }

  void deleteStarred(name) {
    if (!_initialized) {
      return;
    }
    if (_starred.containsKey(name)) {
      _starred.remove(name);
    }
    _database?.deleteStarred(name);
  }
}

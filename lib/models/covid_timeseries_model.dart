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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'admin_entity.dart';
import 'region_metric_id.dart';
import 'covid_series_id.dart';
import 'model_constants.dart';

class CovidTimeseriesModel with ChangeNotifier {
  bool _initialized = false;
  AdminEntity _rootEntity = AdminEntity.empty();

  void initialize() async {
    if (!_initialized) {
      _initialized = true;
      _rootEntity =
          await AdminEntity.create([ModelConstants.rootEntityName], null);
      notifyListeners();
    }
  }

  List<RegionMetricId> get populationMetrics => _rootEntity.populationMetrics;

  bool get initialized => _initialized;

  AdminEntity? _findEntity(List<String> path, AdminEntity? entity) {
    if (path.length == 0) {
      if (entity != null && entity.isStale) {
        refreshEntity(entity);
      }
      return entity;
    }
    if (entity == null) {
      if (path.first == ModelConstants.rootEntityName) {
        return _findEntity(path.sublist(1), _rootEntity);
      } else {
        return null;
      }
    }
    if (!entity.childIndexContains(path.first)) {
      return null;
    } else if (!entity.childrenContains(path.first)) {
      return null;
    } else {
      return _findEntity(path.sublist(1), entity.child(path.first));
    }
  }

  void loadEntities(List<List<String>> paths) async {
    for (var path in paths) {
      await loadRegion(path);
    }
    notifyListeners();

    // This retry works around an issue where starting up and restoring
    // a view of a single country results in the country not being findable.
    // The issue might be a bug in flutter but is hard to analyze because it
    // only occurred in release builds on physical iOS devices.
    await Future.delayed(Duration(milliseconds: 200));
    for (var path in paths) {
      if (_findEntity(path, null) == null) {
        await loadRegion(path);
      }
    }
    notifyListeners();
  }

  Future<void> loadRegion(List<String> path) async {
    AdminEntity? parent;
    bool entityCreated = false;
    for (var depth = 1; depth <= path.length; ++depth) {
      var childLocalPath = path.sublist(depth - 1, depth);
      var child = _findEntity(childLocalPath, parent);
      if (child == null) {
        var childFullPath = path.sublist(0, depth);
        child = await AdminEntity.create(childFullPath, parent);
        entityCreated = true;
      }
      parent = child;
    }
    if (entityCreated) {
      notifyListeners();
    }
  }

  void refreshEntity(AdminEntity entity) async {
    if (entity.path.length > 0) {
      await entity.refresh();
      notifyListeners();
    }
  }

  List<int> entityTimestamps(List<String> path, {seriesLength = 0}) {
    var entity = _findEntity(path, null);
    if (entity != null) {
      return entity.timestamps(seriesLength: seriesLength);
    } else {
      return List<int>.empty();
    }
  }

  List<double> entitySeriesData(List<String> path, CovidSeriesId seriesId,
      {seriesLength = 0, per100k = false}) {
    var entity = _findEntity(path, null);
    if (entity != null) {
      return entity.seriesData(seriesId,
          seriesLength: seriesLength, per100k: per100k);
    } else {
      return List<double>.empty();
    }
  }

  bool regionHasChildren(List<String> path) {
    if (path.length == 0) {
      return false;
    }
    if (path.length == 1) {
      var entity = _findEntity(path, null);
      if (entity != null) {
        return entity.hasChildren;
      }
      return false;
    }
    var entity = _findEntity(path.sublist(0, path.length - 1), null);
    if (entity != null) {
      return entity.childHasChildren(path.last);
    }
    return false;
  }

  List<String> regionChildNames(List<String> path,
      {RegionMetricId sortMetricId = RegionMetricId.None,
      bool sortUp = true,
      bool per100k = false}) {
    var entity = _findEntity(path, null);
    if (entity != null) {
      return entity.childNames(
          sortBy: sortMetricId, sortUp: sortUp, per100k: per100k);
    } else {
      return List<String>.empty();
    }
  }

  double regionSortMetric(
      List<String> path, RegionMetricId sortMetricId, bool per100k) {
    if (path.isEmpty) {
      return 0.0;
    }

    if (path.length == 1) {
      var root = _findEntity(path, null);
      if (root == null) {
        return 0.0;
      }
      return root.sortMetricValue(sortMetricId, per100k);
    }

    var parentPath = path.sublist(0, path.length - 1);
    var entity = _findEntity(parentPath, null);
    if (entity == null) {
      return 0.0;
    }
    return entity.childSortMetricValue(path.last, sortMetricId, per100k);
  }

  void halveHistory() {
    print('DEBUG: Halve History');
    _rootEntity.halveTreeHistory();
    notifyListeners();
  }

  void markStale() {
    _rootEntity.markTreeStale();
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';

import 'admin_entity.dart';
import 'model_constants.dart';

class CovidTimeseriesModel with ChangeNotifier {
  bool _initialized = false;
  AdminEntity _rootEntity = AdminEntity.empty();

  // TODO: Why is initialize() called 3 times on startup?  Can this be reduced?
  void initialize() async {
    if (!_initialized) {
      _initialized = true;
      _rootEntity =
          await AdminEntity.create([ModelConstants.rootEntityName], null);
      notifyListeners();
    }
  }

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
    if (entity.childrenContains(path.first)) {
      return _findEntity(path.sublist(1), entity.child(path.first));
    } else {
      return null;
    }
  }

  void loadEntities(List<List<String>> paths) async {
    for (var path in paths) {
      await loadEntityFromRoot(path);
    }
  }

  void loadEntity(List<String> path) async {
    if (_findEntity(path, null) == null && path.length > 1) {
      var parent = _findEntity(path.sublist(0, path.length - 1), null);
      if (parent != null) {
        await AdminEntity.create(path, parent);
        notifyListeners();
      }
    }
  }

  Future<void> loadEntityFromRoot(List<String> path) async {
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

  List<double> entitySeriesData(List<String> path, String key,
      {seriesLength = 0, per100k = false}) {
    var entity = _findEntity(path, null);
    if (entity != null) {
      return entity.seriesData(key,
          seriesLength: seriesLength, per100k: per100k);
    } else {
      return List<double>.empty();
    }
  }

  bool entityHasChildren(List<String> path) {
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

  List<String> entityChildNames(List<String> path,
      {String sortBy = '', bool sortUp = true, bool per100k = false}) {
    var entity = _findEntity(path, null);
    if (entity != null) {
      return entity.childNames(
          sortBy: sortBy, sortUp: sortUp, per100k: per100k);
    } else {
      return List<String>.empty();
    }
  }

  double entitySortMetric(List<String> path, String sortMetric, bool per100k) {
    if (path.isEmpty) {
      return 0.0;
    }

    if (path.length == 1) {
      var root = _findEntity(path, null);
      if (root == null) {
        return 0.0;
      }
      return root.sortMetricValue(sortMetric, per100k);
    }

    var parentPath = path.sublist(0, path.length - 1);
    var entity = _findEntity(parentPath, null);
    if (entity == null) {
      return 0.0;
    }
    return entity.childSortMetricValue(path.last, sortMetric, per100k);
  }

  List<String> sortMetrics() {
    return _rootEntity.childMetricNames();
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
}

import 'package:flutter/foundation.dart';

import 'admin_entity.dart';

class CovidTimeseriesModel with ChangeNotifier {
  bool _initialized = false;
  AdminEntity _rootEntity = AdminEntity.empty();

  void initialize() async {
    if (!_initialized) {
      _initialized = true;
      _rootEntity = await AdminEntity.create(['World'], null);
      notifyListeners();
    }
  }

  bool get initialized => _initialized;

  AdminEntity _findEntity(List<String> path, AdminEntity entity) {
    if (path.length == 0) {
      return entity;
    }
    if (entity == null) {
      if (path.first == 'World') {
        return _findEntity(path.sublist(1), _rootEntity);
      } else {
        return null;
      }
    }
    if (entity.subEntitiesContains(path.first)) {
      return _findEntity(path.sublist(1), entity.subEntity(path.first));
    } else {
      return null;
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

  List<int> entityTimestamps(List<String> path) {
    var entity = _findEntity(path, null);
    if (entity != null) {
      return entity.timestamps;
    } else {
      return List<int>.empty();
    }
  }

  List<int> entitySeriesData(List<String> path, String key) {
    var entity = _findEntity(path, null);
    if (entity != null) {
      return entity.seriesData(key);
    } else {
      return List<int>.empty();
    }
  }

  bool entityHasSubEntities(List<String> path) {
    if (path.length == 0) {
      return false;
    }
    if (path.length == 1) {
      var entity = _findEntity(path, null);
      if (entity != null) {
        return entity.hasSubEntities;
      }
      return false;
    }
    var entity = _findEntity(path.sublist(0, path.length - 1), null);
    if (entity != null) {
      return entity.subEntityHasChildren(path.last);
    }
    return false;
  }

  List<String> entitySubEntityNames(List<String> path) {
    var entity = _findEntity(path, null);
    if (entity != null) {
      return entity.subEntityNames();
    } else {
      return List<String>.empty();
    }
  }
}

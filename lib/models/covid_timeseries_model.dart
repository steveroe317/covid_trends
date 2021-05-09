import 'package:flutter/foundation.dart';

import 'admin_entity.dart';

class CovidTimeseriesModel with ChangeNotifier {
  bool _initialized = false;
  AdminEntity _rootEntity = AdminEntity.empty();
  AdminEntity _currentEntity = AdminEntity.empty();

  void initialize() async {
    if (!_initialized) {
      _initialized = true;
      _rootEntity = await AdminEntity.create(['World'], null);
      _currentEntity = _rootEntity;
      notifyListeners();
      await _rootEntity.loadSubEntities();
      notifyListeners();
    }
  }

  bool get initialized => _initialized;

  List<String> get path => _currentEntity.path;

  List<String> get subEntityNames => _currentEntity.subEntityNames;

  void openSubEntity(String name) async {
    _currentEntity = _currentEntity.subEntity(name);
    notifyListeners();
    await _currentEntity.loadSubEntities();
    notifyListeners();
  }

  AdminEntity _findEntity(List<String> path, AdminEntity entity) {
    if (entity == null) {
      if (path.first == 'World') {
        return _findEntity(path.sublist(1), _rootEntity);
      } else {
        return null;
      }
    }
    if (path.length == 0) {
      return entity;
    } else if (entity.subEntityNames.contains(path.first)) {
      return _findEntity(path.sublist(1), entity.subEntity(path.first));
    } else {
      return null;
    }
  }

  void openPath(List<String> path) {
    var entity = _findEntity(path, null);
    if (entity != null) {
      _currentEntity = entity;
      notifyListeners();
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
}

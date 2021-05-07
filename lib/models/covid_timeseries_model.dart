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

  AdminEntity get parent => _currentEntity.parent;

  List<int> get timestamps => _currentEntity.timestamps;

  List<int> seriesData(String key) => _currentEntity.seriesData(key);

  List<String> get subEntityNames => _currentEntity.subEntityNames;

  void openSubEntity(String name) async {
    _currentEntity = _currentEntity.subEntity(name);
    notifyListeners();
    await _currentEntity.loadSubEntities();
    notifyListeners();
  }

  void openParent() {
    if (_currentEntity.parent != null) {
      _currentEntity = _currentEntity.parent;
      notifyListeners();
    }
  }
}

import 'package:flutter/foundation.dart';

class CovidEntitiesPageModel with ChangeNotifier {
  CovidEntitiesPageModel(this._path);
  List<String> _path;
  String _sortMetric = 'Name';

  List<String> path() {
    return List<String>.from(_path);
  }

  void setPath(List<String> path) {
    _path = List<String>.from(path);
    notifyListeners();
  }

  String get sortMetric => _sortMetric;

  set sortMetric(value) {
    _sortMetric = value;
    notifyListeners();
  }
}

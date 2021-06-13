import 'package:flutter/foundation.dart';

class CovidEntitiesPageModel with ChangeNotifier {
  List<String> _path = List<String>.empty();
  List<String> _chartPath = List<String>.empty();
  String _sortMetric = 'Name';
  int _seriesLength = 60;

  CovidEntitiesPageModel(List<String> path) {
    _path = List<String>.from(path);
    _chartPath = List<String>.from(path);
  }

  List<String> path() {
    return List<String>.from(_path);
  }

  void setPath(List<String> path) {
    _path = List<String>.from(path);
    _chartPath = List<String>.from(path);
    notifyListeners();
  }

  List<String> chartPath() {
    return List<String>.from(_chartPath);
  }

  void setChartPath(List<String> chartPath) {
    _chartPath = List<String>.from(chartPath);
    notifyListeners();
  }

  String get sortMetric => _sortMetric;

  set sortMetric(value) {
    _sortMetric = value;
    notifyListeners();
  }

  int get seriesLength => _seriesLength;

  void setSeriesLength(seriesLength) {
    _seriesLength = seriesLength;
    notifyListeners();
  }
}

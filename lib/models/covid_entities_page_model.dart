import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../widgets/ui_constants.dart';
import 'model_constants.dart';

class CovidEntitiesPageModel with ChangeNotifier {
  static const maxPathListLength = 4;
  List<String> _path = List<String>.empty();
  List<String> _chartPath = List<String>.empty();
  var _pathList = <List<String>>[
    [ModelConstants.rootEntityName]
  ];
  String _sortMetric = UiConstants.noSortMetricName;
  int _seriesLength = 0;
  bool _per100k = false;
  bool _compareRegion = false;

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

  List<List<String>> get pathList => _pathList;

  void addPathList(List<String> path) {
    for (var existingPath in _pathList) {
      if (listEquals(path, existingPath)) {
        return;
      }
    }
    if (_pathList.length >= maxPathListLength) {
      _pathList.removeAt(0);
    }
    _pathList.add(path);
    notifyListeners();
  }

  void clearPathList() {
    _pathList = <List<String>>[];
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

  bool get per100k => _per100k;

  void setPer100k(bool value) {
    _per100k = value;
    notifyListeners();
  }

  bool get compareRegion => _compareRegion;

  void setCompareRegion(bool value) {
    _compareRegion = value;
    notifyListeners();
  }

  List<Color> generateColors(int count) {
    var colors = <Color>[];
    var hue = 240.0;
    const double hueStep = 77.0;
    for (var index = 0; index < count; ++index) {
      var hslColor = HSLColor.fromAHSL(1.0, hue, 0.5, 0.5);
      colors.add(hslColor.toColor());
      hue += hueStep;
      if (hue > 360.0) {
        hue -= 360;
      }
    }
    return colors;
  }
}

import 'package:covid_trends/models/starred_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../widgets/ui_constants.dart';
import 'app_data_cache.dart';
import 'model_constants.dart';
import 'starred_model.dart';

class CovidEntitiesPageModel with ChangeNotifier {
  AppDataCache? appDataCache;
  static const maxPathListLength = 4;
  List<String> _entityPagePath = List<String>.empty();
  List<String> _chartPath = List<String>.empty();
  var _comparisonPathList = <List<String>>[
    [ModelConstants.rootEntityName]
  ];
  String _sortMetric = UiConstants.noSortMetricName;
  int _seriesLength = 0;
  bool _per100k = false;
  bool _compareRegion = false;
  String _editStarName = '';

  CovidEntitiesPageModel(List<String> path)
      : _entityPagePath = List<String>.from(path),
        _chartPath = List<String>.from(path) {
    appDataCache = AppDataCache('app_state', onInitFinish: () {
      loadStar(ModelConstants.startupStarName);
    });
  }

  List<String> entityPagePath() {
    return List<String>.from(_entityPagePath);
  }

  void setEntityPagePath(List<String> path) {
    _entityPagePath = List<String>.from(path);
    notifyListeners();
  }

  List<String> chartPath() {
    return List<String>.from(_chartPath);
  }

  void setChartPath(List<String> chartPath) {
    _chartPath = List<String>.from(chartPath);
    if (!_compareRegion) {
      _comparisonPathList = <List<String>>[];
    }
    _addComparisonPathList(chartPath);
    notifyListeners();
  }

  List<List<String>> get comparisonPathList => _comparisonPathList;

  void _addComparisonPathList(List<String> path) {
    for (var existingPath in _comparisonPathList) {
      if (listEquals(path, existingPath)) {
        return;
      }
    }
    if (_comparisonPathList.length >= maxPathListLength) {
      _comparisonPathList.removeAt(0);
    }
    _comparisonPathList.add(path);
    notifyListeners();
  }

  List<List<String>> getAllModelPaths() {
    // TODO: filter duplicate paths.
    List<List<String>> allPaths = [];
    allPaths.add(_entityPagePath);
    allPaths.add(_chartPath);
    for (var path in _comparisonPathList) {
      allPaths.add(path);
    }
    return allPaths;
  }

  void clearComparisonPathList() {
    _comparisonPathList = <List<String>>[];
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

  List<Color> chartColors(List<List<String>> paths, String seriesName) {
    List<Color> colors;
    if (compareRegion == true) {
      colors = generateColors(paths.length);
    } else if (seriesName.contains('Death')) {
      colors = [Colors.red];
    } else {
      colors = [Colors.black];
    }
    return colors;
  }

  List<String> getStarredNames() {
    return appDataCache?.getStarredNames() ?? [];
  }

  String get editStarName => _editStarName;

  set editStarName(value) {
    _editStarName = value;
  }

  void addStar(String name) {
    var star = StarredModel(name, _compareRegion, per100k, seriesLength,
        _entityPagePath, _comparisonPathList, _chartPath);
    appDataCache?.addStarred(name, star);
  }

  void deleteStar(String name) {
    appDataCache?.deleteStarred(name);
  }

  void renameStar(String oldName, String newName) {
    var star = appDataCache?.getStarred(oldName);
    if (star != null) {
      appDataCache!.deleteStarred(oldName);
      appDataCache!.addStarred(newName, star);
    }
  }

  void loadStar(String name) {
    var star = appDataCache?.getStarred(name);
    if (star != null) {
      _compareRegion = star.compareRegion;
      _per100k = star.per100k;
      _seriesLength = star.seriesLength;
      _entityPagePath = star.path.toList();
      _comparisonPathList = StarredModel.copyListListString(star.pathList);
      _chartPath = star.chartPath.toList();
      notifyListeners();
    }
  }

  void notify() {
    notifyListeners();
  }
}

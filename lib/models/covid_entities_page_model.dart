import 'package:covid_trends/models/starred_model.dart';
import 'package:covid_trends/theme/palette_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/palette_colors.dart';
import '../widgets/ui_constants.dart';
import 'app_data_cache.dart';
import 'model_constants.dart';
import 'starred_model.dart';

class CovidEntitiesPageModel with ChangeNotifier {
  AppDataCache? appDataCache;
  List<String> _entityPagePath = List<String>.empty();
  List<String> _chartPath = List<String>.empty();
  var _comparisonGraphModel = CovidComparisonGraphModel();
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
      _comparisonGraphModel.clear();
    }
    _comparisonGraphModel.addPath(chartPath);
    notifyListeners();
  }

  List<List<String>> get comparisonPathList => _comparisonGraphModel.pathList;
  List<Color> get comparisonPathColors => _comparisonGraphModel.pathColors;

  List<List<String>> getAllModelPaths() {
    // TODO: filter duplicate paths.
    List<List<String>> allPaths = [];
    allPaths.add(_entityPagePath);
    allPaths.add(_chartPath);
    for (var path in _comparisonGraphModel.pathList) {
      allPaths.add(path);
    }
    return allPaths;
  }

  void clearComparisonPathList() {
    _comparisonGraphModel.clear();
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
      colors = _comparisonGraphModel.pathColors;
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
        _entityPagePath, _comparisonGraphModel.pathList, _chartPath);
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
      _comparisonGraphModel.clear();
      for (var path in star.pathList) {
        _comparisonGraphModel.addPath(path);
      }
      _chartPath = star.chartPath.toList();
      notifyListeners();
    }
  }

  void notify() {
    notifyListeners();
  }
}

class CovidComparisonGraphModel {
  static const maxPathListLength = 6;
  var _comparisonPathList = <List<String>>[
    [ModelConstants.rootEntityName]
  ];
  var _comparisonPathColors = <Color>[PaletteColors.coolGrey.shade900];
  var _comparisonNextColorIndex = 1;

  // Colors from the quantitative palette example in
  // https://chartio.com/learn/charts/how-to-choose-colors-data-visualization/
  final comparisonColors = <Color>[
    Color(0xFF0483A6),
    Color(0xFFF6CA58),
    Color(0xFF704C7D),
    Color(0xFF9BDA60),
    Color(0xFFCB482B),
    Color(0xFFFFA250),
    Color(0xFF8BDDD0),
  ];

  List<List<String>> get pathList => _comparisonPathList;
  List<Color> get pathColors => _comparisonPathColors;

  void clear() {
    _comparisonPathList = <List<String>>[];
    _comparisonPathColors = <Color>[];
    _comparisonNextColorIndex = 0;
  }

  bool addPath(List<String> path) {
    for (var existingPath in _comparisonPathList) {
      if (listEquals(path, existingPath)) {
        return false;
      }
    }
    if (_comparisonPathList.length >= maxPathListLength) {
      _comparisonPathList.removeAt(0);
      _comparisonPathColors.removeAt(0);
    }
    _comparisonPathList.add(path);
    _comparisonPathColors.add(comparisonColors[_comparisonNextColorIndex]);

    _comparisonNextColorIndex++;
    if (_comparisonNextColorIndex >= comparisonColors.length) {
      _comparisonNextColorIndex = 0;
    }

    return true;
  }
}

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
// limitations under the License.

import 'package:covid_trends/models/starred_chart_examples.dart';
import 'package:covid_trends/models/starred_model.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../theme/graph_colors.dart';
import 'app_data_cache.dart';
import 'app_shared_preferences.dart';
import 'comparison_graph_model.dart';
import 'covid_series_id.dart';
import 'region_metric_id.dart';
import 'model_constants.dart';
import 'starred_model.dart';

class CovidFlowTab {
  static const int regions = 0;
  static const int starred = 0;
  static const int colors = 0;
}

/// Holds the main application display state in a model outside the widget tree.
class AppDisplayStateModel with ChangeNotifier {
  var _appInfo = CovidAppInfo();
  var _appPreferences = AppSharedPreferences();
  var _appDataCache = AppDataCache('app_state');
  int _selectedTab = CovidFlowTab.regions;
  List<String> _parentPath = List<String>.empty();
  List<String> _chartPath = List<String>.empty();
  var _comparisonGraphModel = ComparisonGraphModel();
  RegionMetricId _sortMetric = RegionMetricId.None;
  int _seriesLength = 0;
  bool _per100k = false;
  bool _compareRegion = false;
  String _selectedStarName = '';
  bool _entitySearchActive = false;
  String _entitySearchString = '';

  AppDisplayStateModel(List<String> path)
      : _parentPath = List<String>.from(path),
        _chartPath = List<String>.from(path) {
    initializeLocalDataStores();
  }

  void initializeLocalDataStores() async {
    _appInfo.initialize();

    await Future.wait<void>([
      _appDataCache.initialize(),
      _appPreferences.initialize(),
    ]);
    loadStar(ModelConstants.startupStarName);
    if (_appPreferences.addExampleCharts) {
      addStarredList(starredChartExamples);
      _appPreferences.addExampleCharts = false;
    }
  }

  String get appName => _appInfo.appName;
  String get appVersion => _appInfo.version;
  String get appBuild => _appInfo.buildNumber;

  set addExampleChartsPreference(bool value) {
    _appPreferences.addExampleCharts = value;
  }

  int get selectedTab => _selectedTab;

  void goToTab(index) {
    _selectedTab = index;
    notifyListeners();
  }

  List<String> parentPath() {
    return List<String>.from(_parentPath);
  }

  void setParentPath(List<String> path) {
    _parentPath = List<String>.from(path);
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

  bool isComparisonPathHighlighted(List<String> path) {
    return _comparisonGraphModel.isPathHighlighted(path);
  }

  void setComparisonPathHighlight(List<String> path, bool isHighlighted) {
    _comparisonGraphModel.setPathHighlight(path, isHighlighted);
    notifyListeners();
  }

  void restoreHighlightFadeDefaults() {
    _comparisonGraphModel.restoreHighlightFadeDefaults();
    notifyListeners();
  }

  GraphLineFadeTypes get fadeType => _comparisonGraphModel.fadeType;

  set fadeType(GraphLineFadeTypes value) {
    _comparisonGraphModel.fadeType = value;
    notifyListeners();
  }

  double get fadeFactor => _comparisonGraphModel.fadeFactor;

  set fadeFactor(double value) {
    _comparisonGraphModel.fadeFactor = value;
    notifyListeners();
  }

  int get fadeAlpha => _comparisonGraphModel.fadeAlpha;

  set fadeAlpha(int value) {
    _comparisonGraphModel.fadeAlpha = value;
    notifyListeners();
  }

  GraphLineHighlightTypes get highlightType =>
      _comparisonGraphModel.highlightType;

  set highlightType(GraphLineHighlightTypes value) {
    _comparisonGraphModel.highlightType = value;
    notifyListeners();
  }

  double get highlightFactor => _comparisonGraphModel.highlightFactor;

  set highlightFactor(double value) {
    _comparisonGraphModel.highlightFactor = value;
    notifyListeners();
  }

  List<List<String>> getAllModelPaths() {
    // TODO: filter duplicate paths.
    List<List<String>> allPaths = [];
    allPaths.add(_parentPath);
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

  /// Sort metric for entity list leaf regions.
  ///
  /// A sort metric of "None" sorts by region name.
  RegionMetricId get sortMetric => _sortMetric;

  /// Display metric for entity list regions.
  RegionMetricId get itemListMetric => (_sortMetric != RegionMetricId.None)
      ? _sortMetric
      : RegionMetricId.ConfirmedDaily;

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

  List<Color> chartColors(List<List<String>> paths, CovidSeriesId seriesId) {
    List<Color> colors;
    if (compareRegion == true) {
      colors = _comparisonGraphModel.pathColors;
    } else if (seriesId == CovidSeriesId.Deaths ||
        seriesId == CovidSeriesId.DeathsDaily) {
      colors = [GraphColors.deaths];
    } else if (seriesId == CovidSeriesId.Confirmed ||
        seriesId == CovidSeriesId.ConfirmedDaily) {
      colors = [GraphColors.confirmed];
    } else {
      colors = [GraphColors.singleDefault];
    }
    return colors;
  }

  List<String> getStarredNames() {
    return _appDataCache.getStarredNames();
  }

  String get selectedStarName => _selectedStarName;

  set selectedStarName(value) {
    _selectedStarName = value;
    notifyListeners();
  }

  void addStar(String name) {
    var star = StarredModel(
      name,
      _compareRegion,
      per100k,
      seriesLength,
      _parentPath,
      _chartPath,
      _comparisonGraphModel.pathList,
      _comparisonGraphModel.pathColorIndexes,
      _comparisonGraphModel.pathHighlights,
      _comparisonGraphModel.fadeType,
      _comparisonGraphModel.fadeFactor,
      _comparisonGraphModel.fadeAlpha,
      _comparisonGraphModel.highlightType,
      _comparisonGraphModel.highlightFactor,
    );
    _appDataCache.addStarred(name, star);
    notifyListeners();
  }

  void addStarredList(List<StarredModel> stars) {
    for (var star in stars) {
      _appDataCache.addStarred(star.name, star);
    }
    notifyListeners();
  }

  void deleteStar(String name) {
    _appDataCache.deleteStarred(name);
    notifyListeners();
  }

  void renameStar(String oldName, String newName) {
    var star = _appDataCache.getStarred(oldName);
    if (star != null) {
      _appDataCache.deleteStarred(oldName);
      _appDataCache.addStarred(newName, star);
    }
    notifyListeners();
  }

  void loadStar(String name) {
    var star = _appDataCache.getStarred(name);
    if (star != null) {
      _compareRegion = star.compareRegion;
      _per100k = star.per100k;
      _seriesLength = star.seriesLength;
      _parentPath = star.path.toList();
      _comparisonGraphModel.clear();
      _chartPath = star.chartPath.toList();

      for (var pathIndex = 0;
          pathIndex < star.comparisonPathList.length;
          pathIndex++) {
        var colorIndexes = star.comparisonPathColorIndexes;
        var highlights = star.comparisonPathHighlights;
        var path = star.comparisonPathList[pathIndex];

        // If highlight information is available for this path use it,
        // else create path entry without highlighting.
        if (colorIndexes != null &&
            highlights != null &&
            pathIndex < colorIndexes.length &&
            pathIndex < highlights.length) {
          _comparisonGraphModel.addPathWithAttributes(
              path, colorIndexes[pathIndex], highlights[pathIndex]);
        } else {
          _comparisonGraphModel.addPath(path);
        }
      }

      // Load highlight color information if available.
      _comparisonGraphModel.fadeType = (star.fadeType != null)
          ? star.fadeType!
          : ComparisonGraphModel.defaultFadeType;
      _comparisonGraphModel.fadeFactor = (star.fadeFactor != null)
          ? star.fadeFactor!
          : ComparisonGraphModel.defaultFadeFactor;
      _comparisonGraphModel.fadeAlpha = (star.fadeAlpha != null)
          ? star.fadeAlpha!
          : ComparisonGraphModel.defaultFadeAlpha;
      _comparisonGraphModel.highlightType = (star.highlightType != null)
          ? star.highlightType!
          : ComparisonGraphModel.defaultHighlightType;
      _comparisonGraphModel.highlightFactor = (star.highlightFactor != null)
          ? star.highlightFactor!
          : ComparisonGraphModel.defaultHightlightFactor;
      notifyListeners();
    }
  }

  bool get entitySearchActive => _entitySearchActive;

  set entitySearchActive(bool value) {
    if (_entitySearchActive != value) {
      _entitySearchActive = value;
      notifyListeners();
    }
  }

  String get entitySearchString => _entitySearchString;

  set entitySearchString(String value) {
    if (entitySearchString != value) {
      _entitySearchString = value;
      notifyListeners();
    }
  }

  double get singleChartStrokeWidth => _appPreferences.singleChartStrokeWidth;

  set singleChartStrokeWidth(double value) {
    _appPreferences.singleChartStrokeWidth = value;
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }
}

/// Holds app version and build info.
class CovidAppInfo {
  String appName = 'Covid Flows';
  String version = '1.0';
  String buildNumber = '';

  void initialize() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    appName = packageInfo.appName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  }
}

class RegionPath {
  static String name(List<String> path) {
    return path.join('/');
  }

  static List<String> pathFromName(String name) {
    return name.split('/');
  }
}

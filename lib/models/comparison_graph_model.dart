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
// limitations under the License.import 'dart:collection';

/// Holds application graph comparison display state.

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/graph_colors.dart';
import 'model_constants.dart';

class ComparisonGraphModel {
  static const pathsMax = 6;
  static const defaultFadeType = GraphLineFadeTypes.toColoredWhite;
  static const defaultFadeFactor = 0.25;
  static const defaultFadeAlpha = 0x40;
  static const defaultHighlightType = GraphLineHighlightTypes.pop;
  static const defaultHightlightFactor = 0.5;

  var _paths = <List<String>>[
    [ModelConstants.rootEntityName]
  ];
  var _pathColorIndexes = <int>[0];
  var _nextColorIndex = 1;
  var _pathHighlights = <bool>[false];
  var _fadeType = defaultFadeType;
  var _fadeFactor = defaultFadeFactor;
  var _fadeAlpha = defaultFadeAlpha;
  var _highlightType = defaultHighlightType;
  var _highlightFactor = defaultHightlightFactor;

  late var fadedColors = List<Color>.from(GraphColors.basicColors.map((color) =>
      GraphColors.fade(color, _fadeType, _fadeFactor).withAlpha(_fadeAlpha)));

  late var highlightColors = List<Color>.from(GraphColors.basicColors.map(
      (color) =>
          GraphColors.highlight(color, _highlightType, _highlightFactor)));

  void restoreHighlightFadeDefaults() {
    _fadeType = defaultFadeType;
    _fadeFactor = defaultFadeFactor;
    _fadeAlpha = defaultFadeAlpha;
    _highlightType = defaultHighlightType;
    _highlightFactor = defaultHightlightFactor;
    updateHighlightColors();
    updateFadedColors();
  }

  void updateFadedColors() {
    fadedColors = List<Color>.from(GraphColors.basicColors.map((color) =>
        GraphColors.fade(color, _fadeType, _fadeFactor).withAlpha(_fadeAlpha)));
  }

  void updateHighlightColors() {
    highlightColors = List<Color>.from(GraphColors.basicColors.map((color) =>
        GraphColors.highlight(color, _highlightType, _highlightFactor)));
  }

  GraphLineFadeTypes get fadeType => _fadeType;

  set fadeType(GraphLineFadeTypes value) {
    _fadeType = value;
    updateFadedColors();
  }

  double get fadeFactor => _fadeFactor;

  set fadeFactor(double value) {
    _fadeFactor = value;
    updateFadedColors();
  }

  int get fadeAlpha => _fadeAlpha;

  set fadeAlpha(int value) {
    _fadeAlpha = value;
    updateFadedColors();
  }

  GraphLineHighlightTypes get highlightType => _highlightType;

  set highlightType(GraphLineHighlightTypes value) {
    _highlightType = value;
    updateHighlightColors();
  }

  double get highlightFactor => _highlightFactor;

  set highlightFactor(double value) {
    _highlightFactor = value;
    updateHighlightColors();
  }

  List<List<String>> get pathList => _paths;
  List<int> get pathColorIndexes => _pathColorIndexes;
  List<bool> get pathHighlights => _pathHighlights;

  List<Color> get pathColors {
    // See if any regions are highlighted.
    var noRegionsHighlighted = true;
    _pathHighlights.forEach((isHighlighted) {
      if (isHighlighted) {
        noRegionsHighlighted = false;
      }
    });

    // If no regions are highlighted use standard colors.
    if (noRegionsHighlighted) {
      return GraphColors.basicColors;
    }

    // Otherwise use a combination of highlighted and faded colors.
    var colors = <Color>[];
    _pathHighlights.forEachIndexed((pathIndex, isHighlighted) {
      var colorIndex = _pathColorIndexes[pathIndex];
      colors.add(isHighlighted
          ? highlightColors[colorIndex]
          : fadedColors[colorIndex]);
    });
    return colors;
  }

  void clear() {
    _paths = <List<String>>[];
    _pathColorIndexes = <int>[];
    _nextColorIndex = 0;
    _pathHighlights = <bool>[];
  }

  bool addPath(List<String> path) {
    for (var existingPath in _paths) {
      if (listEquals(path, existingPath)) {
        return false;
      }
    }
    if (_paths.length >= pathsMax) {
      _paths.removeAt(0);
      _pathColorIndexes.removeAt(0);
      _pathHighlights.removeAt(0);
    }
    _paths.add(path);
    _pathColorIndexes.add(_nextColorIndex);
    _pathHighlights.add(false);

    _nextColorIndex++;
    if (_nextColorIndex >= GraphColors.basicColors.length) {
      _nextColorIndex = 0;
    }

    return true;
  }

  void addPathWithAttributes(
      List<String> path, int colorIndex, bool isHighlighted) {
    addPath(path);

    var pathIndex = findComparisonPath(path);
    if (pathIndex >= 0) {
      _pathColorIndexes[pathIndex] = colorIndex;
      _pathHighlights[pathIndex] = isHighlighted;
    }
  }

  /// Returns index of path in the comparison path list or -1 if not present.
  int findComparisonPath(List<String> path) {
    for (var index = 0; index < _paths.length; index++) {
      if (ListEquality<String>().equals(path, _paths[index])) {
        return index;
      }
    }
    return -1;
  }

  bool isPathHighlighted(List<String> path) {
    var pathIndex = findComparisonPath(path);
    return (pathIndex >= 0) ? _pathHighlights[pathIndex] : false;
  }

  void setPathHighlight(List<String> path, bool isHighlighted) {
    var pathIndex = findComparisonPath(path);
    if (pathIndex >= 0) {
      _pathHighlights[pathIndex] = isHighlighted;
    }
  }
}

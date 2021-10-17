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

import '../theme/graph_colors.dart';

/// Holds attributes for a starred chart.
///
/// Handles conversion to and from json.
class StarredModel {
  String name;
  bool compareRegion;
  bool per100k;
  int seriesLength;
  List<String> path;
  List<String> chartPath;
  List<List<String>> comparisonPathList;
  List<int>? comparisonPathColorIndexes;
  List<bool>? comparisonPathHighlights;
  GraphLineFadeTypes? fadeType;
  double? fadeFactor;
  int? fadeAlpha;
  GraphLineHighlightTypes? highlightType;
  double? highlightFactor;

  // TODO: consider using a json serialization package to improve error handling
  // and versioning.

  StarredModel(
      this.name,
      this.compareRegion,
      this.per100k,
      this.seriesLength,
      this.path,
      this.chartPath,
      this.comparisonPathList,
      this.comparisonPathColorIndexes,
      this.comparisonPathHighlights,
      this.fadeType,
      this.fadeFactor,
      this.fadeAlpha,
      this.highlightType,
      this.highlightFactor);

  StarredModel.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        compareRegion = json['compareRegion'],
        per100k = json['per100k'],
        seriesLength = json['seriesLength'],
        path = List<String>.from(json['path']),
        chartPath = List<String>.from(json['chartPath']),
        comparisonPathList = copyJsonListListString(json['pathList']) {
    comparisonPathColorIndexes = (json['pathColorIndexes'] != null)
        ? List<int>.from(json['pathColorIndexes'])
        : null;
    comparisonPathHighlights = (json['pathHighlights'] != null)
        ? List<bool>.from(json['pathHighlights'])
        : null;
    fadeType = (json['fadeType'] != null)
        ? GraphLineFadeTypes.values[json['fadeType']]
        : null;
    fadeFactor = (json['fadeFactor'] != null) ? json['fadeFactor'] : null;
    fadeAlpha = (json['fadeAlpha'] != null) ? json['fadeAlpha'] : null;
    highlightType = (json['highlightType'] != null)
        ? GraphLineHighlightTypes.values[json['highlightType']]
        : null;
    highlightFactor =
        (json['highlightFactor'] != null) ? json['highlightFactor'] : null;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'compareRegion': compareRegion,
        'per100k': per100k,
        'seriesLength': seriesLength,
        'path': List<String>.from(path),
        'chartPath': List<String>.from(chartPath),
        'pathList': copyListListString(comparisonPathList),
        'pathColorIndexes': (comparisonPathColorIndexes != null)
            ? List<int>.from(comparisonPathColorIndexes!)
            : null,
        'pathHighlights': (comparisonPathHighlights != null)
            ? List<bool>.from(comparisonPathHighlights!)
            : null,
        'fadeType': fadeType?.index,
        'fadeFactor': fadeFactor,
        'fadeAlpha': fadeAlpha,
        'highlightType': highlightType?.index,
        'highlightFactor': highlightFactor,
      };

  static List<List<String>> copyListListString(List<List<String>> source) {
    List<List<String>> target = [];
    for (var path in source) {
      target.add(List<String>.from(path));
    }
    return target;
  }

  static copyJsonListListString(List<dynamic> source) {
    List<List<String>> target = [];
    for (var path in source) {
      target.add(List<String>.from(path));
    }
    return target;
  }
}

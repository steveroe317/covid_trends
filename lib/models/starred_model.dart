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

class StarredModel {
  String name;
  bool compareRegion;
  bool per100k;
  int seriesLength;
  List<String> path;
  List<List<String>> pathList;
  List<String> chartPath;

  StarredModel(this.name, this.compareRegion, this.per100k, this.seriesLength,
      this.path, this.pathList, this.chartPath);

  StarredModel.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        compareRegion = json['compareRegion'],
        per100k = json['per100k'],
        seriesLength = json['seriesLength'],
        path = List<String>.from(json['path']),
        pathList = copyJsonListListString(json['pathList']),
        chartPath = List<String>.from(json['chartPath']);

  Map<String, dynamic> toJson() => {
        'name': name,
        'compareRegion': compareRegion,
        'per100k': per100k,
        'seriesLength': seriesLength,
        'path': List<String>.from(path),
        'pathList': copyListListString(pathList),
        'chartPath': List<String>.from(chartPath),
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

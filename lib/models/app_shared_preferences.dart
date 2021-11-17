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

import 'package:shared_preferences/shared_preferences.dart';

/// Covid app shared preferences settings.
class AppSharedPreferences {
  final String _singleChartStrokeWidthKey = 'SingleChartStrokeWidth';
  final String _saveExampleChartsKey = 'SaveExampleCharts';
  double _singleChartStrokeWidth = 3.0;
  bool _addExampleCharts = false;

  SharedPreferences? _preferences;

  Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();

    double? strokeWidth = _preferences?.getDouble(_singleChartStrokeWidthKey);
    if (strokeWidth != null) {
      _singleChartStrokeWidth = strokeWidth;
    }

    bool? saveExamples = _preferences?.getBool(_saveExampleChartsKey);
    _addExampleCharts = saveExamples ?? true;
  }

  double get singleChartStrokeWidth => _singleChartStrokeWidth;

  set singleChartStrokeWidth(double value) {
    _singleChartStrokeWidth = value;
    _preferences?.setDouble(_singleChartStrokeWidthKey, value);
  }

  bool get addExampleCharts => _addExampleCharts;

  set addExampleCharts(bool value) {
    _addExampleCharts = value;
    _preferences?.setBool(_saveExampleChartsKey, value);
  }
}

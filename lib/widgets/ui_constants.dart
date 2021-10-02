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

import '../models/region_metric_id.dart';

class UiConstants {
  // UI strings.
  static const noSortMetricName = 'Sort By Name';
  static const saveStar = 'Save Chart';

  // UI string functions.
  static String metricIdLabel(RegionMetricId metricId) {
    switch (metricId) {
      case RegionMetricId.None:
        return 'Confirmed Daily';
      case RegionMetricId.Confirmed:
        return 'Confirmed';
      case RegionMetricId.ConfirmedDaily:
        return 'Confirmed Daily';
      case RegionMetricId.Deaths:
        return 'Deaths';
      case RegionMetricId.DeathsDaily:
        return 'Deaths Daily';
      case RegionMetricId.Rise:
        return 'Rise';
      case RegionMetricId.Spike:
        return 'Spike';
      case RegionMetricId.Population:
        return 'Population';
    }
  }

  static String metricIdSortLabel(RegionMetricId metricId) {
    return (metricId == RegionMetricId.None)
        ? noSortMetricName
        : metricIdLabel(metricId);
  }

  // UI region popu menu sort metrics.
  static const regionSortMetrics = [
    RegionMetricId.None,
    RegionMetricId.Confirmed,
    RegionMetricId.ConfirmedDaily,
    RegionMetricId.Deaths,
    RegionMetricId.DeathsDaily,
    RegionMetricId.Rise,
    RegionMetricId.Spike,
  ];

  // UI layout constants.
  static const iconWidth = 24.0;
  static const minCovidChartHeight = 200.0;

  // Layout design breakpoints.
  static const chartTableWidthBreakpoint = 600.0;
  static const chartTableHeightBreakpoint = 520.0;
  static const chartTableAspectRatioBreakpoint = 0.8;
}

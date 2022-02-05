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

import '../models/covid_series_id.dart';
import '../models/region_metric_id.dart';
import '../theme/graph_colors.dart';

class UiConstants {
  // UI strings.
  static const noSortMetricName = 'Sort By Name';
  static const averagedSubtitle = 'Averaged over 7 days';

  // UI string functions.
  static String metricIdLabel(RegionMetricId metricId) {
    switch (metricId) {
      case RegionMetricId.None:
        return 'Daily Confirmed';
      case RegionMetricId.Confirmed:
        return 'Confirmed';
      case RegionMetricId.ConfirmedDaily:
        return 'Daily Confirmed';
      case RegionMetricId.Deaths:
        return 'Deaths';
      case RegionMetricId.DeathsDaily:
        return 'Daily Deaths';
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

  static String graphLineHighlightDescription(
      GraphLineHighlightTypes highlightType) {
    switch (highlightType) {
      case GraphLineHighlightTypes.pop:
        return 'Pop colors';
      case GraphLineHighlightTypes.toTrueBlack:
        return 'Shift to true black';
      case GraphLineHighlightTypes.toColoredBlack:
        return 'Shift to black';
    }
  }

  static String graphLineFadeDescription(GraphLineFadeTypes fadeType) {
    switch (fadeType) {
      case GraphLineFadeTypes.toTrueBlack:
        return 'Shift to true black';
      case GraphLineFadeTypes.toColoredBlack:
        return 'Shift to black';
      case GraphLineFadeTypes.toTrueWhite:
        return 'Shift to true white';
      case GraphLineFadeTypes.toColoredWhite:
        return 'Shift to white';
      case GraphLineFadeTypes.toGrey:
        return 'Shift to grey';
    }
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

  // UI series averaged data series.
  static const averagedSeries = [
    CovidSeriesId.ConfirmedDaily,
    CovidSeriesId.DeathsDaily,
  ];

  // UI layout constants.
  static const iconWidth = 24.0;
  // TODO: The min chart height should be larger than the min graph height
  // to allow for padding, legends, and titles.
  static const minCovidChartHeight = 200.0;
  static const minCovidGraphHeight = 200.0;
  static const desiredCovidChartAspectRatio = 1.6;

  // Layout design breakpoints.
  static const chartTableWidthBreakpoint = 600.0;
  static const chartTableHeightBreakpoint = 520.0;
  static const chartTableAspectRatioBreakpoint = 0.8;
}

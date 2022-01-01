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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_display_state_model.dart';
import '../models/region_metric_id.dart';
import 'ui_constants.dart';

class SortPopupMenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<RegionMetricId>(
        icon: const Icon(Icons.sort),
        tooltip: UiConstants.noSortMetricName,
        onSelected: (RegionMetricId metricId) {
          var pageModel =
              Provider.of<AppDisplayStateModel>(context, listen: false);
          pageModel.sortMetric = metricId;
        },
        itemBuilder: (BuildContext context) {
          var pageModel =
              Provider.of<AppDisplayStateModel>(context, listen: false);
          return List<PopupMenuEntry<RegionMetricId>>.from(UiConstants
              .regionSortMetrics
              .map((metricId) => CheckedPopupMenuItem(
                  value: metricId,
                  child: Text(UiConstants.metricIdSortLabel(metricId)),
                  checked: metricId == pageModel.sortMetric)));
        });
  }
}

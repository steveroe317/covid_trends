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

import '../models/covid_entities_page_model.dart';
import '../models/covid_timeseries_model.dart';
import 'ui_constants.dart';

PopupMenuButton<String> buildSortPopupMenuButton(BuildContext context) {
  return PopupMenuButton<String>(
      icon: const Icon(Icons.sort),
      tooltip: 'Sort By Name',
      onSelected: (String sortMetric) {
        var pageModel =
            Provider.of<CovidEntitiesPageModel>(context, listen: false);
        pageModel.sortMetric = sortMetric;
      },
      itemBuilder: (BuildContext context) {
        var timeseriesModel =
            Provider.of<CovidTimeseriesModel>(context, listen: false);
        var pageModel =
            Provider.of<CovidEntitiesPageModel>(context, listen: false);
        var metricNames = timeseriesModel.sortMetrics();
        metricNames.sort();
        metricNames.insert(0, UiConstants.noSortMetricName);
        return List<PopupMenuEntry<String>>.from(metricNames.map((name) =>
            CheckedPopupMenuItem(
                value: name,
                child: Text(name),
                checked: name == pageModel.sortMetric)));
      });
}

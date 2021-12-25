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

import 'package:covid_trends/widgets/ui_parameters.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_display_state_model.dart';
import '../models/covid_timeseries_model.dart';
import 'covid_chart_group.dart';
import 'covid_chart_group_page.dart';
import 'covid_entity_list.dart';
import 'ui_colors.dart';
import 'ui_parameters.dart';

class CovidEntitiesWideBody extends StatelessWidget {
  final Key _chartGroupPage;

  CovidEntitiesWideBody(this._chartGroupPage);

  @override
  Widget build(BuildContext context) {
    var pageModel = Provider.of<AppDisplayStateModel>(context);
    var uiParameters = context.read<UiParameters>();

    // This onRegionPressed() function does not need the build context,
    // so it could be defined outside build().
    void onRegionPressed(
        CovidTimeseriesModel timeseriesModel, List<String> path) {
      timeseriesModel.loadEntity(path);
      pageModel.setChartPath(path);
    }

    return Row(children: [
      Container(
          width: uiParameters.entityRowWidth,
          color: UiColors.entityListLeaf,
          child: CovidEntityList(onRegionPressed)),
      Expanded(
        child: RepaintBoundary(key: _chartGroupPage, child: CovidChartGroup()),
      )
    ]);
  }
}

class CovidEntitiesNarrowBody extends StatelessWidget {
  CovidEntitiesNarrowBody();

  @override
  Widget build(BuildContext context) {
    var pageModel = Provider.of<AppDisplayStateModel>(context);

    // onRegionPressed is inside build so that it has access to the context.
    void onRegionPressed(
        CovidTimeseriesModel timeseriesModel, List<String> path) {
      timeseriesModel.loadEntity(path);
      pageModel.setChartPath(path);

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Container(child: CovidChartGroupPage())),
      );
    }

    return Container(
        color: UiColors.entityListLeaf,
        child: CovidEntityList(onRegionPressed));
  }
}

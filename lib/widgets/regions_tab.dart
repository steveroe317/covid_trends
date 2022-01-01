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

import 'package:covid_trends/widgets/home_page_navigation.dart';
import 'package:covid_trends/widgets/ui_parameters.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_display_state_model.dart';
import '../models/covid_timeseries_model.dart';
import '../theme/size_scale.dart';
import 'covid_chart_group.dart';
import 'covid_chart_group_page.dart';
import 'regions_list.dart';
import 'ui_colors.dart';
import 'ui_parameters.dart';

class RegionsWideBodyTab extends StatelessWidget {
  RegionsWideBodyTab(this._chartGroupPage);

  final Key _chartGroupPage;

  @override
  Widget build(BuildContext context) {
    var pageModel = Provider.of<AppDisplayStateModel>(context);
    var uiParameters = context.read<UiParameters>();

    // This onRegionPressed() function does not need the build context,
    // so if pageModel was passed to it, it could be defined outside build().
    void onRegionPressed(
        CovidTimeseriesModel timeseriesModel, List<String> path) {
      timeseriesModel.loadRegion(path);
      pageModel.setChartPath(path);
    }

    // showChartGroup is inside build so it has access to the build context.
    void showChartGroup() {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Container(child: CovidChartGroupPage())),
      );
    }

    return Row(
      children: [
        HomePageNavigationRail(),
        Card(
            elevation: 5.0,
            margin: EdgeInsets.fromLTRB(
                SizeScale.px8, SizeScale.px8, SizeScale.px8, SizeScale.px8),
            child: Container(
                width: uiParameters.regionRowWidth,
                color: UiColors.regionListLeaf,
                child: RegionsList(onRegionPressed))),
        Expanded(
            child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: showChartGroup,
                onLongPress: showChartGroup,
                child: Card(
                    elevation: 5.0,
                    margin: EdgeInsets.fromLTRB(
                        0.0, SizeScale.px8, SizeScale.px8, SizeScale.px8),
                    child: RepaintBoundary(
                        key: _chartGroupPage, child: CovidChartGroup())))),
      ],
    );
  }
}

class RegionsNarrowBodyTab extends StatelessWidget {
  RegionsNarrowBodyTab(this._chartGroupPage);

  final Key _chartGroupPage;

  @override
  Widget build(BuildContext context) {
    var pageModel = Provider.of<AppDisplayStateModel>(context);

    // onRegionPressed is inside build so that it has access to the page model.
    void onRegionPressed(
        CovidTimeseriesModel timeseriesModel, List<String> path) {
      timeseriesModel.loadRegion(path);
      pageModel.setChartPath(path);
    }

    // showChartGroup is inside build so it has access to the build context.
    void showChartGroup() {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Container(child: CovidChartGroupPage())),
      );
    }

    return Column(children: [
      Expanded(
          flex: 2,
          child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: showChartGroup,
              onLongPress: showChartGroup,
              child: Card(
                  elevation: 5.0,
                  margin: EdgeInsets.fromLTRB(SizeScale.px8, SizeScale.px8,
                      SizeScale.px8, SizeScale.px8),
                  child: RepaintBoundary(
                      key: _chartGroupPage, child: CovidChartGroup())))),
      Expanded(
          flex: 3,
          child: Card(
              elevation: 5.0,
              margin: EdgeInsets.fromLTRB(
                  SizeScale.px8, 0.0, SizeScale.px8, SizeScale.px8),
              child: Container(
                  color: UiColors.regionListLeaf,
                  child: RegionsList(onRegionPressed))))
    ]);
  }
}

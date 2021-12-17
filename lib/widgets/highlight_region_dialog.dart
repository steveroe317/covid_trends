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

import 'package:covid_trends/models/covid_series_id.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_display_state_model.dart';
import '../theme/size_scale.dart';
import 'covid_chart.dart';
import 'ui_colors.dart';

Widget buildHighlightRegionDialog(BuildContext context) {
  return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
    return buildTallHighlightRegionDialog(
        context, constraints.maxHeight > constraints.maxWidth);
  });
}

Widget buildTallHighlightRegionDialog(BuildContext context, bool isTall) {
  var pageModel = Provider.of<AppDisplayStateModel>(context);
  var regionHighlighted = <String, bool>{};

  var listDensity = VisualDensity(
      horizontal: VisualDensity.minimumDensity,
      vertical: VisualDensity.minimumDensity);

  for (var path in pageModel.comparisonPathList) {
    var pathName = RegionPath.name(path);
    regionHighlighted[pathName] = pageModel.isComparisonPathHighlighted(path);
  }

  // Create region header widget. The Material widget is used so that the
  // header widgets color will overlay a surrounding Container widget's color.
  var regionHeader = Material(
      child: ListTile(
    visualDensity: listDensity,
    title: Text('Highlight Regions',
        style: TextStyle(fontWeight: FontWeight.bold)),
    tileColor: UiColors.entityListHeader,
    onTap: () {},
  ));

  // Create region highlight widgets for the dialog's fade options column.
  List<Widget> regionWidgets = editHighlightRegionsWidgets(
      pageModel, true, regionHighlighted, listDensity);

  var closeButtonWidget = TextButton(
    onPressed: () {
      Navigator.of(context).pop();
    },
    child: Text('Close'),
  );

  // Set up chart and highlight widgets in either portrait or landscape mode.
  var chartHighlightWidgets = (isTall)
      ? Column(children: [
          Container(
            constraints: BoxConstraints(maxHeight: 290, maxWidth: 320),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              regionHeader,
              Container(
                  color: UiColors.entityListLeaf,
                  constraints: BoxConstraints(maxHeight: 250, maxWidth: 320),
                  child: ListView(children: regionWidgets))
            ]),
          ),
          Container(
            constraints: BoxConstraints(maxHeight: 220, maxWidth: 320),
            padding: EdgeInsets.fromLTRB(
                SizeScale.px8, SizeScale.px16, SizeScale.px8, 0),
            child: CovidChart(CovidSeriesId.ConfirmedDaily, false, null),
          ),
          closeButtonWidget,
        ])
      : Container(
          constraints: BoxConstraints(maxHeight: 270, maxWidth: 575),
          child: Row(children: [
            Container(
              color: UiColors.entityListLeaf,
              constraints: BoxConstraints(maxHeight: 270, maxWidth: 225),
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                regionHeader,
                Container(
                    constraints: BoxConstraints(maxHeight: 230, maxWidth: 225),
                    child: ListView(children: regionWidgets)),
              ]),
            ),
            Container(
              child: Column(
                children: [
                  Container(
                    constraints: BoxConstraints(maxHeight: 220, maxWidth: 350),
                    padding: EdgeInsets.fromLTRB(
                        SizeScale.px16, SizeScale.px16, SizeScale.px16, 0),
                    child:
                        CovidChart(CovidSeriesId.ConfirmedDaily, false, null),
                  ),
                  closeButtonWidget,
                ],
              ),
            ),
          ]));

  return Dialog(
      child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      chartHighlightWidgets,
    ],
  ));
}

List<Widget> editHighlightRegionsWidgets(
    AppDisplayStateModel pageModel,
    bool isMenuSegment,
    Map<String, bool> regionHighlighted,
    VisualDensity listDensity) {
  var regionWidgets = <Widget>[];

  if (isMenuSegment) {
    // Create region header widget. The Material widget is used so that the
    // header widgets color will overlay a surrounding Container widget's color.
    var regionHeader = Material(
        child: ListTile(
      visualDensity: listDensity,
      title: Text('Highlight Regions',
          style: TextStyle(fontWeight: FontWeight.bold)),
      tileColor: UiColors.entityListHeader,
      onTap: () {},
    ));
    regionWidgets.add(regionHeader);
  }

  var menuItemTextStyle = TextStyle(
      fontWeight: (isMenuSegment) ? FontWeight.normal : FontWeight.bold);

  for (var path in pageModel.comparisonPathList) {
    var pathName = RegionPath.name(path);
    bool highlighted = regionHighlighted[pathName] ?? false;
    regionWidgets.add(ListTile(
      leading:
          Opacity(opacity: highlighted ? 1.0 : 0.0, child: Icon(Icons.check)),
      title: Text(path.last, style: menuItemTextStyle),
      visualDensity: listDensity,
      tileColor: UiColors.entityListLeaf,
      onTap: () {
        var highlighted = regionHighlighted[pathName] ?? false;
        pageModel.setComparisonPathHighlight(path, !highlighted);
      },
    ));
  }
  return regionWidgets;
}

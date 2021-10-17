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
import '../theme/graph_colors.dart';
import '../theme/size_scale.dart';
import 'covid_chart.dart';
import 'ui_colors.dart';

Widget buildHighlightColorsDialog(BuildContext context) {
  return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
    return buildTallHighlightColorDialog(
        context, constraints.maxHeight > constraints.maxWidth);
  });
}

Widget buildTallHighlightColorDialog(BuildContext context, bool isTall) {
  var pageModel = Provider.of<AppDisplayStateModel>(context);

  var listDensity = VisualDensity(
      horizontal: VisualDensity.minimumDensity,
      vertical: VisualDensity.minimumDensity);

  // Create highlight color header widget. The Material widget is used so that
  // the header widgets color will overlay a surrounding Container widget's
  // color.
  var highlightColorHeader = Material(
      child: ListTile(
    visualDensity: listDensity,
    title: Text('Highlight Options',
        style: TextStyle(fontWeight: FontWeight.bold)),
    tileColor: UiColors.entityListHeader,
    onTap: () {},
  ));

  // Widgets for chart highlight color adjustments.
  var highlightColorWidgets = <Widget>[];

  // Create widgets for the dialog's hightlight options column.
  var selectedHighlightType = pageModel.highlightType;
  highlightColorWidgets.add(Container(
      alignment: Alignment.center,
      color: Colors.blueGrey.shade100,
      child: Text('Highlight',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: SizeScale.px16))));
  for (var highlightType in GraphLineHighlightTypes.values) {
    highlightColorWidgets.add(RadioListTile<GraphLineHighlightTypes>(
        value: highlightType,
        title: Text(highlightType.toString().split('.').last),
        groupValue: selectedHighlightType,
        onChanged: (value) {
          if (value != null) {
            selectedHighlightType = value;
            pageModel.highlightType = selectedHighlightType;
          }
        }));
  }
  highlightColorWidgets.add(Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeScale.px24),
      child: Text(
        'Highlight factor ${pageModel.highlightFactor.toStringAsFixed(2)}',
      )));
  highlightColorWidgets.add(Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeScale.px16),
      child: Slider(
          label: 'Highlight Factor',
          value: pageModel.highlightFactor,
          min: 0.0,
          max: 1.0,
          onChanged: (value) {
            pageModel.highlightFactor = value;
          })));

  // Create widgets for the dialog's fade options column.
  var selectedFadeType = pageModel.fadeType;
  highlightColorWidgets.add(Container(
      alignment: Alignment.center,
      color: Colors.blueGrey.shade100,
      child: Text('Fade',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: SizeScale.px16))));
  for (var fadeType in GraphLineFadeTypes.values) {
    highlightColorWidgets.add(RadioListTile<GraphLineFadeTypes>(
        value: fadeType,
        title: Text(fadeType.toString().split('.').last),
        groupValue: selectedFadeType,
        onChanged: (value) {
          if (value != null) {
            selectedFadeType = value;
            pageModel.fadeType = selectedFadeType;
          }
        }));
  }
  highlightColorWidgets.add(Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeScale.px24),
      child: Text('Fade factor ${pageModel.fadeFactor.toStringAsFixed(2)}')));
  highlightColorWidgets.add(Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeScale.px16),
      child: Slider(
          label: 'Fade Factor',
          value: pageModel.fadeFactor,
          min: 0.0,
          max: 1.0,
          onChanged: (value) {
            pageModel.fadeFactor = value;
          })));
  highlightColorWidgets.add(Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeScale.px24),
      child: Text('Fade alpha 0x${pageModel.fadeAlpha.toRadixString(16)}')));
  highlightColorWidgets.add(Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeScale.px16),
      child: Slider(
          label: 'Fade aplha',
          value: pageModel.fadeAlpha.roundToDouble(),
          min: 0,
          max: 255,
          onChanged: (value) {
            pageModel.fadeAlpha = value.round();
          })));

  // Create widgets to restore highlight and fade defaults.
  highlightColorWidgets.add(Container(
      alignment: Alignment.center,
      color: Colors.blueGrey.shade100,
      child: Text('Restore',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: SizeScale.px16))));
  highlightColorWidgets.add(Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeScale.px24),
      child: ListTile(
        title: Text('Restore Defaults'),
        onTap: () {
          pageModel.restoreHighlightFadeDefaults();
        },
      )));
  var closeButtonWidget = TextButton(
    onPressed: () {
      Navigator.of(context).pop();
    },
    child: Text('Close'),
  );

  // Set up chart and highlight widgets in either portrait or landscape mode.
  var chartHighlightColorWidgets = (isTall)
      ? Column(children: [
          Container(
            constraints: BoxConstraints(maxHeight: 290, maxWidth: 320),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              highlightColorHeader,
              Scrollbar(
                  isAlwaysShown: true,
                  thickness: SizeScale.px8,
                  child: Container(
                      color: UiColors.entityListLeaf,
                      constraints:
                          BoxConstraints(maxHeight: 250, maxWidth: 320),
                      child: ListView(children: highlightColorWidgets)))
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
                highlightColorHeader,
                Scrollbar(
                  isAlwaysShown: true,
                  thickness: SizeScale.px8,
                  child: Container(
                      constraints:
                          BoxConstraints(maxHeight: 230, maxWidth: 225),
                      child: ListView(children: highlightColorWidgets)),
                )
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
      chartHighlightColorWidgets,
    ],
  ));
}

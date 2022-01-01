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
import '../theme/graph_colors.dart';
import '../theme/size_scale.dart';
import 'ui_colors.dart';
import 'ui_constants.dart';

class EditChartList extends StatelessWidget {
  final ScrollController _optionsListController = ScrollController();

  @override
  build(BuildContext context) {
    var pageModel = Provider.of<AppDisplayStateModel>(context);

    var regionHighlighted = <String, bool>{};
    for (var path in pageModel.comparisonPathList) {
      var pathName = RegionPath.name(path);
      regionHighlighted[pathName] = pageModel.isComparisonPathHighlighted(path);
    }

    var listDensity = VisualDensity(
        horizontal: VisualDensity.minimumDensity,
        vertical: VisualDensity.minimumDensity);

    var optionsWidgets = <Widget>[];
    optionsWidgets.addAll(editHighlightRegionsWidgets(
        pageModel, true, regionHighlighted, listDensity));
    optionsWidgets.addAll(editHighlightsWidgets(pageModel));

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Scrollbar(
              isAlwaysShown: true,
              controller: _optionsListController,
              thickness: SizeScale.px8,
              child: Container(
                  child: ListView(
                      controller: _optionsListController,
                      children: optionsWidgets))));
    });
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
        tileColor: UiColors.regionListHeader,
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
        tileColor: UiColors.regionListLeaf,
        onTap: () {
          var highlighted = regionHighlighted[pathName] ?? false;
          pageModel.setComparisonPathHighlight(path, !highlighted);
        },
      ));
    }
    return regionWidgets;
  }

  List<Widget> editHighlightsWidgets(AppDisplayStateModel pageModel) {
    var highlightOptions = <GraphLineHighlightTypes>[
      GraphLineHighlightTypes.pop,
      GraphLineHighlightTypes.toColoredBlack,
    ];
    var fadeOptions = <GraphLineFadeTypes>[
      GraphLineFadeTypes.toColoredBlack,
      GraphLineFadeTypes.toColoredWhite,
      GraphLineFadeTypes.toGrey,
    ];

    // Widgets for chart highlight color adjustments.
    var highlightColorWidgets = <Widget>[];

    // Create widgets for the dialog's hightlight options column.
    var selectedHighlightType = pageModel.highlightType;
    highlightColorWidgets.add(Container(
        padding: EdgeInsets.all(SizeScale.px12),
        alignment: Alignment.centerLeft,
        color: UiColors.regionListHeader,
        child: Text('Highlight Options',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: SizeScale.px16))));
    for (var highlightType in highlightOptions) {
      highlightColorWidgets.add(RadioListTile<GraphLineHighlightTypes>(
          value: highlightType,
          title: Text(UiConstants.graphLineHighlightDescription(highlightType)),
          groupValue: selectedHighlightType,
          onChanged: (value) {
            if (value != null) {
              selectedHighlightType = value;
              pageModel.highlightType = selectedHighlightType;
            }
          }));
    }
    highlightColorWidgets.add(Padding(
        padding: EdgeInsets.fromLTRB(
            SizeScale.px24, SizeScale.px12, SizeScale.px24, 0),
        child: Text(
          'Highlight Intensity ${pageModel.highlightFactor.toStringAsFixed(2)}',
          style: TextStyle(fontSize: SizeScale.px16),
        )));
    highlightColorWidgets.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: SizeScale.px16),
        child: Slider(
            label: 'Highlight Intensity',
            value: pageModel.highlightFactor,
            min: 0.0,
            max: 1.0,
            onChanged: (value) {
              pageModel.highlightFactor = value;
            })));

    // Create widgets for the dialog's fade options column.
    var selectedFadeType = pageModel.fadeType;
    highlightColorWidgets.add(Container(
        padding: EdgeInsets.all(SizeScale.px12),
        alignment: Alignment.centerLeft,
        color: UiColors.regionListHeader,
        child: Text('Fade Options',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: SizeScale.px16))));
    for (var fadeType in fadeOptions) {
      highlightColorWidgets.add(RadioListTile<GraphLineFadeTypes>(
          value: fadeType,
          title: Text(UiConstants.graphLineFadeDescription(fadeType)),
          groupValue: selectedFadeType,
          onChanged: (value) {
            if (value != null) {
              selectedFadeType = value;
              pageModel.fadeType = selectedFadeType;
            }
          }));
    }
    highlightColorWidgets.add(Padding(
        padding: EdgeInsets.fromLTRB(
            SizeScale.px24, SizeScale.px12, SizeScale.px24, 0),
        child: Text(
          'Fade Intensity ${pageModel.fadeFactor.toStringAsFixed(2)}',
          style: TextStyle(fontSize: SizeScale.px16),
        )));
    highlightColorWidgets.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: SizeScale.px16),
        child: Slider(
            label: 'Fade Intensity',
            value: pageModel.fadeFactor,
            min: 0.0,
            max: 1.0,
            onChanged: (value) {
              pageModel.fadeFactor = value;
            })));
    // The fade transparency widgets show internal color alpha integer values of
    // 255 to 0 as transparency double values from 0.0 to 1.0.
    highlightColorWidgets.add(Padding(
        padding: EdgeInsets.fromLTRB(
            SizeScale.px24, SizeScale.px12, SizeScale.px24, 0),
        child: Text(
          'Fade Transparency ${(1.0 - pageModel.fadeAlpha / 255).toStringAsFixed(2)}',
          style: TextStyle(fontSize: SizeScale.px16),
        )));
    highlightColorWidgets.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: SizeScale.px16),
        child: Slider(
            label: 'Fade Transparency',
            value: 255 - pageModel.fadeAlpha.roundToDouble(),
            min: 0,
            max: 255,
            divisions: 10,
            onChanged: (value) {
              pageModel.fadeAlpha = 255 - value.round();
            })));

    // Create widgets to restore highlight and fade defaults.
    highlightColorWidgets.add(Container(
        padding: EdgeInsets.all(SizeScale.px12),
        alignment: Alignment.centerLeft,
        color: UiColors.regionListHeader,
        child: Text('Restore',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: SizeScale.px16))));
    highlightColorWidgets.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: SizeScale.px24),
        child: ListTile(
          title: Text('Restore Default Options'),
          onTap: () {
            pageModel.restoreHighlightFadeDefaults();
          },
        )));
    return highlightColorWidgets;
  }
}

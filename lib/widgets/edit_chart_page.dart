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

import 'compare_region_popup_menu.dart';
import 'covid_chart_group.dart';
import 'date_range_popup_menu.dart';
import 'per_100k_popup_menu.dart';
import 'edit_chart_list.dart';
import 'ui_colors.dart';
import 'ui_parameters.dart';

class EditChartPage extends StatefulWidget {
  final String title;

  const EditChartPage({Key? key, required this.title}) : super(key: key);

  @override
  _EditChartPageState createState() => _EditChartPageState();
}

class _EditChartPageState extends State<EditChartPage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 700) {
        return ChangeNotifierProvider<UiParameters>(
            create: (_) => UiParameters(UiAppShape.Wide),
            child: _buildWideScaffold(context, widget.title));
      } else if (constraints.maxWidth >= 350) {
        return ChangeNotifierProvider<UiParameters>(
            create: (_) => UiParameters(UiAppShape.Narrow),
            child: _buildNarrowScaffold(context, widget.title));
      } else {
        return ChangeNotifierProvider<UiParameters>(
            create: (_) => UiParameters(UiAppShape.Mini),
            child: _buildNarrowScaffold(context, widget.title));
      }
    });
  }

  Scaffold _buildWideScaffold(BuildContext context, String title) {
    final chartGroupKey = GlobalKey();

    var actions = [
      buildCompareRegionPopupMenuButton(context),
      buildDateRangePopupMenuButton(context),
      buildper100kPopupMenuButton(context),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: SafeArea(
          left: true,
          right: true,
          top: true,
          bottom: true,
          minimum: EdgeInsets.zero,
          child: _EditChartWideListBody(chartGroupKey)),
    );
  }
}

Scaffold _buildNarrowScaffold(BuildContext context, String title) {
  final chartGroupKey = GlobalKey();

  var actions = [
    buildCompareRegionPopupMenuButton(context),
    buildDateRangePopupMenuButton(context),
    buildper100kPopupMenuButton(context),
  ];

  return Scaffold(
    appBar: AppBar(
      title: Text(title),
      actions: actions,
    ),
    body: _EditChartNarrowListBody(chartGroupKey),
  );
}

class _EditChartWideListBody extends StatelessWidget {
  final Key _chartGroupPage;

  _EditChartWideListBody(this._chartGroupPage);

  void onSavedChartPressed(
      AppDisplayStateModel pageModel, String savedChartName) {
    pageModel.loadStar(savedChartName);
    pageModel.selectedStarName = savedChartName;
  }

  @override
  Widget build(BuildContext context) {
    var uiParameters = context.read<UiParameters>();

    return Row(
      children: [
        Card(
            elevation: 10.0,
            child: Container(
                width: uiParameters.entityRowWidth,
                color: UiColors.entityListLeaf,
                child: EditChartList())),
        Expanded(
            child: RepaintBoundary(
                key: _chartGroupPage, child: CovidChartGroup())),
      ],
    );
  }
}

class _EditChartNarrowListBody extends StatelessWidget {
  final Key _chartGroupPage;

  _EditChartNarrowListBody(this._chartGroupPage);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          flex: 2,
          child: Card(
              elevation: 5.0,
              child: RepaintBoundary(
                  key: _chartGroupPage, child: CovidChartGroup()))),
      Expanded(
          flex: 3,
          child: SafeArea(
              child: Card(
                  elevation: 5.0,
                  child: Container(
                      color: UiColors.entityListLeaf,
                      margin: const EdgeInsets.only(bottom: 6.0),
                      child: EditChartList()))))
    ]);
  }
}

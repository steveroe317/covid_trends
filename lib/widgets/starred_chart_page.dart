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
import 'covid_chart_group_page.dart';
import 'date_range_popup_menu.dart';
import 'highlight_region_popup_menu.dart';
import 'per_100k_popup_menu.dart';
import 'share_button.dart';
import 'starred_chart_list.dart';
import 'ui_colors.dart';
import 'ui_parameters.dart';

class StarredChartPage extends StatefulWidget {
  final String title;

  const StarredChartPage({Key? key, required this.title}) : super(key: key);

  @override
  _StarredChartPageState createState() => _StarredChartPageState();
}

class _StarredChartPageState extends State<StarredChartPage> {
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
            child: _buildNarrowScaffold(context));
      } else {
        return ChangeNotifierProvider<UiParameters>(
            create: (_) => UiParameters(UiAppShape.Mini),
            child: _buildNarrowScaffold(context));
      }
    });
  }

  Scaffold _buildWideScaffold(BuildContext context, String title) {
    final chartGroupKey = GlobalKey();
    var pageModel = Provider.of<AppDisplayStateModel>(context);

    var actions = [
      buildCompareRegionPopupMenuButton(context),
      buildDateRangePopupMenuButton(context),
      buildper100kPopupMenuButton(context),
      buildShareButton(context, chartGroupKey),
    ];
    if (pageModel.compareRegion && pageModel.comparisonPathList.length > 1) {
      actions.insert(
          actions.length - 1, buildHighlightRegionPopupMenuButton(context));
    }
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
          child: _StarredChartWideListBody(chartGroupKey)),
    );
  }
}

Scaffold _buildNarrowScaffold(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: null,
      actions: [],
    ),
    body: _StarredChartNarrowListBody(),
  );
}

class _StarredChartWideListBody extends StatelessWidget {
  final Key _chartGroupPage;

  _StarredChartWideListBody(this._chartGroupPage);

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
        Container(
            width: uiParameters.entityRowWidth,
            color: UiColors.entityListLeaf,
            child: StarredChartList(onSavedChartPressed)),
        Expanded(
            child: RepaintBoundary(
                key: _chartGroupPage, child: CovidChartGroup())),
      ],
    );
  }
}

class _StarredChartNarrowListBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // onSavedChartPressed is inside build so that it has access to the context.
    void onSavedChartPressed(
        AppDisplayStateModel pageModel, String savedChartName) {
      pageModel.loadStar(savedChartName);
      pageModel.selectedStarName = savedChartName;

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Container(child: CovidChartGroupPage())),
      );
    }

    return Container(
        color: UiColors.entityListLeaf,
        child: StarredChartList(onSavedChartPressed));
  }
}

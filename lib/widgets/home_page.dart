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

import 'package:covid_trends/widgets/edit_chart_tab.dart';
import 'package:covid_trends/widgets/ui_parameters.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_display_state_model.dart';
import 'compare_region_popup_menu.dart';
import 'date_range_popup_menu.dart';
//import 'debug_popup_menu.dart';
import 'home_page_drawer.dart';
import 'home_page_navigation.dart';
import 'per_100k_popup_menu.dart';
import 'regions_tab.dart';
import 'share_button.dart';
import 'sort_popup_menu.dart';
import 'star_popup_menu.dart';
import 'starred_chart_tab.dart';
import 'ui_parameters.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 700) {
        return ChangeNotifierProvider<UiParameters>(
            create: (_) => UiParameters(UiAppShape.Wide),
            child: WideHomePage(widget.title));
      } else if (constraints.maxWidth >= 350) {
        return ChangeNotifierProvider<UiParameters>(
            create: (_) => UiParameters(UiAppShape.Narrow),
            child: NarrowHomePage(widget.title));
      } else {
        return ChangeNotifierProvider<UiParameters>(
            create: (_) => UiParameters(UiAppShape.Mini),
            child: NarrowHomePage(widget.title));
      }
    });
  }
}

class WideHomePage extends StatelessWidget {
  WideHomePage(this.title);

  final title;
  static final chartGroupKey = GlobalKey();

  static List<Widget> widePages = [
    RegionsWideBodyTab(chartGroupKey),
    StarredChartWideBodyTab(chartGroupKey),
    EditChartWideBodyTab(chartGroupKey),
  ];

  @override
  Widget build(BuildContext context) {
    var pageModel = Provider.of<AppDisplayStateModel>(context);
    // TODO: Create these as inline widgets, not as alls to helper functions.
    // This should reduce overhead during animations.
    List<List<Widget>> wideActions = [
      [
        SortPopupMenuButton(),
        CompareRegionPopupMenuButton(),
        DateRangePopupMenuButton(),
        Per100kPopupMenuButton(),
        StarPopupDialogButton(),
        ShareButton(chartGroupKey),
      ],
      [
        CompareRegionPopupMenuButton(),
        DateRangePopupMenuButton(),
        Per100kPopupMenuButton(),
        ShareButton(chartGroupKey),
      ],
      [
        CompareRegionPopupMenuButton(),
        DateRangePopupMenuButton(),
        Per100kPopupMenuButton(),
      ],
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: wideActions[pageModel.selectedTab],
      ),
      body: SafeArea(child: widePages[pageModel.selectedTab]),
      drawer: HomePageDrawer(),
    );
  }
}

class NarrowHomePage extends StatelessWidget {
  NarrowHomePage(this.title);

  final title;
  static final chartGroupKey = GlobalKey();

  static List<Widget> narrowPages = [
    RegionsNarrowBodyTab(chartGroupKey),
    StarredChartNarrowBodyTab(chartGroupKey),
    EditChartNarrowBodyTab(chartGroupKey),
  ];

  @override
  Widget build(BuildContext context) {
    var pageModel = Provider.of<AppDisplayStateModel>(context);
    List<List<Widget>> narrowActions = [
      [
        SortPopupMenuButton(),
        CompareRegionPopupMenuButton(),
        DateRangePopupMenuButton(),
        Per100kPopupMenuButton(),
        StarPopupDialogButton(),
      ],
      [
        CompareRegionPopupMenuButton(),
        DateRangePopupMenuButton(),
        Per100kPopupMenuButton(),
      ],
      [
        CompareRegionPopupMenuButton(),
        DateRangePopupMenuButton(),
        Per100kPopupMenuButton(),
      ],
    ];

    return Scaffold(
      appBar: AppBar(
        title: title.isNotEmpty ? Text(title) : null,
        actions: narrowActions[pageModel.selectedTab],
      ),
      body: SafeArea(child: narrowPages[pageModel.selectedTab]),
      drawer: HomePageDrawer(),
      bottomNavigationBar: HomePageNavigationBar(),
    );
  }
}

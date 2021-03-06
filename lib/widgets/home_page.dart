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
      } else if (constraints.maxWidth > 375 && constraints.maxHeight > 375) {
        return ChangeNotifierProvider<UiParameters>(
            create: (_) => UiParameters(UiAppShape.Narrow),
            child: NarrowHomePage(widget.title));
      } else {
        return ChangeNotifierProvider<UiParameters>(
            create: (_) => UiParameters(UiAppShape.Mini),
            child: MiniHomePage(widget.title));
      }
    });
  }
}

class WideHomePage extends StatelessWidget {
  WideHomePage(this.title);

  final title;
  static final chartGroupKey = GlobalKey();

  final List<Widget> wideTabs = [
    RegionsWideBodyTab(chartGroupKey),
    StarredChartWideBodyTab(chartGroupKey),
    EditChartWideBodyTab(chartGroupKey),
  ];

  final List<List<Widget>> wideActions = [
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

  @override
  Widget build(BuildContext context) {
    var selectedTab = context.select((AppDisplayStateModel m) => m.selectedTab);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: wideActions[selectedTab],
      ),
      body: SafeArea(child: wideTabs[selectedTab]),
      drawer: HomePageDrawer(),
    );
  }
}

class NarrowHomePage extends StatelessWidget {
  NarrowHomePage(this.title);

  final title;
  static final chartGroupKey = GlobalKey();

  final List<Widget> narrowTabs = [
    RegionsNarrowBodyTab(chartGroupKey),
    StarredChartNarrowBodyTab(chartGroupKey),
    EditChartNarrowBodyTab(chartGroupKey),
  ];

  final List<List<Widget>> narrowActions = [
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

  @override
  Widget build(BuildContext context) {
    var selectedTab = context.select((AppDisplayStateModel m) => m.selectedTab);

    return Scaffold(
      appBar: AppBar(
        title: title.isNotEmpty ? Text(title) : null,
        actions: narrowActions[selectedTab],
      ),
      body: SafeArea(child: narrowTabs[selectedTab]),
      drawer: HomePageDrawer(),
      bottomNavigationBar: HomePageNavigationBar(),
    );
  }
}

class MiniHomePage extends StatelessWidget {
  MiniHomePage(this.title);

  final title;
  static final chartGroupKey = GlobalKey();

  final List<Widget> narrowTabs = [
    RegionsMiniBodyTab(),
    StarredChartMiniBodyTab(chartGroupKey),
    EditChartNarrowBodyTab(chartGroupKey),
  ];

  final List<List<Widget>> narrowActions = [
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

  @override
  Widget build(BuildContext context) {
    var selectedTab = context.select((AppDisplayStateModel m) => m.selectedTab);

    return Scaffold(
      appBar: AppBar(
        title: Text("XX"), //title.isNotEmpty ? Text(title) : null,
        actions: narrowActions[selectedTab],
      ),
      body: SafeArea(child: narrowTabs[selectedTab]),
      drawer: HomePageDrawer(),
      bottomNavigationBar: HomePageNavigationBar(),
    );
  }
}

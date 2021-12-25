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

import 'package:covid_trends/widgets/edit_chart_page.dart';
import 'package:covid_trends/widgets/ui_parameters.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_display_state_model.dart';
import 'compare_region_popup_menu.dart';
import 'date_range_popup_menu.dart';
//import 'debug_popup_menu.dart';
import 'home_page_drawer.dart';
import 'per_100k_popup_menu.dart';
import 'region_chart_page.dart';
import 'share_button.dart';
import 'sort_popup_menu.dart';
import 'star_popup_menu.dart';
import 'starred_chart_page.dart';
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
    CovidEntitiesWideBody(chartGroupKey),
    StarredChartWideBody(chartGroupKey),
    EditChartWideBody(chartGroupKey),
  ];

  @override
  Widget build(BuildContext context) {
    var pageModel = Provider.of<AppDisplayStateModel>(context);
    List<List<Widget>> wideActions = [
      [
        buildSortPopupMenuButton(context),
        buildCompareRegionPopupMenuButton(context),
        buildDateRangePopupMenuButton(context),
        buildper100kPopupMenuButton(context),
        buildStarPopupMenuButton(context),
        buildShareButton(context, chartGroupKey),
      ],
      [
        buildCompareRegionPopupMenuButton(context),
        buildDateRangePopupMenuButton(context),
        buildper100kPopupMenuButton(context),
        buildShareButton(context, chartGroupKey),
      ],
      [
        buildCompareRegionPopupMenuButton(context),
        buildDateRangePopupMenuButton(context),
        buildper100kPopupMenuButton(context),
      ],
    ];
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: wideActions[pageModel.selectedTab],
        ),
        body: SafeArea(
            left: true,
            right: true,
            top: true,
            bottom: true,
            minimum: EdgeInsets.zero,
            child: widePages[pageModel.selectedTab]),
        drawer: HomePageDrawer(),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.language), label: 'Regions'),
            BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Starred'),
            BottomNavigationBarItem(icon: Icon(Icons.tune), label: 'Adjust'),
          ],
          landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
          currentIndex: pageModel.selectedTab,
          onTap: (int index) {
            pageModel.goToTab(index);
          },
        ));
  }
}

class NarrowHomePage extends StatelessWidget {
  NarrowHomePage(this.title);

  final title;
  static final chartGroupKey = GlobalKey();

  static List<Widget> narrowPages = [
    CovidEntitiesNarrowBody(),
    StarredChartNarrowBody(chartGroupKey),
    EditChartNarrowBody(chartGroupKey),
  ];

  @override
  Widget build(BuildContext context) {
    var pageModel = Provider.of<AppDisplayStateModel>(context);
    List<List<Widget>> narrowActions = [
      [
        buildSortPopupMenuButton(context),
        buildCompareRegionPopupMenuButton(context),
        buildDateRangePopupMenuButton(context),
        buildper100kPopupMenuButton(context),
        buildStarPopupMenuButton(context, openChartPage: true),
      ],
      [
        buildCompareRegionPopupMenuButton(context),
        buildDateRangePopupMenuButton(context),
        buildper100kPopupMenuButton(context),
      ],
      [
        buildCompareRegionPopupMenuButton(context),
        buildDateRangePopupMenuButton(context),
        buildper100kPopupMenuButton(context),
      ],
    ];

    return Scaffold(
        appBar: AppBar(
          title: title.isNotEmpty ? Text(title) : null,
          actions: narrowActions[pageModel.selectedTab],
        ),
        body: narrowPages[pageModel.selectedTab],
        drawer: HomePageDrawer(),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.language), label: 'Regions'),
            BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Starred'),
            BottomNavigationBarItem(icon: Icon(Icons.tune), label: 'Adjust'),
          ],
          currentIndex: pageModel.selectedTab,
          onTap: (int index) {
            pageModel.goToTab(index);
          },
        ));
  }
}

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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';
import 'covid_chart_group.dart';
import 'compare_region_popup_menu.dart';
import 'date_range_popup_menu.dart';
import 'per_100k_popup_menu.dart';
import 'share_button.dart';
import 'star_popup_menu.dart';

class CovidChartGroupPage extends StatefulWidget {
  CovidChartGroupPage({Key? key}) : super(key: key);

  @override
  _CovidChartGroupPageState createState() => _CovidChartGroupPageState();
}

class _CovidChartGroupPageState extends State<CovidChartGroupPage> {
  final chartGroupKey = GlobalKey();

  _CovidChartGroupPageState();

  @override
  Widget build(BuildContext context) {
    return Consumer<CovidEntitiesPageModel>(
        builder: (context, pageModel, child) {
      return Scaffold(
          appBar: AppBar(actions: [
            buildCompareRegionPopupMenuButton(context),
            buildDateRangePopupMenuButton(context),
            buildper100kPopupMenuButton(context),
            buildStarPopupMenuButton(context),
            buildShareButton(context, chartGroupKey),
          ]),
          body: Center(
            child:
                RepaintBoundary(key: chartGroupKey, child: CovidChartGroup()),
          ));
    });
  }
}

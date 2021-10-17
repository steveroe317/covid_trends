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

import 'package:covid_trends/widgets/ui_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_display_state_model.dart';
import '../models/covid_series_id.dart';
import '../theme/size_scale.dart';
import 'covid_chart.dart';
import 'compare_region_popup_menu.dart';
import 'date_range_popup_menu.dart';
import 'per_100k_popup_menu.dart';
import 'share_button.dart';
import 'star_popup_menu.dart';

class CovidChartPage extends StatelessWidget {
  final CovidSeriesId seriesId;

  CovidChartPage({Key? key, required this.seriesId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chartGroupKey = GlobalKey();
    return Consumer<AppDisplayStateModel>(builder: (context, pageModel, child) {
      return Scaffold(
          appBar: AppBar(actions: [
            buildCompareRegionPopupMenuButton(context),
            buildDateRangePopupMenuButton(context),
            buildper100kPopupMenuButton(context),
            buildStarPopupMenuButton(context),
            buildShareButton(context, chartGroupKey),
          ]),
          body: SafeArea(
              left: true,
              right: true,
              top: true,
              bottom: true,
              minimum: EdgeInsets.zero,
              child: Center(
                  child: RepaintBoundary(
                      key: chartGroupKey,
                      child: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return Padding(
                              padding: EdgeInsets.all(SizeScale.px24),
                              child: (constraints.maxHeight <
                                      constraints.maxWidth)
                                  ? ConstrainedBox(
                                      constraints: BoxConstraints.expand(),
                                      child: CovidChart(seriesId, true,
                                          pageModel.singleChartStrokeWidth))
                                  : AspectRatio(
                                      aspectRatio: UiConstants
                                          .desiredCovidChartAspectRatio,
                                      child: CovidChart(seriesId, true,
                                          pageModel.singleChartStrokeWidth)));
                        },
                      )))));
    });
  }
}

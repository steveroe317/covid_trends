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

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';
import '../theme/size_scale.dart';
import 'covid_chart.dart';
import 'covid_chart_page.dart';
import 'ui_constants.dart';

class CovidChartGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= UiConstants.chartTableWidthBreakpoint ||
            constraints.maxHeight <= UiConstants.chartTableHeightBreakpoint ||
            constraints.maxWidth / constraints.maxHeight <
                UiConstants.chartTableAspectRatioBreakpoint) {
          return CovidChartList(constraints.maxHeight);
        } else {
          return CovidChartTable(constraints.maxHeight);
        }
      },
    );
  }
}

class CovidChartList extends StatelessWidget {
  final double constraintsHeight;

  CovidChartList(this.constraintsHeight);

  @override
  Widget build(BuildContext context) {
    var labelledChartHeight =
        max(UiConstants.minCovidChartHeight, constraintsHeight / 4);
    return ListView(
      children: <Widget>[
        _LabelledCovidChart("Confirmed 7-Day", labelledChartHeight),
        _LabelledCovidChart("Deaths 7-Day", labelledChartHeight),
        _LabelledCovidChart("Confirmed", labelledChartHeight),
        _LabelledCovidChart("Deaths", labelledChartHeight),
      ],
    );
  }
}

class CovidChartTable extends StatelessWidget {
  final double constraintsHeight;

  CovidChartTable(this.constraintsHeight);

  @override
  Widget build(BuildContext context) {
    var labelledChartHeight =
        max(UiConstants.minCovidChartHeight, constraintsHeight / 2);
    return Row(
      children: [
        Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
              _LabelledCovidChart("Confirmed 7-Day", labelledChartHeight),
              _LabelledCovidChart("Deaths 7-Day", labelledChartHeight),
            ])),
        Expanded(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _LabelledCovidChart("Confirmed", labelledChartHeight),
            _LabelledCovidChart("Deaths", labelledChartHeight),
          ],
        )),
      ],
    );
  }
}

class _LabelledCovidChart extends StatelessWidget {
  final String seriesName;
  final double labelledChartHeight;

  _LabelledCovidChart(this.seriesName, this.labelledChartHeight);

  @override
  build(BuildContext context) {
    final pageModel = Provider.of<CovidEntitiesPageModel>(context);
    final scaleSuffix = (pageModel.per100k) ? ' per 100k' : '';
    var paths = (pageModel.compareRegion)
        ? pageModel.comparisonPathList
        : [pageModel.chartPath()];
    var regionName = (paths.length == 1 && paths.first.length > 0)
        ? '${paths.first.last} '
        : '';

    // This code to get the size of a text widget is from
    // https://stackoverflow.com/questions/52659759
    var label = '$regionName$seriesName$scaleSuffix';
    var labelTextStyle = TextStyle(fontWeight: FontWeight.w600);
    final Size size = (TextPainter(
            text: TextSpan(text: label, style: labelTextStyle),
            maxLines: 1,
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
            textDirection: TextDirection.ltr)
          ..layout())
        .size;
    var chartHeight = labelledChartHeight -
        (SizeScale.px24 + SizeScale.px8 + size.height + SizeScale.px24);

    return Column(children: [
      Padding(
        padding: EdgeInsets.fromLTRB(
            SizeScale.px24, SizeScale.px24, SizeScale.px24, SizeScale.px8),
        child: SizedBox(
          height: chartHeight,
          child: new CovidChart(seriesName, false),
        ),
      ),
      Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, SizeScale.px24),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CovidChartPage(seriesName: seriesName)),
              );
            },
            child: Center(child: Text(label, style: labelTextStyle)),
          ))
    ]);
  }
}
